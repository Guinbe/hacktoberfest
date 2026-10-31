$ErrorActionPreference = 'Stop'

$apiKeyFile = Join-Path (Split-Path $PSScriptRoot -Parent) '.env'
if (-not (Test-Path -LiteralPath $apiKeyFile)) {
    throw '.env est introuvable à la racine du projet.'
}

$content = Get-Content -LiteralPath $apiKeyFile -Raw
if ($content -notmatch '(?im)^\s*GEMINI_API_KEY\s*=\s*(?!COLLE_TA_NOUVELLE_CLE_ICI\s*$)\S') {
    throw 'Clé absente. Remplace la valeur de GEMINI_API_KEY dans .env par ta nouvelle clé.'
}

Write-Host 'Relais Sabi démarré. Garde ce terminal ouvert.'
node (Join-Path $PSScriptRoot 'server.mjs')
