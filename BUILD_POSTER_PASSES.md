# Building Poster Event Ticket Passes

## Quick Start

I've created 3 new poster-style event ticket templates that implement the iOS 18+ features from the guide:

1. **`poster-event-demo`** — Single event with full poster layout
2. **`poster-multi-event`** — 3-day workshop series with multi-event support
3. **`event-poster-ios18`** — Comprehensive reference implementation

## What's Different from event-poster-v2?

The existing `event-poster-v2` has semantics but is **missing the key field** that enables poster features:

```json
// ❌ event-poster-v2 (missing poster style)
"eventTicket": {
  "primaryFields": [...]
}

// ✅ New poster passes (with poster style)
"eventTicket": {
  "preferredStyle": "PKPosterEventTicketStylePoster",  // <-- This enables poster features!
  "primaryFields": [...]
}
```

Without `preferredStyle`, iOS won't show:
- Maps tile below the pass
- Event Guide button
- Tap-to-call venue phone
- Enhanced visual layout

## Building the Passes

### Step 1: Ensure Certificates Are Set Up

Check if you have certificates in `apps/passkit-apple/certificates/`:
```bash
ls -la apps/passkit-apple/certificates/
```

You should see:
- `signerCert-new.pem` — Your Pass Type ID certificate
- `signerKey.pem` — Private key
- `apple_wwdr_g4.pem` — Apple WWDR G4 intermediate certificate

If you don't have these, see the main README for certificate setup instructions.

### Step 2: Build All Poster Passes

```bash
cd apps/passkit-apple
pnpm build:poster
```

This builds all 3 poster templates and copies them to `public/` for hosting.

**Or build individually:**
```bash
pnpm build:poster-demo      # Single event
pnpm build:poster-multi     # Multi-event series
pnpm build:poster-ios18     # Comprehensive reference
```

### Step 3: Deploy to Netlify

```bash
git add public/*.pkpass apps/passkit-apple/templates/
git commit -m "Add poster-style event ticket passes"
git push
```

Netlify will auto-deploy and the passes will be available at:
- `https://exchangereserve.netlify.app/poster-event-demo.pkpass`
- `https://exchangereserve.netlify.app/poster-multi-event.pkpass`
- `https://exchangereserve.netlify.app/event-poster-ios18.pkpass`

### Step 4: Update index.html

Add links to the new poster passes in `public/index.html` so users can tap to add them to Wallet.

I can help with this once the passes are built!

## What to Test on iPhone (iOS 18+)

Once deployed, test each pass:

### poster-event-demo (Single Event)
- ✅ Pass installs successfully
- ✅ Large poster-style visual layout
- ✅ Maps tile appears below pass showing Bell Tower Hall
- ✅ Tap "Event Guide" button
  - Should show venue name, address, phone (tap-to-call)
  - "Get Directions" button opens Apple Maps
  - May show weather, transit options
- ✅ Pass appears on lock screen when near venue (geofencing)
- ✅ Pass appears on lock screen 1 hour before event (relevantDate)

### poster-multi-event (3-Day Series)
- ✅ All single event features above, plus:
- ✅ Swipe between Day 1, Day 2, Day 3 in Wallet
- ✅ Each day shows different speakers/performers
- ✅ Each day has its own event info URL
- ✅ Automatic day switching based on date/time

### event-poster-ios18 (Reference Implementation)
- ✅ All poster features
- ✅ Comprehensive semantics (seats, organizer, admission level)
- ✅ Additional info fields (WiFi, check-in)
- ✅ Full venue details including entrance location

## Troubleshooting

### "Certificates not found" Error

**Problem:** Build script can't find certificate files.

**Fix:**
```bash
# Check certificate location
ls -la apps/passkit-apple/certificates/

# Make sure you have:
# - signerCert-new.pem
# - signerKey.pem
# - apple_wwdr_g4.pem
```

If missing, extract from your Pass Type ID certificate (see main README).

### Maps Tile / Event Guide Not Showing

**Problem:** Pass installs but no Maps or Event Guide appears.

**Likely causes:**
1. ❌ Testing on iOS 17 or earlier (need iOS 18+)
2. ❌ Pass not signed with Enhanced Pass (NFC-entitled) certificate
3. ❌ Semantics missing required fields

**Fix:** Verify the pass has:
```json
"eventTicket": {
  "preferredStyle": "PKPosterEventTicketStylePoster"  // Required!
},
"semantics": {
  "venueName": "...",        // Required
  "venueLocation": {...},    // Required
  "eventStartDate": "..."    // Required
}
```

### Pass Won't Install

**Problem:** "Unable to add pass" error.

**Fix:**
1. Validate with [PKPASS Validator](https://pkpassvalidator.com/)
2. Check signature is valid (not 0 bytes)
3. Verify Team ID matches: `5A984FTAG3`
4. Ensure certificate hasn't expired

## Files Created

### Templates
- `apps/passkit-apple/templates/poster-event-demo/pass.json`
- `apps/passkit-apple/templates/poster-multi-event/pass.json`
- `apps/passkit-apple/templates/event-poster-ios18/pass.json`

### Scripts
- `apps/passkit-apple/scripts/build-poster-passes.sh` — Build all poster passes
- `apps/passkit-apple/package.json` — Added npm scripts

### Documentation
- `apps/passkit-apple/POSTER_PASSES.md` — Detailed poster pass documentation
- `IOS_EVENT_TICKET_GUIDE.md` — Comprehensive guide (already created)
- `public/ios-event-ticket-guide.html` — Web guide (already created)

## Next Steps

1. ✅ Templates created and ready to build
2. 🔲 **You:** Set up Enhanced Pass certificate (if not already done)
3. 🔲 **You:** Run `pnpm build:poster` to build passes
4. 🔲 **You:** Commit and push to deploy
5. 🔲 **Me:** Update `public/index.html` with links to poster passes
6. 🔲 **You:** Test on iPhone iOS 18+

## Questions?

- See `apps/passkit-apple/POSTER_PASSES.md` for detailed documentation
- See `IOS_EVENT_TICKET_GUIDE.md` for comprehensive guide
- See `apps/passkit-apple/README.md` for general PassKit setup

---

**Ready to build?** Just run:
```bash
cd apps/passkit-apple
pnpm build:poster
```
