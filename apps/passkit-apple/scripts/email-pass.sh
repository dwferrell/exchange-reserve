#!/bin/bash

# Email a pass to yourself
# Usage: ./email-pass.sh <pass-name> <email>

PASS_NAME="${1:-event-poster}"
EMAIL="${2}"
PASS_FILE="/Users/dwferrell/Dev/exchange-reserve/apps/passkit-apple/dist/${PASS_NAME}.pkpass"

if [ ! -f "$PASS_FILE" ]; then
  echo "❌ Pass file not found: $PASS_FILE"
  exit 1
fi

if [ -z "$EMAIL" ]; then
  read -p "Enter your email address: " EMAIL
fi

echo "📧 Opening Mail with ${PASS_NAME}.pkpass attached..."
echo "   Sending to: $EMAIL"

# Create email with proper attachment
osascript -e "
tell application \"Mail\"
    set newMessage to make new outgoing message with properties {subject:\"Your LIFT Certificate\", visible:true}
    tell newMessage
        set content to \"Your LIFT Certificate is attached.

Tap the attachment on your iPhone to add it to Apple Wallet.

This pass includes:
• QR code for verification
• Geofencing (get notifications near venue)
• Time-based reminders
• Apple Maps & Calendar integration

—
Exchange Reserve / LocalFund
https://exchangereserve.org\"
        make new to recipient at end of to recipients with properties {address:\"$EMAIL\"}
        make new attachment with properties {file name:POSIX file \"$PASS_FILE\"}
    end tell
    activate
end tell
"

echo "✅ Mail opened"
echo ""
echo "To install on iPhone:"
echo "1. Send the email"
echo "2. Open email on iPhone"
echo "3. Tap the .pkpass attachment"
echo "4. Tap 'Add' in the top-right corner"
