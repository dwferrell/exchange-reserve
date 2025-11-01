# LIFT Certificate → Apple Wallet PassKit Mapping

## Overview

This document explains how LIFT Certificate concepts map to Apple Wallet's `eventTicket` pass type structure.

## Design Rationale

### Why EventTicket (Not Generic)?

**Decision:** Use `eventTicket` pass type for LIFT Certificates

**Reasoning:**
1. **Lifecycle Matches Event Model** - LIFT Certificates have start (issue) and end (maturity) dates
2. **Engagement Events** - Certificates unlock access to Impact Briefings and learning events
3. **Location-Based Features** - `eventTicket` supports geofencing for venue notifications
4. **Semantic Integration** - Maps, Siri, and Calendar integration work better with event semantics
5. **Phase Progression** - Maps well to event "tiers" or "access levels"

### iOS 26 Constraints

**Confirmed Limitations:**
- ✅ **5-6 BackField Maximum** - iOS 26 validates backField count strictly
- ❌ **No Poster Layout** - `preferredStyle: "PKPosterEventTicketStylePoster"` requires NFC-entitled certificate
- ✅ **Standard Layout Works** - Regular `eventTicket` renders reliably
- ✅ **Semantics Still Valuable** - Even without poster layout, semantics enable Maps/Siri/notifications

## Field Mapping Strategy

### Front of Pass

**Primary Field** (1 field, large display):
```json
{
  "key": "maturity-value",
  "label": "MATURITY VALUE",
  "value": "$3,780 USD"
}
```
- Most important metric to certificate holder
- Immediately visible without opening pass

**Secondary Fields** (2 fields, medium display):
```json
[
  {
    "key": "holder",
    "label": "Certificate Holder",
    "value": "Raul Hernandez"
  },
  {
    "key": "phase",
    "label": "Engagement Phase",
    "value": "◉◉◉○○ Phase 3 of 5"
  }
]
```
- Holder: Personalization & ownership
- Phase: Gamification / progression status

**Auxiliary Fields** (2 fields, small display):
```json
[
  {
    "key": "series",
    "label": "Series",
    "value": "2025Q4"
  },
  {
    "key": "maturity-date",
    "label": "Maturity",
    "value": "2029-03-15",
    "dateStyle": "PKDateStyleMedium"
  }
]
```
- Series: Investment cohort identifier
- Maturity Date: When certificate reaches full value

### Back of Pass (5 Field Maximum)

**Hybrid Approach - Balancing Comprehensive Info with Readability:**

#### Field 1: Certificate Details
**Purpose:** Core certificate metadata
```
Certificate ID: LIFT-CERT-V5-2025Q4
Holder: Raul Hernandez
Series: 2025Q4

Issue Date: March 15, 2024
Maturity Date: March 15, 2029 (60 months)

Maturity Value: $3,780 USD
Deposited to Date: $250
Projected Annual Growth: 20%

This certificate represents your participation...
```

#### Field 2: Engagement & Progression
**Purpose:** Gamification, phase status, unlocked/upcoming benefits
```
Current Phase: ◉◉◉○○ Engagement (Phase 3 of 5)

Progression Path:
Phase 1-2: Onboarding ✓
Phase 3: Engagement ← You are here
Phase 4: Residency (Next)
Phase 5: Anchorship (Final)

Unlocked Benefits:
• Access to Impact Briefings
• Priority event notifications
• Community forum access

Next Phase Unlocks:
• Private placement access
• Quarterly liquidity windows
• Governance participation
```

#### Field 3: Priorities & Upcoming Events
**Purpose:** Personalized priorities, next events
```
Selected Impact Priorities:
• Community Living
• Resilient Infrastructure
• Food & Farming

You'll receive invitations to learning events...

Next Impact Briefing:
Capitol Fund Quarterly Update
November 15, 2025 @ 6:00 PM
Bell Tower Hall, Frederick MD

You'll receive a geofenced notification...
```

#### Field 4: Structure & Verification
**Purpose:** Org hierarchy, verification
```
Organizational Hierarchy:
LocalFund → Capitol Fund → Exchange Reserve → LIFT Trust

• LocalFund: Community-facing brand
• Capitol Fund: Regional capital pool
• Exchange Reserve: Meta-ledger operator
• LIFT Trust: Delaware Statutory Trust (DST) series

Verify Certificate:
https://exchangereserve.netlify.app/verify/...

Scan QR code or visit link...
```

#### Field 5: Support & Disclosures
**Purpose:** Contact info, legal disclosures
```
Contact & Support:
Email: hello@exchangereserve.org
Phone: +1 (949) 202-6850
Website: https://exchangereserve.org
Dashboard: https://afluant.com

Legal Disclosure:
This certificate represents participation...

Complete Terms:
https://exchangereserve.netlify.app/terms/lift-2025q4
```

## Semantics Configuration

### Treating LIFT as "Ongoing Engagement Event"

```json
{
  "semantics": {
    "eventType": "PKEventTypeGeneric",
    "eventName": "LIFT Certificate — Series 2025Q4",
    "venueName": "Exchange Reserve",
    "venueLocation": {
      "latitude": 39.4143,
      "longitude": -77.4105
    },
    "venuePhoneNumber": "+19492026850",
    "eventStartDate": "2024-03-15T00:00:00-05:00",  // Issue date
    "eventEndDate": "2029-03-15T23:59:59-05:00"      // Maturity date
  }
}
```

**Benefits:**
- iOS Maps shows "Exchange Reserve" location
- Siri knows it's an engagement spanning 5 years
- Calendar integration (if holder enables)
- Smart suggestions based on location/time

### Location-Based Notifications

