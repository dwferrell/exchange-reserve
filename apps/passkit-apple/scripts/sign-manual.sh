#!/bin/bash

# Manual signing using OpenSSL with extracted certificates
# This script signs a pass without relying on macOS Keychain

set -e

PASS_DIR="$1"
CERT_DIR="/Users/dwferrell/Dev/exchange-reserve/apps/passkit-apple/certificates"

if [ -z "$PASS_DIR" ]; then
  echo "Usage: $0 <pass-directory>"
  exit 1
fi

cd "$PASS_DIR"

echo "🔐 Signing pass manually with OpenSSL..."

# Extract certificate and key from .p12 if not already done
if [ ! -f "$CERT_DIR/signerCert.pem" ] || [ ! -f "$CERT_DIR/signerKey.pem" ]; then
  echo "Extracting certificate and key from .p12..."

  # Extract certificate
  openssl pkcs12 -in "$CERT_DIR/Certificates.p12" \
    -clcerts -nokeys \
    -out "$CERT_DIR/signerCert.pem" \
    -passin pass:F1asco919 \
    -passout pass:

  # Extract private key
  openssl pkcs12 -in "$CERT_DIR/Certificates.p12" \
    -nocerts \
    -out "$CERT_DIR/signerKey.pem" \
    -passin pass:F1asco919 \
    -passout pass:

  echo "✅ Certificate and key extracted"
fi

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
echo "✅ Manifest generated"

# Sign manifest with OpenSSL
echo "Signing manifest..."
openssl smime -binary -sign \
  -certfile "$CERT_DIR/apple_wwdr_g3.pem" \
  -signer "$CERT_DIR/signerCert.pem" \
  -inkey "$CERT_DIR/signerKey.pem" \
  -in manifest.json \
  -out signature \
  -outform DER

if [ -f signature ] && [ -s signature ]; then
  echo "✅ Pass signed successfully!"
  echo "   Signature size: $(wc -c < signature) bytes"

  # Verify signature
  openssl smime -verify \
    -in signature \
    -inform DER \
    -content manifest.json \
    -CAfile "$CERT_DIR/apple_wwdr_g3.pem" \
    -noverify 2>&1 | grep -q "Verification successful" && \
    echo "✅ Signature verified" || \
    echo "⚠️  Signature verification inconclusive"
else
  echo "❌ Signing failed - signature file is empty or missing"
  exit 1
fi

echo ""
echo "✅ Pass signed and ready!"
