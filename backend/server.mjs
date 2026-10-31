import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';

const MAX_BODY_BYTES = 4_096;
const MAX_QUESTION_LENGTH = 2_000;
const DEFAULT_MODEL = 'gemma-3-27b-it';

export function createTutorServer({
  apiKey = process.env.GEMINI_API_KEY,
  apiKeyFile = new URL('../.env', import.meta.url),
  model = process.env.GEMMA_MODEL ?? DEFAULT_MODEL,
  allowedOrigins = (process.env.ALLOWED_ORIGINS ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
  fetchImpl = fetch,
  now = Date.now,
  rateLimitMax = 20,
  rateLimitWindowMs = 60_000,
} = {}) {
  const requestsByIp = new Map();

  return createServer(async (request, response) => {
    const origin = request.headers.origin;
    if (origin && !isAllowedOrigin(origin, allowedOrigins)) {
      sendJson(response, 403, { error: 'Origine non autorisée.' });
      return;
    }

    if (origin) {
      response.setHeader('access-control-allow-origin', origin);
      response.setHeader('vary', 'Origin');
    }
    response.setHeader('access-control-allow-methods', 'POST, OPTIONS');
    response.setHeader('access-control-allow-headers', 'content-type');

    if (request.method === 'OPTIONS') {
      response.writeHead(204).end();
      return;
    }

    if (request.method === 'GET' && request.url === '/health') {
      sendJson(response, 200, { status: 'ok' });
      return;
    }

    const isConnectionTest =
      request.method === 'GET' && request.url === '/api/test';
    const isTutorRequest =
      request.method === 'POST' && request.url === '/api/tutor';
    if (!isConnectionTest && !isTutorRequest) {
      sendJson(response, 404, { error: 'Route introuvable.' });
      return;
    }

    const resolvedApiKey = await loadApiKey(apiKey, apiKeyFile);
    if (!resolvedApiKey) {
      sendJson(response, 503, {
        error: 'Clé absente. Ajoute une nouvelle clé après « GEMINI_API_KEY= » dans .env.',
      });
      return;
    }

    try {
      let question = 'Réponds exactement : Sabi est connectée.';
      if (isTutorRequest) {
        const ip = request.socket.remoteAddress ?? 'unknown';
        const timestamp = now();
        const usage = requestsByIp.get(ip);
        if (!usage || timestamp - usage.startedAt >= rateLimitWindowMs) {
          requestsByIp.set(ip, { startedAt: timestamp, count: 1 });
        } else if (usage.count >= rateLimitMax) {
          sendJson(response, 429, {
            error: 'Trop de questions. Réessaie dans une minute.',
          });
          return;
        } else {
          usage.count++;
        }

        if (!request.headers['content-type']?.includes('application/json')) {
          sendJson(response, 415, {
            error: 'Le contenu doit être au format JSON.',
          });
          return;
        }

        const body = await readJsonBody(request);
        question = typeof body.question === 'string' ? body.question.trim() : '';
        if (!question || question.length > MAX_QUESTION_LENGTH) {
          sendJson(response, 400, {
            error: `La question doit contenir entre 1 et ${MAX_QUESTION_LENGTH} caractères.`,
          });
          return;
        }
      }

      const upstream = await requestGemma({
        apiKey: resolvedApiKey,
        model,
        question,
        fetchImpl,
      });

      if (!upstream.ok) {
        sendJson(
          response,
          isConnectionTest ? upstream.status : 502,
          { error: publicGemmaError(upstream.status) },
        );
        return;
      }

      const answer = await readGemmaAnswer(upstream);
      if (!answer) {
        sendJson(response, 502, {
          error: 'Gemma n’a pas renvoyé de réponse lisible.',
        });
        return;
      }

      if (isConnectionTest) {
        sendJson(response, 200, { status: 'ok', model, response: answer });
      } else {
        sendJson(response, 200, { response: answer });
      }
    } catch (error) {
      if (error instanceof RequestError) {
        sendJson(response, error.status, { error: error.message });
        return;
      }
      sendJson(response, 502, { error: 'Impossible de contacter Gemma pour le moment.' });
    }
  });
}

async function loadApiKey(apiKey, apiKeyFile) {
  if (typeof apiKey === 'string' && apiKey.trim()) return apiKey.trim();
  try {
    const content = await readFile(apiKeyFile, 'utf8');
    const match = content.match(/^\s*GEMINI_API_KEY\s*=\s*(.*?)\s*$/im);
    if (!match) return null;
    const value = match[1].trim().replace(/^(['"])(.*)\1$/, '$2');
    return value && value !== 'COLLE_TA_NOUVELLE_CLE_ICI' ? value : null;
  } catch {
    return null;
  }
}

async function requestGemma({ apiKey, model, question, fetchImpl }) {
  return fetchImpl(
    `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`,
    {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text:
                  'Tu es Sabi, un tuteur de mathématiques bienveillant pour les élèves de Troisième au Cameroun. ' +
                  'Réponds en français simple, avec une explication courte et des étapes claires. ' +
                  'Aide l’élève à raisonner sans le juger et ne demande jamais son nom, son adresse, son école, ' +
                  'son numéro de téléphone ni aucune autre donnée personnelle. Si la question ne porte pas sur ' +
                  'les mathématiques, réponds poliment que tu aides seulement en mathématiques. ' +
                  'Question de l’élève : ' +
                  question,
              },
            ],
          },
        ],
        generationConfig: { temperature: 0.4, maxOutputTokens: 700 },
      }),
      signal: AbortSignal.timeout(30_000),
    },
  );
}

async function readGemmaAnswer(upstream) {
  const result = await upstream.json();
  return result?.candidates?.[0]?.content?.parts
    ?.map((part) => part.text)
    .filter((text) => typeof text === 'string')
    .join('\n')
    .trim();
}

function publicGemmaError(status) {
  if (status === 400) return 'Requête refusée par Google. Vérifie le modèle Gemma configuré.';
  if (status === 401 || status === 403) {
    return 'Clé Google refusée. Révoque la clé exposée et remplace-la par une nouvelle dans .env.';
  }
  if (status === 429) return 'Limite ou quota Google atteint. Vérifie le quota Google AI Studio.';
  return 'Gemma est momentanément indisponible. Réessaie plus tard.';
}

function isAllowedOrigin(origin, allowedOrigins) {
  if (allowedOrigins.includes(origin)) return true;
  try {
    const url = new URL(origin);
    return (
      url.protocol === 'http:' &&
      ['localhost', '127.0.0.1'].includes(url.hostname)
    );
  } catch {
    return false;
  }
}

async function readJsonBody(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > MAX_BODY_BYTES) {
      throw new RequestError(413, 'La question est trop longue.');
    }
    chunks.push(chunk);
  }

  try {
    const body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
    if (body === null || typeof body !== 'object' || Array.isArray(body)) {
      throw new SyntaxError('Objet JSON attendu.');
    }
    return body;
  } catch {
    throw new RequestError(400, 'La requête JSON est invalide.');
  }
}

function sendJson(response, status, body) {
  response.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(body));
}

class RequestError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const server = createTutorServer();
  const port = Number(process.env.PORT ?? 8787);
  server.listen(port, '0.0.0.0', () => {
    console.log(`Sabi tutor proxy listening on port ${port}`);
  });
}
