# Apple Wallet PassKit Generator

Generate Apple Wallet passes for Exchange Reserve's LIFT certificates.

## Features

- ✅ Hello World Pass (baseline validation)
- ✅ Event Poster Pass (rich layout with geofencing & notifications)
- 🔐 Secure signing using macOS Keychain
- 📱 Ready for AirDrop to iPhone

## Prerequisites

- macOS with Xcode Command Line Tools
- Node.js >= 18
- Apple Developer account
- Pass Type ID certificate installed in macOS Keychain
- Team ID: `5A984FTAG3`
- Pass Type Identifier: `pass.exchangereserve.lift`

## Setup

1. Install dependencies:
   ```bash
   pnpm install
   ```

2. Ensure certificates are in `certificates/`:
   - `Certificates.p12` (if available)
   - `apple_wwdr_g3.pem` (Apple WWDR G3)
   - `pass.cer` (Pass Type ID certificate)
   - `signerCert.pem` (generated from pass.cer)

3. Configure environment variables in `.env.local`:
   ```bash
   PASSKIT_CERT_PASSWORD=your_password
   APPLE_TEAM_ID=5A984FTAG3
   PASS_TYPE_IDENTIFIER=pass.exchangereserve.lift
   ORGANIZATION_NAME=LocalFund
   ```

## Usage

### Build Passes

```bash
# Build Hello World pass
pnpm build:hello

# Build Event Poster pass
pnpm build:event

# Build all passes
pnpm build
```

### Pass Templates

#### 1. Hello World Pass
Location: `templates/hello-world/pass.json`

A minimal pass to validate:
- Certificate chain
- Signature verification
- Basic PassKit functionality

#### 2. Event Poster Pass
Location: `templates/event-poster/pass.json`

Advanced features:
- **Event Details**: Impact Briefing at Bell Tower Hall, Frederick MD
- **Geofencing**: Triggers notification when user arrives (within 100m)
- **Time-based Notifications**: Shows on lock screen 1 hour before event (`relevantDate`)
- **Rich Layout**: Primary, secondary, auxiliary, and back fields
- **QR Verification**: Links to `https://exchangereserve.org/verify/LIFT-2025-AB12`
- **Semantics**: Apple Maps & Calendar integration
- **Web Service**: Ready for PassKit Web Service updates

### Testing on iPhone

**Method 1: AirDrop (Recommended)**
1. Build pass: `pnpm build:event`
2. Open Finder, navigate to `dist/`
3. Right-click `event-poster.pkpass`
4. Select "Share" > "AirDrop"
5. Select your iPhone
6. Tap "Add" in Wallet app on iPhone

**Method 2: Email**
1. Attach `.pkpass` file to email
2. Send to yourself
3. Open email on iPhone
4. Tap attachment
5. Tap "Add" in Wallet app

**Method 3: Open Directly (macOS)**
```bash
open dist/event-poster.pkpass
```

## Pass Structure

```
.pkpass (zip archive)
├── pass.json           # Pass definition
├── manifest.json       # SHA1 hashes of all files
├── signature          # PKCS7 signature of manifest
├── icon.png           # 29x29 pt
├── icon@2x.png        # 58x58 pt
├── icon@3x.png        # 87x87 pt
├── logo.png           # 160x50 pt
├── logo@2x.png        # 320x100 pt
├── logo@3x.png        # 480x150 pt
├── background.png     # 180x220 pt (for event poster)
├── background@2x.png  # 360x440 pt
└── background@3x.png  # 1080x1320 pt
```

## PassKit Web Service

The Event Poster pass includes web service integration:

```json
{
  "webServiceURL": "https://exchangereserve.org/api/passes",
  "authenticationToken": "vxwxd7J8AlNNFPS8k0a0FfUFtq0ewzFdc"
}
```

### Required Endpoints

Implement these endpoints to enable pass updates and push notifications:

1. **Register Device**
   - `POST /v1/devices/:deviceID/registrations/:passTypeID/:serialNumber`
   - Called when user adds pass to Wallet

2. **Unregister Device**
   - `DELETE /v1/devices/:deviceID/registrations/:passTypeID/:serialNumber`
   - Called when user removes pass

3. **Get Pass Updates**
   - `GET /v1/passes/:passTypeID/:serialNumber`
   - Returns updated pass if available
   - Include `Last-Modified` header

4. **Get Serial Numbers**
   - `GET /v1/devices/:deviceID/registrations/:passTypeID?passesUpdatedSince=:tag`
   - Returns list of passes to update

5. **Log Messages**
   - `POST /v1/log`
   - Receives error logs from devices

See: [PassKit Web Service Reference](https://developer.apple.com/documentation/passkit/wallet/implementing_wallet_with_a_server)

## Geofencing & Notifications

### Geofencing Configuration
```json
"locations": [
  {
    "latitude": 39.4143,
    "longitude": -77.4105,
    "relevantText": "Welcome to Bell Tower Hall! Your Impact Briefing starts soon.",
    "distance": 100
  }
]
```

- Triggers when user is within 100 meters of Bell Tower Hall
- Shows notification with `relevantText`
- Maximum 10 locations per pass

### Time-based Notifications
```json
"relevantDate": "2025-11-15T17:00:00-05:00"
```

- Shows pass on lock screen at specified time
- Use ISO 8601 format with timezone
- Typically set 1 hour before event

## Pass Semantics (Apple Maps & Siri Integration)

```json
"semantics": {
  "eventType": "PKEventTypeGeneric",
  "eventName": "Capitol Fund Quarterly Update",
  "venueName": "Bell Tower Hall",
  "venueLocation": {
    "latitude": 39.4143,
    "longitude": -77.4105
  },
  "eventStartDate": "2025-11-15T18:00:00-05:00",
  "eventEndDate": "2025-11-15T20:00:00-05:00"
}
```

Enables:
- "Add to Calendar" suggestion in iOS
- Directions in Apple Maps
- Siri suggestions ("You have an event in 1 hour")

## Troubleshooting

### Signature is empty (0 bytes)
- Ensure certificate is in macOS Keychain
- Check certificate name matches: `"Pass Type ID: pass.exchangereserve.lift"`
- Try: `security find-identity -v -p codesigning`

### Pass doesn't open on iPhone
- Verify certificate is not expired
- Check Team ID matches Apple Developer account
- Ensure all images are properly sized
- Validate JSON syntax

### Geofencing not working
- Location Services must be enabled for Wallet app
- Test on physical device (not simulator)
- Check `distance` is reasonable (100-500 meters)

### Notifications not appearing
- Set `relevantDate` in the future
- Check iPhone notification settings for Wallet
- Verify pass was added to Wallet (not just downloaded)

## Security Notes

⚠️ **Important**: Never commit these files to git:
- `certificates/*.p12`
- `certificates/*.pem` (except WWDR)
- `.env.local`
- `authenticationToken` should be unique per pass and stored securely

## Resources

- [PassKit Package Format Reference](https://developer.apple.com/documentation/passkit/wallet/creating_the_source_for_a_pass)
- [Apple Wallet Developer Guide](https://developer.apple.com/wallet/)
- [PassKit Web Service Reference](https://developer.apple.com/documentation/passkit/wallet/implementing_wallet_with_a_server)
- [Pass Design and Creation](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/)

## Next Steps

1. ✅ Hello World Pass — validated signature and packaging
2. ✅ Event Poster Pass — rich layout with geofencing
3. 🚧 Implement PassKit Web Service endpoints
4. 🚧 Setup APNs for push notifications
5. 🚧 Build web verification page
6. 🚧 Create pass management dashboard

## License

UNLICENSED - Proprietary
