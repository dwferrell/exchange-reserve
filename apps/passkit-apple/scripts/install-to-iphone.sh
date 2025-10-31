#!/bin/bash

# Install pass to iPhone via different methods
# Usage: ./install-to-iphone.sh <pass-name>

set -e

PASS_NAME="${1:-event-poster}"
PASS_FILE="/Users/dwferrell/Dev/exchange-reserve/apps/passkit-apple/dist/${PASS_NAME}.pkpass"

if [ ! -f "$PASS_FILE" ]; then
  echo "❌ Pass file not found: $PASS_FILE"
  echo "Usage: $0 <pass-name>"
  echo "Example: $0 event-poster"
  exit 1
fi

echo "📱 Installing ${PASS_NAME}.pkpass to iPhone"
echo ""
echo "Choose a method:"
echo "1) Open with macOS (will prompt to add to Wallet)"
echo "2) AirDrop (select this, then choose iPhone)"
echo "3) Share via Mail (will open Mail.app)"
echo "4) Copy to local web server for QR code scanning"
echo ""
read -p "Select method (1-4): " method

case $method in
  1)
    echo "Opening pass..."
    open "$PASS_FILE"
    echo "✅ Pass should open in Wallet preview"
    echo "   If you have iPhone nearby, you can use Handoff to transfer"
    ;;
  2)
    echo "Opening Finder for AirDrop..."
    open -R "$PASS_FILE"
    echo ""
    echo "✅ Finder opened with file selected"
    echo "   Right-click the file → Share → AirDrop → Select iPhone"
    ;;
  3)
    echo "Opening Mail..."
    open "mailto:?subject=Your%20LIFT%20Certificate&body=Add%20this%20pass%20to%20Apple%20Wallet" -a Mail --attach "$PASS_FILE"
    echo "✅ Mail opened with pass attached"
    echo "   Send to yourself and open on iPhone"
    ;;
  4)
    echo "Starting local web server..."
    TEMP_DIR=$(mktemp -d)
    cp "$PASS_FILE" "$TEMP_DIR/"
    cd "$TEMP_DIR"

    echo "Starting Python HTTP server on port 8000..."
    echo ""
    echo "🌐 Server running at:"
    echo "   http://$(ipconfig getifaddr en0):8000/${PASS_NAME}.pkpass"
    echo ""
    echo "📲 Scan this URL with iPhone Camera app:"
    echo ""

    # Generate QR code if qrencode is available
    if command -v qrencode &> /dev/null; then
      qrencode -t UTF8 "http://$(ipconfig getifaddr en0):8000/${PASS_NAME}.pkpass"
    else
      echo "   Visit: https://qr.io/ and enter the URL above"
    fi

    echo ""
    echo "Press Ctrl+C to stop server"
    python3 -m http.server 8000
    ;;
  *)
    echo "❌ Invalid selection"
    exit 1
    ;;
esac
