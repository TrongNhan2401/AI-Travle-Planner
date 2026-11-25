#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo '[types] Compiling C#...'
dotnet build AI_Travel_Planner.sln --configuration Release --disable-build-servers -m:1 -p:UseSharedCompilation=false
echo '[types] Checking TypeScript without bundling...'
npm --prefix src/WebFrontend run typecheck
