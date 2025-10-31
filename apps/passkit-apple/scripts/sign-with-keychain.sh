#!/bin/bash

# Sign a pass using macOS keychain
# Usage: ./sign-with-keychain.sh <pass-directory>

set -e

PASS_DIR="$1"

if [ -z "$PASS_DIR" ]; then
  echo "Usage: $0 <pass-directory>"
  exit 1
fi

if [ ! -d "$PASS_DIR" ]; then
  echo "Error: Directory $PASS_DIR does not exist"
  exit 1
fi

cd "$PASS_DIR"

# Generate manifest
echo "Generating manifest.json..."
manifest="{}"
for file in *; do
  if [ "$file" != "manifest.json" ] && [ "$file" != "signature" ]; then
    hash=$(openssl sha1 -binary "$file" | xxd -p)
    manifest=$(echo "$manifest" | jq --arg file "$file" --arg hash "$hash" '. + {($file): $hash}')
  fi
done
echo "$manifest" | jq . > manifest.json

echo "Manifest generated:"
cat manifest.json

# Sign manifest using macOS keychain
echo "Signing manifest..."
security cms -S \
  -N "Pass Type ID: pass.exchangereserve.lift" \
  -i manifest.json \
  -o signature \
  -k ~/Library/Keychains/login.keychain-db

if [ -f signature ] && [ -s signature ]; then
  echo "✅ Pass signed successfully!"
  echo "Signature file size: $(wc -c < signature) bytes"
else
  echo "❌ Signing failed - signature file is empty or missing"
  exit 1
fi

# Create .pkpass file
cd ..
PASS_NAME=$(basename "$PASS_DIR")
echo "Creating $PASS_NAME.pkpass..."
cd "$PASS_DIR"
zip -qr "../$PASS_NAME.pkpass" *

echo "✅ Pass created: $PASS_NAME.pkpass"
ls -lh "../$PASS_NAME.pkpass"
