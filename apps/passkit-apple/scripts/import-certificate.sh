#!/bin/bash

# Import PassKit certificate with private key into Keychain
# This script helps diagnose and fix certificate issues

set -e

CERT_DIR="/Users/dwferrell/Dev/exchange-reserve/apps/passkit-apple/certificates"
P12_FILE="$CERT_DIR/Certificates.p12"

echo "🔐 PassKit Certificate Import Tool"
echo ""
echo "This script will help import your Pass Type ID certificate with private key."
echo ""

# Check if p12 exists
if [ ! -f "$P12_FILE" ]; then
  echo "❌ Certificates.p12 not found in $CERT_DIR"
  echo ""
  echo "Please do one of the following:"
  echo "1. Download a new certificate from Apple Developer Portal"
  echo "2. Export your existing certificate from Keychain Access"
  echo ""
  echo "To export from Keychain Access:"
  echo "  1. Open Keychain Access"
  echo "  2. Find 'Pass Type ID: pass.exchangereserve.lift'"
  echo "  3. Right-click → Export"
  echo "  4. Save as Certificates.p12"
  echo "  5. Set a strong password"
  exit 1
fi

echo "Found: $P12_FILE"
echo ""

# Check current identities
echo "Current signing identities in keychain:"
security find-identity -v -p codesigning | grep -i "pass\|exchange" || echo "  (none found for PassKit)"
echo ""

# Try to import
echo "Attempting to import certificate..."
echo ""
echo "⚠️  You'll be prompted for:"
echo "   1. The .p12 file password (the one you set when exporting)"
echo "   2. Your macOS keychain password (to allow the import)"
echo ""

read -p "Press Enter to continue..."

# Import with security command
if security import "$P12_FILE" -k ~/Library/Keychains/login.keychain-db -T /usr/bin/codesign -T /usr/bin/security; then
  echo ""
  echo "✅ Certificate imported successfully!"
  echo ""
  echo "Verifying..."
  security find-identity -v -p codesigning | grep -i "pass\|exchange" || echo "  Still not found - may need to restart Keychain Access"
  echo ""
  echo "✅ You can now build passes with: pnpm build:event"
else
  echo ""
  echo "❌ Import failed"
  echo ""
  echo "Common issues:"
  echo "1. Wrong password - The .p12 password is from when YOU exported it"
  echo "2. Certificate already exists - Check Keychain Access"
  echo "3. .p12 file is corrupted - Re-export from Apple Developer or Keychain"
  echo ""
  echo "Alternative: Generate a new certificate from Apple Developer Portal"
  echo "  https://developer.apple.com/account/resources/identifiers/list/passTypeId"
fi
