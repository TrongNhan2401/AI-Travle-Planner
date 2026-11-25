#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo '[lint] Building C# with analyzers and warnings as errors...'
dotnet build AI_Travel_Planner.sln --configuration Release --warnaserror --disable-build-servers -m:1 -p:UseSharedCompilation=false
echo '[lint] Checking frontend with Oxlint...'
npm --prefix src/WebFrontend run lint
