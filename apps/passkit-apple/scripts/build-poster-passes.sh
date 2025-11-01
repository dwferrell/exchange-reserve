#!/bin/bash
# Build all poster-style event ticket passes following the iOS Event Ticket Guide

set -e

echo "🎫 Building iOS 18+ Poster Event Ticket Passes"
echo "================================================"
echo ""

# Check if certificates exist
if [ ! -f "certificates/signerCert-new.pem" ] || [ ! -f "certificates/signerKey.pem" ]; then
    echo "❌ Error: Certificates not found in certificates/"
    echo ""
    echo "Required files:"
    echo "  - signerCert-new.pem"
    echo "  - signerKey.pem"
    echo "  - apple_wwdr_g4.pem"
    echo ""
    echo "Please set up your certificates before building passes."
    echo "See README.md for certificate setup instructions."
    exit 1
fi

# Array of poster-style templates
POSTER_TEMPLATES=(
    "poster-event-demo"
    "poster-multi-event"
    "event-poster-ios18"
)

SUCCESS_COUNT=0
FAIL_COUNT=0

# Build each template
for template in "${POSTER_TEMPLATES[@]}"; do
    echo "📦 Building: $template"

    if node scripts/build-pass.js "$template"; then
        echo "✅ Successfully built $template"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

        # Copy to public directory for hosting
        cp "dist/${template}.pkpass" "../../public/${template}.pkpass"
        echo "📋 Copied to public/${template}.pkpass"
    else
        echo "❌ Failed to build $template"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    echo ""
done

# Summary
echo "================================================"
echo "🏁 Build Summary"
echo "================================================"
echo "✅ Successful: $SUCCESS_COUNT"
echo "❌ Failed: $FAIL_COUNT"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "🎉 Built passes are ready in public/ directory"
    echo ""
    echo "📱 To test on iPhone:"
    echo "   1. Deploy to Netlify (git push)"
    echo "   2. Visit https://exchangereserve.netlify.app"
    echo "   3. Tap 'Add to Wallet' on any poster pass"
    echo ""
    echo "👀 What to look for in iOS 18+:"
    echo "   - Maps tile below the pass"
    echo "   - Event Guide button with venue details"
    echo "   - Tap-to-call phone number"
    echo "   - Get Directions button"
    echo "   - (Multi-event) Swipe between event days"
fi

exit 0
