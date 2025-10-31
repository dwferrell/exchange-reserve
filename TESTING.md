# Testing the Passes

## Web Distribution (Recommended)

Visit **https://exchangereserve.netlify.app/** on your iPhone and tap "Add to Wallet"

### Expected Behavior
1. Page loads with two pass cards
2. Tap "📲 Add to Wallet" button
3. Pass opens in Wallet app (NOT Files app)
4. Top-right shows "Add" button
5. Tap "Add" to install pass

### Troubleshooting

#### "Safari cannot download this file"
**Cause**: Files not deployed to Netlify yet
**Solution**:
- Wait 1-2 minutes for auto-deploy
- Check: https://app.netlify.com/sites/exchangereserve/deploys
- Verify files exist:
  - https://exchangereserve.netlify.app/hello-world.pkpass
  - https://exchangereserve.netlify.app/event-poster.pkpass

#### Pass downloads to Files app instead of Wallet
**Cause**: Wrong MIME type or certificate issue
**Solution**:
- Check netlify.toml has: `Content-Type = "application/vnd.apple.pkpass"`
- Verify signature contains Pass Type ID cert:
  ```bash
  cd apps/passkit-apple/dist/temp/event-poster
  openssl pkcs7 -inform DER -in signature -print_certs -text | grep "Subject:"
  ```
  Should show: `Pass Type ID: pass.exchangereserve.lift`

#### Pass won't open in Wallet
**Possible causes**:
1. **Wrong certificate**: Signature must contain Pass Type ID cert (not personal cert)
2. **Expired certificate**: Check cert expiry (should be valid through Nov 2026)
3. **Missing WWDR cert**: Signature needs WWDR G4 intermediate cert
4. **Invalid JSON**: Check pass.json syntax
5. **Manifest mismatch**: SHA1 hashes must match file contents

**Verification**:
```bash
cd apps/passkit-apple
node scripts/verify-pass.js dist/event-poster.pkpass
```

---

## Alternative: Email Method

If web distribution doesn't work, email the pass:

```bash
cd apps/passkit-apple/scripts
./email-pass.sh event-poster your-email@example.com
```

Then:
1. Open email on iPhone
2. Tap .pkpass attachment
3. Tap "Add" in Wallet

---

## Alternative: AirDrop Method

```bash
cd apps/passkit-apple/scripts
./install-to-iphone.sh event-poster
# Select option 2 for AirDrop
```

---

## Verification Commands

### Check certificate in signature
```bash
cd apps/passkit-apple/dist/temp/event-poster
openssl pkcs7 -inform DER -in signature -print_certs | grep "Subject:"
```

**Expected output**:
```
Subject: CN=Apple Worldwide Developer Relations Certification Authority, OU=G4, O=Apple Inc., C=US
Subject: UID=pass.exchangereserve.lift, CN=Pass Type ID: pass.exchangereserve.lift, OU=5A984FTAG3, O=Localight Inc., C=US
```

### Verify signature
```bash
cd apps/passkit-apple/dist/temp/event-poster
openssl smime -verify -in signature -inform DER -content manifest.json -noverify
```

Should output: `Verification successful`

### Check manifest hashes
```bash
cd apps/passkit-apple
node scripts/verify-pass.js dist/event-poster.pkpass
```

All checks should pass ✅

---

## Current Status

### Latest Build
- **Signature size**: 3418 bytes ✅
- **Certificate**: Pass Type ID: pass.exchangereserve.lift ✅
- **WWDR**: G4 (correct) ✅
- **Team ID**: 5A984FTAG3 ✅
- **Pass Type ID**: pass.exchangereserve.lift ✅
- **Expiry**: November 29, 2026 ✅

### Deployment
- **GitHub**: ✅ Pushed to main
- **Netlify**: ⏳ Auto-deploying
- **URL**: https://exchangereserve.netlify.app/

---

## What to Test on iPhone

Once the pass installs successfully:

### 1. Basic Functionality
- [ ] Pass appears in Wallet
- [ ] Logo/icon displays correctly
- [ ] Colors match (blue background, white text)
- [ ] QR code is scannable

### 2. Pass Details
- [ ] Front shows event name, holder status, venue, date
- [ ] Back shows about, venue details, contact info
- [ ] Tap ⓘ (info) button to see back

### 3. Geofencing (Event Poster only)
- [ ] Walk to Bell Tower Hall (39.4143, -77.4105)
- [ ] Should get notification within 100 meters
- [ ] Notification text: "Welcome to Bell Tower Hall! Your Impact Briefing starts soon."

### 4. Time-based Notifications (Event Poster only)
- [ ] On Nov 15, 2025 at 5:00 PM EST (1 hour before event)
- [ ] Pass should appear on lock screen
- [ ] Siri may suggest event

### 5. Apple Maps Integration
- [ ] Tap venue name
- [ ] Should open in Maps with directions

### 6. Sharing
- [ ] Hold pass, tap share icon
- [ ] Can share via AirDrop, Messages, etc.

---

## Common Issues

### "This pass cannot be added to Wallet"
- Certificate is wrong or expired
- Rebuild passes: `pnpm build:passes`
- Verify certificate chain

### Pass shows but fields are blank
- pass.json has invalid values
- Check for null/undefined fields
- Verify JSON syntax

### Pass updates don't appear
- Clear cache: Settings > Wallet & Apple Pay > [Pass] > Remove
- Re-add pass from website

### Geofencing not working
- Enable Location Services: Settings > Privacy > Location Services > Wallet
- Must be on physical device (not simulator)
- Test within 100 meters of venue

---

## Next Steps After Successful Test

Once you confirm passes work on iPhone:

1. **Phase 2**: Implement PassKit Web Service API
   - Device registration endpoints
   - Push notifications via APNs
   - Pass update mechanism

2. **Phase 3**: Build Next.js website
   - Homepage
   - Pass distribution page
   - QR verification endpoint

3. **Phase 4**: Supabase backend
   - Database schema
   - Authentication
   - Pass management

4. **Phase 5**: Google Wallet integration
   - Mirror Apple pass structure
   - JWT signing for Google Pay API

---

**Last Updated**: October 30, 2025
