#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v jazzy >/dev/null 2>&1; then
  echo "jazzy is not installed. Install with: gem install jazzy"
  exit 1
fi

echo "Generating API docs into docs/ ..."
jazzy --config .jazzy.yaml

echo "Done. Open docs/index.html to preview."