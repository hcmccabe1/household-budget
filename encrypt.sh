#!/bin/bash
# Encrypt data.json → data.json.enc for pushing to GitHub Pages.
# Usage: bash encrypt.sh [password]
# If no password given, reads from .password file.
set -euo pipefail

cd "$(dirname "$0")"

if [ "${1:-}" != "" ]; then
  PASSWORD="$1"
elif [ -f .password ]; then
  PASSWORD=$(cat .password)
else
  echo "Error: provide password as argument or create .password file"
  exit 1
fi

if [ ! -f data.json ]; then
  echo "Error: data.json not found (run build.py first)"
  exit 1
fi

# AES-256-CBC + PBKDF2-SHA256 (210,000 iterations) + salt, base64 output
openssl enc -aes-256-cbc -pbkdf2 -iter 210000 -md sha256 -salt \
  -in data.json -out data.json.enc -base64 \
  -pass "pass:${PASSWORD}"

BYTES=$(wc -c < data.json.enc | tr -d ' ')
echo "✓ Encrypted data.json → data.json.enc (${BYTES} bytes, base64)"