```json
{
  "locations": [
    {
      "latitude": 39.4143,
      "longitude": -77.4105,
      "relevantText": "Upcoming Impact Briefing at Bell Tower Hall",
      "distance": 100
    }
  ],
  "relevantDate": "2025-11-15T17:00:00-05:00",
  "maxDistance": 500
}
```

**Behavior:**
- When holder is within 500m of Bell Tower Hall
- Pass appears on lock screen
- Shows "relevantText" notification
- 1 hour before relevantDate, pass becomes prominent

## Related Event Passes

### 1. Impact Briefing (Quarterly)

**Serial:** `IMPACT-BRIEF-Q4-2025`

**Purpose:** Quarterly holder update events

**Key Differences from LIFT Certificate:**
- Specific event date/time (not ongoing)
- Venue-specific (Bell Tower Hall)
- References LIFT holder status in backFields
- More detailed event agenda

**Integration:**
- "Holder Access" backField references LIFT Certificate
- Same Pass Type ID (groups with LIFT in Wallet)
- Complementary event to base certificate

### 2. Learning Events (Priority-Based)

**Serials:**
- `LEARNING-COMMUNITY-001` - Community Living
- `LEARNING-INFRA-001` - Resilient Infrastructure
- `LEARNING-FOOD-001` - Food & Farming

**Purpose:** Educational workshops/tours for priority topics

**Key Differences:**
- Tied to specific priorities holders selected
- Smaller, topic-focused events
- Include "LIFT Priority Connection" backField
- Note that participation enhances phase progression

**Integration:**
- Reference LIFT Certificate holder status
- Map to holder's selected priorities
- Free access benefit of holding LIFT Certificate

## Pass Ecosystem

```
LIFT Certificate V5 (Base Credential)
├── Ongoing engagement (5-year lifecycle)
├── Unlocks access to:
│   ├── Impact Briefings (quarterly)
│   ├── Learning Events (priority-based)
│   └── Future: Liquidity Window passes
└── Contains: Phase, priorities, structure info

Impact Briefing Q4-2025 (Quarterly Event)
├── Specific event instance
├── References LIFT holder status
└── Groups with LIFT in Wallet

Learning Events (Priority Events)
├── Community Living Workshop
├── Infrastructure Field Tour
└── Food & Farming Workshop
    ├── Match holder priorities
    ├── Reference LIFT status
    └── Note phase progression benefit
```

## Quarterly Update Strategy

### Options for Handling Changing Information:

**Option 1: Replace Pass Quarterly (Current Approach)**
- Create V5 (Q4 2025), V6 (Q1 2026), V7 (Q2 2026)...
- Each includes updated:
  - Phase progression
  - Deposited amount
  - Next Impact Briefing details
  - Current priorities
- User deletes old, adds new

**Option 2: Implement PassKit Web Service** (Future)
- Dynamic backField updates
- Push notifications for pass changes
- Requires web service implementation
- See `/PASSKIT-WEB-SERVICE.md` for specs

**Option 3: Hybrid**
- Base LIFT Certificate stays static (identity credential)
- Impact Briefings and events update quarterly
- Major milestones (phase changes) trigger new LIFT pass

**Recommendation:** Start with Option 1, plan for Option 2

## Key Design Decisions

### 1. Why Not Use `generic` Pass Type?

**Considered:** Using `generic` since LIFT is a financial instrument

**Rejected Because:**
- `eventTicket` provides better engagement features (geofencing, dates)
- Semantics integration better with event model
- Impact Briefings and learning events ARE events
- Lifecycle (issue → maturity) maps well to event span

### 2. Why Consolidate BackFields?

**5-Field Limit:** iOS 26 strictly validates

**Strategy:** Group related information
- Certificate metadata → Single field
- Engagement/progression → Single field
- Priorities/events → Single field
- Structure/verification → Single field
- Support/legal → Single field

**Benefits:**
- Stays within iOS 26 limits
- Readable on mobile screen
- Comprehensive without overwhelming

### 3. Why Separate Event Passes?

**Alternative:** Put everything in LIFT Certificate

**Rejected Because:**
- Event-specific details clutter base certificate
- Dates change quarterly
- Different notification requirements
- Cleaner separation of concerns

**Benefits of Separate Passes:**
- LIFT Certificate = Identity/access credential (persistent)
- Event Passes = Time-bound engagements (ephemeral)
- Each can be optimized for its purpose

## Implementation Checklist

- [x] LIFT Certificate V5 base structure
- [x] 5 backFields (iOS 26 compliant)
- [x] Semantics with venue/location/dates
- [x] Geofencing for Impact Briefings
- [x] Impact Briefing Q4-2025 event pass
- [x] 3 priority learning event samples
- [ ] PassKit Web Service (future)
- [ ] Liquidity Window passes (future)
- [ ] NFC certificate request (for poster layout)

## Next Steps

1. **Test on iOS 26** - Verify all passes install and display correctly
2. **Validate Notifications** - Test geofencing and relevantDate triggers
3. **User Feedback** - Gather input on information architecture
4. **Iterate** - Refine backField content based on readability
5. **Plan Web Service** - For dynamic updates in future versions

## Files Created

```
templates/
├── lift-certificate-v5/          # Base LIFT Certificate
├── impact-briefing-q4-2025/      # Quarterly holder event
├── learning-community-living/    # Priority: Community Living
├── learning-infrastructure/      # Priority: Infrastructure
└── learning-food-farming/        # Priority: Food & Farming

public/
├── lift-certificate-v5.pkpass
├── impact-briefing-q4-2025.pkpass
├── learning-community-living.pkpass
├── learning-infrastructure.pkpass
└── learning-food-farming.pkpass
```

---

**Document Version:** 1.0
**Last Updated:** November 1, 2025
**Author:** Exchange Reserve Team (via Claude Code)
