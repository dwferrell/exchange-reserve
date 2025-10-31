# PassKit Web Service Integration for Exchange Reserve

## Overview

Exchange Reserve LIFT Certificates use Apple's PassKit Web Service protocol to enable dynamic pass updates. This allows the meta-ledger to push real-time changes to holder devices for:

- Balance/maturity value updates
- Phase progression notifications
- New offering windows
- Event invitations (geofenced)
- Impact milestone achievements

## Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌────────────────┐
│  Apple Wallet   │ ◄─────► │  Exchange Reserve │ ◄─────► │   Supabase     │
│  (iOS Device)   │  HTTPS  │  PassKit API      │  Auth   │  Meta-Ledger   │
└─────────────────┘         └──────────────────┘         └────────────────┘
```

## Required API Endpoints

Apple's PassKit Web Service requires implementing 4 specific REST endpoints:

### 1. Register Device for Pass Updates

**Endpoint:** `POST /v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}/{serialNumber}`

**Purpose:** iOS calls this when a pass is added to Wallet

**Headers:**
- `Authorization: ApplePass {authenticationToken}`

**Body:**
```json
{
  "pushToken": "<hex-encoded-apns-token>"
}
```

**Response:**
- `200 OK` - Registration successful
- `201 Created` - New registration
- `401 Unauthorized` - Invalid authenticationToken

**Implementation:** Store device-pass mappings in Supabase table:
```sql
CREATE TABLE pass_registrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  device_library_id TEXT NOT NULL,
  pass_type_id TEXT NOT NULL,
  serial_number TEXT NOT NULL,
  push_token TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(device_library_id, pass_type_id, serial_number)
);
```

---

### 2. Get Updatable Passes for Device

**Endpoint:** `GET /v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}?passesUpdatedSince={timestamp}`

**Purpose:** iOS polls this to check which passes need updates

**Query Parameters:**
- `passesUpdatedSince` (optional) - ISO 8601 timestamp

**Response:**
```json
{
  "lastUpdated": "2025-10-31T12:00:00Z",
  "serialNumbers": ["LIFT-8472-9103", "LIFT-8472-9104"]
}
```

**Implementation:** Query Supabase for passes with `updated_at > passesUpdatedSince`

---

### 3. Get Latest Pass Data

**Endpoint:** `GET /v1/passes/{passTypeIdentifier}/{serialNumber}`

**Purpose:** iOS fetches the updated pass when notified

**Headers:**
- `Authorization: ApplePass {authenticationToken}`
- `If-Modified-Since` (optional)

**Response:**
- `200 OK` + `.pkpass` file (if updated)
- `304 Not Modified` (if no changes)
- `401 Unauthorized` - Invalid authenticationToken

**Implementation:**
1. Query meta-ledger for current certificate data
2. Generate fresh pass.json with updated values
3. Sign manifest and package as .pkpass
4. Return binary .pkpass file

---

### 4. Unregister Device

**Endpoint:** `DELETE /v1/devices/{deviceLibraryIdentifier}/registrations/{passTypeIdentifier}/{serialNumber}`

**Purpose:** iOS calls this when pass is removed from Wallet

**Headers:**
- `Authorization: ApplePass {authenticationToken}`

**Response:**
- `200 OK` - Unregistration successful

**Implementation:** Delete registration record from Supabase

---

## Push Notification Flow

When Exchange Reserve updates a certificate:

1. **Meta-Ledger Update Event** (e.g., phase progression, balance change)
2. **Exchange Reserve API** queries for devices registered to that serial number
3. **Send APNs Notification** to each device's push token:
   ```
   POST https://api.push.apple.com/3/device/{pushToken}
   Headers:
     apns-topic: pass.exchangereserve.lift
   Body: {}  (empty payload)
   ```
4. **iOS Fetches Update** via GET /v1/passes/{passTypeIdentifier}/{serialNumber}
5. **Pass Updates in Wallet** automatically

## Example: Phase Progression Update

```javascript
// Triggered by Supabase function when holder advances to Phase 2
async function notifyPhaseProgression(serialNumber) {
  // 1. Update pass data in meta-ledger
  await supabase
    .from('lift_certificates')
    .update({
      phase: 2,
      updated_at: new Date().toISOString()
    })
    .eq('serial_number', serialNumber);

  // 2. Find all registered devices for this pass
  const { data: registrations } = await supabase
    .from('pass_registrations')
    .select('push_token')
    .eq('serial_number', serialNumber);

  // 3. Send APNs notification to each device
  for (const reg of registrations) {
    await sendAPNsNotification(reg.push_token, {
      topic: 'pass.exchangereserve.lift',
      payload: {}  // Empty payload triggers pass fetch
    });
  }
}
```

## Security Considerations

### Authentication Tokens
- Each pass has unique `authenticationToken` (32+ random chars)
- Stored in Supabase with pass record
- Validated on every API call via `Authorization: ApplePass {token}` header
- Never expose in client code

### APNs Certificates
- Requires Apple Push Notification service certificate
- Request from Apple Developer Portal: Certificates → Services → Pass Type ID Certificate
- Store .p12 securely (Supabase secrets or environment variables)
- Renew annually before expiration

### HTTPS Only
- PassKit Web Service MUST be served over HTTPS
- Use valid SSL certificate (Netlify provides this automatically)
- Self-signed certificates will fail

## Implementation Roadmap

### Phase 1: Supabase Backend (Current: Prototype)
- [ ] Deploy Supabase project
- [ ] Create pass_registrations table
- [ ] Implement 4 required API endpoints as Supabase Edge Functions
- [ ] Set up APNs certificate and push notifications
- [ ] Test device registration → update → notification flow

### Phase 2: Meta-Ledger Integration
- [ ] Link pass updates to meta-ledger events
- [ ] Automatic phase progression triggers
- [ ] Balance recalculation on deposits
- [ ] Event invitation system (geofenced)

### Phase 3: Multi-Series Support
- [ ] Support multiple fund series (S2025Q4, S2026Q1, etc.)
- [ ] Holder portfolio management (multiple certificates)
- [ ] Cross-certificate analytics

## Testing Locally

For development, use placeholder webServiceURL:
```json
{
  "webServiceURL": "https://exchangereserve.netlify.app/api/v1/passes",
  "authenticationToken": "test-token-dev-only-32-chars-min"
}
```

iOS will attempt to register but gracefully handle 404s. Pass will still work offline.

## Resources

- [Apple PassKit Web Service Reference](https://developer.apple.com/library/archive/documentation/PassKit/Reference/PassKit_WebService/WebService.html)
- [PassKit Developer Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/)
- [APNs Provider API](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)

## Contact

For implementation questions: hello@exchangereserve.org
