# Poster Event Ticket Passes (iOS 18+)

This directory contains poster-style event ticket templates that demonstrate the features described in the [iOS Event Ticket Guide](../../IOS_EVENT_TICKET_GUIDE.md).

## What Makes These Different?

These passes use the **Poster Event Ticket layout** introduced in iOS 18 (WWDC 2024), which enables:
- 📍 Interactive Maps tile showing venue location
- 🗺️ Event Guide button with directions, weather, and transit
- ☎️ Tap-to-call venue phone number
- 📅 Multi-event support (festivals, season passes)
- ✨ Enhanced visual layout with large imagery

## Key Difference from Standard Event Tickets

**Standard Event Ticket** (`event-poster-v2`):
```json
"eventTicket": {
  "primaryFields": [...]
}
```
- Shows basic pass layout
- Has semantics but no poster features
- Maps/Event Guide don't appear below pass

**Poster Event Ticket** (`poster-event-demo`, `poster-multi-event`):
```json
"eventTicket": {
  "preferredStyle": "PKPosterEventTicketStylePoster",
  "primaryFields": [...]
}
```
- Shows enhanced poster layout
- Maps tile appears below pass
- Event Guide button with venue details
- Tap-to-call, directions, weather

## Templates

### 1. `poster-event-demo/` — Single Event with Poster Layout

A single-day event demonstrating the core poster features:
- ✅ `preferredStyle: "PKPosterEventTicketStylePoster"`
- ✅ Complete semantics (venue, location, dates, performers)
- ✅ Distinction between semantic tags (features) and fields (display)
- ✅ Geofencing with relevant notifications
- ✅ 5 backFields (iOS 26 compatibility)

**Serial:** `POSTER-DEMO-2025-001`

**Use case:** Single event like a conference, concert, or Impact Briefing

### 2. `poster-multi-event/` — Multi-Event Series with Poster Layout

A 3-day workshop series demonstrating multi-event features:
- ✅ `preferredStyle: "PKPosterEventTicketStylePoster"`
- ✅ `upcomingPassInformation` array for multiple events
- ✅ Each event day has its own semantics, URLs, and detail screen
- ✅ Users can swipe between event days in Wallet
- ✅ Automatic date switching based on time

**Serial:** `SERIES-2025-001`

**Use case:** Festivals, conference series, season passes, multi-day events

### 3. `event-poster-ios18/` — Comprehensive Demonstration

Full-featured poster ticket with all semantic tags:
- ✅ Seats, admission level, confirmation numbers
- ✅ Organizer information (name, phone, email)
- ✅ Additional info fields (WiFi, check-in instructions)
- ✅ Complete venue details including entrance location

**Serial:** `LIFT-2025-iOS18-DEMO`

**Use case:** Reference implementation showing all available options

## Building the Passes

### Prerequisites

1. **Certificates** in `certificates/` directory:
   - `signerCert-new.pem` — Your Pass Type ID certificate
   - `signerKey.pem` — Private key
   - `apple_wwdr_g4.pem` — Apple WWDR G4 intermediate certificate

2. **Environment variables** in `apps/passkit-apple/.env.local`:
   ```bash
   APPLE_TEAM_ID=5A984FTAG3
   PASS_TYPE_IDENTIFIER=pass.exchangereserve.lift
   ORGANIZATION_NAME=LocalFund
   ```

### Build All Poster Passes

```bash
cd apps/passkit-apple
./scripts/build-poster-passes.sh
```

This will:
1. Build all three poster-style templates
2. Copy them to `public/` for hosting
3. Show a summary of successful/failed builds

### Build Individual Pass

```bash
cd apps/passkit-apple
node scripts/build-pass.js poster-event-demo
```

Replace `poster-event-demo` with any template name.

### Copy to Public for Hosting

```bash
cp apps/passkit-apple/dist/poster-event-demo.pkpass public/
```

## Testing on iPhone

