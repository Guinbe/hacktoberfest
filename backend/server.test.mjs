import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

import { createTutorServer } from './server.mjs';

const servers = new Set();
const temporaryDirectories = new Set();

afterEach(async () => {
  await Promise.all(
    [...servers].map(
      (server) =>
        new Promise((resolve, reject) => {
          server.close((error) => {
            if (error) reject(error);
            else resolve();
          });
        }),
    ),
  );
  servers.clear();
  await Promise.all(
    [...temporaryDirectories].map((directory) =>
      rm(directory, { recursive: true, force: true }),
    ),
  );
  temporaryDirectories.clear();
});

async function startServer(options) {
  const server = createTutorServer(options);
  servers.add(server);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  return `http://127.0.0.1:${server.address().port}`;
}

test('health endpoint does not expose configuration', async () => {
  const baseUrl = await startServer({ apiKey: 'server-only-secret' });

  const response = await fetch(`${baseUrl}/health`);

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
});

test('reads the Google API key from the root .env file', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'sabi-api-'));
  temporaryDirectories.add(directory);
  const apiKeyFile = join(directory, '.env');
  await writeFile(apiKeyFile, 'GEMINI_API_KEY=test-key-from-file\n', 'utf8');
  let sentKey;
  const baseUrl = await startServer({
    apiKey: '',
    apiKeyFile,
    fetchImpl: async (_url, options) => {
      sentKey = options.headers['x-goog-api-key'];
      return Response.json({
        candidates: [{ content: { parts: [{ text: 'Explication de test.' }] } }],
      });
    },
  });

  test('does not use the example placeholder as an API key', async () => {
    const directory = await mkdtemp(join(tmpdir(), 'sabi-placeholder-'));
    temporaryDirectories.add(directory);
    const baseUrl = await startServer({
      apiKey: '',
      apiKeyFile: join(directory, '.env'),
    });
    await writeFile(
      join(directory, '.env'),
      'GEMINI_API_KEY=COLLE_TA_NOUVELLE_CLE_ICI\n',
      'utf8',
    );

    const response = await fetch(`${baseUrl}/api/tutor`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ question: 'Aide-moi avec Thalès.' }),
    });

    assert.equal(response.status, 503);
  });

  const response = await fetch(`${baseUrl}/api/tutor`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: 'Aide-moi avec Thalès.' }),
  });

  assert.equal(response.status, 200);
  assert.equal(sentKey, 'test-key-from-file');
});

test('tests Google connectivity with a minimal prompt', async () => {
  let sentPrompt;
  const baseUrl = await startServer({
    apiKey: 'server-only-secret',
    fetchImpl: async (_url, options) => {
      sentPrompt = JSON.parse(options.body).contents[0].parts[0].text;
      return Response.json({
        candidates: [{ content: { parts: [{ text: 'Sabi est connectée.' }] } }],
      });
    },
  });

  const response = await fetch(`${baseUrl}/api/test`);

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    status: 'ok',
    model: 'gemma-3-27b-it',
    response: 'Sabi est connectée.',
  });
  assert.match(sentPrompt, /Réponds exactement/);
});

test('forwards a math question to Gemma with the key in a header', async () => {
  let upstreamRequest;
  const baseUrl = await startServer({
    apiKey: 'server-only-secret',
    fetchImpl: async (url, options) => {
      upstreamRequest = { url, options };
      return Response.json({
        candidates: [
          { content: { parts: [{ text: 'On avance étape par étape.' }] } },
        ],
      });
    },
  });

  const response = await fetch(`${baseUrl}/api/tutor`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: 'Comment factoriser x² - 25 ?' }),
  });

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    response: 'On avance étape par étape.',
  });
  assert.match(upstreamRequest.url, /gemma-3-27b-it:generateContent$/);
  assert.equal(
    upstreamRequest.options.headers['x-goog-api-key'],
    'server-only-secret',
  );
  assert.equal(
    upstreamRequest.options.body.includes('server-only-secret'),
    false,
  );
  assert.match(upstreamRequest.options.body, /Comment factoriser x² - 25/);
});

test('rejects invalid questions before calling Gemma', async () => {
  let upstreamCalled = false;
  const baseUrl = await startServer({
    apiKey: 'server-only-secret',
    fetchImpl: async () => {
      upstreamCalled = true;
      return Response.json({});
    },
  });

  const response = await fetch(`${baseUrl}/api/tutor`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: '  ' }),
  });

  assert.equal(response.status, 400);
  assert.equal(upstreamCalled, false);
});

test('requires a server-side Gemini API key', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'sabi-no-api-key-'));
  temporaryDirectories.add(directory);
  const baseUrl = await startServer({
    apiKey: '',
    apiKeyFile: join(directory, 'missing-api.txt'),
  });

  const response = await fetch(`${baseUrl}/api/tutor`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ question: 'Aide-moi avec Thalès.' }),
  });

  assert.equal(response.status, 503);
});

test('limits request rates per client', async () => {
  const baseUrl = await startServer({
    apiKey: 'server-only-secret',
    rateLimitMax: 1,
    fetchImpl: async () =>
      Response.json({
        candidates: [{ content: { parts: [{ text: 'Réponse.' }] } }],
      }),
  });
  const request = () =>
    fetch(`${baseUrl}/api/tutor`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ question: 'Aide-moi.' }),
    });

  assert.equal((await request()).status, 200);
  assert.equal((await request()).status, 429);
});
