#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo '[format] Checking C# formatting (no files will be changed)...'
dotnet format whitespace src --folder --verify-no-changes --verbosity minimal
if [[ -d tests ]]; then
  dotnet format whitespace tests --folder --verify-no-changes --verbosity minimal
fi
echo '[format] Checking frontend formatting...'
npm --prefix src/WebFrontend run format:check