1. **Deploy to Netlify:**
   ```bash
   git add public/*.pkpass
   git commit -m "Add poster event ticket passes"
   git push
   ```

2. **Open on iPhone:**
   - Visit https://exchangereserve.netlify.app
   - Tap "Add to Wallet" on poster pass
   - Pass should open in Wallet app

3. **Look for Enhanced Features (iOS 18+):**
   - ✅ Large poster-style visual layout
   - ✅ Maps tile below the pass with venue location
   - ✅ "Event Guide" button (tap to see venue details)
   - ✅ Tap-to-call phone number
   - ✅ "Get Directions" button opening Apple Maps
   - ✅ (Multi-event) Swipe between event days

4. **Test Geofencing:**
   - Enable Location Services for Wallet
   - Visit the venue location (Bell Tower Hall, Frederick MD)
   - Pass should appear on lock screen when within 100-150m

## Comparison: Standard vs Poster

| Feature | Standard Event Ticket | Poster Event Ticket |
|---------|----------------------|---------------------|
| Visual layout | Standard card | Large poster-style |
| Maps tile | ❌ No | ✅ Yes |
| Event Guide | ❌ No | ✅ Yes |
| Tap-to-call | ❌ No | ✅ Yes |
| Directions | ❌ No | ✅ Yes |
| Multi-event UI | ❌ No | ✅ Yes (upcomingPassInformation) |
| Weather | ❌ No | ✅ Yes (in Event Guide) |
| Certificate required | Standard Pass Type ID | Enhanced Pass (NFC-entitled) |

## Troubleshooting

### Maps Tile / Event Guide Not Showing

**Problem:** Pass installs but doesn't show Maps or Event Guide below it.

**Fixes:**
1. ✅ Verify `preferredStyle: "PKPosterEventTicketStylePoster"` is present
2. ✅ Check semantics has `venueName`, `venueLocation`, `eventStartDate`
3. ✅ Ensure you're testing on iOS 18 or later
4. ✅ Confirm pass was signed with Enhanced Pass (NFC-entitled) certificate

### Pass Won't Install

**Problem:** "Unable to add pass" error when trying to install.

**Fixes:**
1. ✅ Validate with [PKPASS Validator](https://pkpassvalidator.com/)
2. ✅ Check certificate hasn't expired
3. ✅ Verify signature is valid (not empty)
4. ✅ Ensure manifest.json includes all files
5. ✅ Confirm Team ID matches Apple Developer account

### Semantics Not Displaying as Text

**This is expected!** Semantic tags power features, not display.

**Solution:** Put visible text in `backFields` or `additionalInfoFields`:
```json
"semantics": {
  "venueName": "Bell Tower Hall"  // Powers Maps integration
},
"eventTicket": {
  "backFields": [
    {
      "key": "venue-info",
      "label": "Venue",
      "value": "Bell Tower Hall\nFrederick, MD"  // Shows on pass
    }
  ]
}
```

## Resources

- [iOS Event Ticket Guide](../../IOS_EVENT_TICKET_GUIDE.md) — Comprehensive guide
- [Web Guide](../../public/ios-event-ticket-guide.html) — Web-friendly version
- [Apple PassKit Documentation](https://developer.apple.com/documentation/walletpasses)
- [WWDC 2024 - What's New in Wallet](https://developer.apple.com/videos/play/wwdc2024/10106/)
- [WWDC 2025 - Multi-Event Passes](https://developer.apple.com/videos/play/wwdc2025/10118/)

## Next Steps

1. ✅ Set up Enhanced Pass certificate (NFC-entitled)
2. ✅ Build poster passes with `./scripts/build-poster-passes.sh`
3. ✅ Test on iOS 18+ device
4. ✅ Update `public/index.html` to link to poster examples
5. ✅ Deploy to Netlify

---

**Note:** These templates follow the best practices from the iOS Event Ticket Guide and demonstrate all key features of the poster layout introduced at WWDC 2024.
