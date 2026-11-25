#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ ! -d tests ]] || [[ -z "$(find tests -name '*.csproj' -print -quit)" ]]; then
  echo '[tests] No test project found under tests/. Create and add one to the solution first.' >&2
  exit 1
fi

# A fresh directory prevents reports from an earlier run from hiding zero tests.
mkdir -p .artifacts/test-results
results_dir="$(mktemp -d "$PWD/.artifacts/test-results/run.XXXXXX")"
echo '[tests] Running .NET tests (no model calls)...'
dotnet test AI_Travel_Planner.sln --configuration Release --logger trx --results-directory "$results_dir" --disable-build-servers -m:1 -p:UseSharedCompilation=false
node scripts/verify-test-results.mjs "$results_dir"
