# iOS Event Ticket Guide: Poster Layout & Semantic Tags

## Overview

Starting with **iOS 18** (introduced at WWDC 2024), Apple Wallet supports an enhanced **Poster Event Ticket** layout that displays rich information below your pass, including:
- Interactive Maps tile showing venue location
- Event Guide button with directions, weather, and more
- Live Activities integration
- Multi-event support (festivals, season passes)

**The key insight:** This extra functionality isn't driven by normal pass fields—it's driven by **Semantic Tags** in the `semantics` object. Without proper semantics and the poster layout, iOS Wallet won't show these features.

---

## Quick Checklist

To get the enhanced event ticket experience working, you must satisfy ALL of these requirements:

### ✅ 1. Use Poster Event Ticket Layout

In your `pass.json`, specify the poster style:

```json
{
  "formatVersion": 1,
  "passTypeIdentifier": "pass.your.identifier",
  "eventTicket": {
    "preferredStyle": "PKPosterEventTicketStylePoster"
  }
}
```

The poster layout is what unlocks the rich UI below the pass.

### ✅ 2. Include Required Semantics

For the below-the-pass features to appear, Apple expects **venue + date semantics** at minimum:

```json
{
  "semantics": {
    "eventType": "PKEventTypeGeneric",
    "eventName": "Your Event Name",
    "venueName": "Venue Name",
    "venueLocation": {
      "latitude": 37.7749,
      "longitude": -122.4194
    },
    "eventStartDate": "2025-11-15T18:00:00-05:00",
    "eventEndDate": "2025-11-15T20:00:00-05:00"
  }
}
```

**Recommended semantic tags:**
- `venueName` (required) - Venue name as a string
- `venueLocation` (recommended) - Object with `latitude` and `longitude`
- `venuePlaceID` (optional) - Apple Maps place identifier for better integration
- `venueEntrance` (optional) - Specific entrance location (lat/long)
- `eventStartDate` (required) - ISO 8601 date string
- `eventEndDate` (optional) - ISO 8601 date string
- `seats` (optional) - Seat information object
- `performers` (optional) - Array of performer names
- `genre` (optional) - Event genre/category

### ✅ 3. Use the Right Buckets for Different Content

**Important distinction:**

- **Semantics** = Machine-readable data that powers features (Maps, Event Guide, Live Activities)
- **Fields** = Human-readable text displayed on the pass

| Content Type | Where to Put It | Example |
|--------------|----------------|---------|
| Venue name, location, dates | `semantics` | Maps integration, Event Guide |
| Seats, performers, teams | `semantics` | Event-specific tiles |
| Custom text you want to display | `eventTicket.backFields` or `additionalInfoFields` | "VIP Lounge Code: 42B" |
| Pass-visible fields | `primaryFields`, `secondaryFields`, `auxiliaryFields` | Event name, date shown on pass front |

**Key point:** Many semantic tags power UI features but don't render as visible text themselves. Always put display text in fields, and use semantics for machine-readable data.

### ✅ 4. NFC Certificate / Entitlement

Poster event tickets typically require an **NFC-entitled pass certificate** (Enhanced Pass certificate):

- If you sign with a regular Pass Type ID certificate, iOS may refuse to install the pass or fall back to the old layout
- Request NFC entitlement from Apple Developer portal for enhanced passes
- This is separate from your standard Pass Type ID certificate

### ✅ 5. (Optional) Multiple Dates on One Ticket

For festivals, season passes, or multi-event tickets, use the `upcomingPassInformation` array:

```json
{
  "upcomingPassInformation": [
    {
      "semantics": {
        "eventName": "Concert Night 1",
        "eventStartDate": "2025-11-15T19:00:00-05:00"
      },
      "urls": {
        "eventInfo": "https://example.com/event/night1"
      }
    },
    {
      "semantics": {
        "eventName": "Concert Night 2",
        "eventStartDate": "2025-11-16T19:00:00-05:00"
      },
      "urls": {
        "eventInfo": "https://example.com/event/night2"
      }
    }
  ]
}
```

Each entry gets its own detail screen with dedicated semantics, URLs, and images.

---

## Minimal Example

Here's a minimal `pass.json` that should trigger the Event Guide and Maps tile:

```json
{
  "formatVersion": 1,
  "passTypeIdentifier": "pass.your.identifier",
  "serialNumber": "EVENT-001",
  "teamIdentifier": "YOUR_TEAM_ID",
  "organizationName": "Your Organization",
  "description": "Concert Ticket",
  "logoText": "Your Brand",

  "eventTicket": {
    "preferredStyle": "PKPosterEventTicketStylePoster",
    "primaryFields": [
      {
        "key": "event",
        "label": "EVENT",
        "value": "Music Festival 2025"
      }
    ],
    "secondaryFields": [
      {
        "key": "location",
        "label": "Location",
        "value": "Golden Gate Park"
      }
    ],
    "auxiliaryFields": [
      {
        "key": "date",
        "label": "Date",
        "value": "2025-11-15T18:00:00-08:00",
        "dateStyle": "PKDateStyleMedium",
        "timeStyle": "PKDateStyleShort"
      }
    ],
    "backFields": [
      {
        "key": "info",
        "label": "Event Info",
        "value": "Gates open at 6 PM. Bring valid ID."
      }
    ]
  },

  "semantics": {
    "eventType": "PKEventTypeLivePerformance",
    "eventName": "Music Festival 2025",
    "venueName": "Golden Gate Park",
    "venueLocation": {
      "latitude": 37.7694,
      "longitude": -122.4862
    },
    "eventStartDate": "2025-11-15T18:00:00-08:00",
    "eventEndDate": "2025-11-15T23:00:00-08:00",
    "performers": ["Artist One", "Artist Two"],
    "genre": "Music"
  },

  "barcodes": [
    {
      "format": "PKBarcodeFormatQR",
      "message": "https://example.com/verify/EVENT-001",
      "messageEncoding": "iso-8859-1"
    }
  ],

  "backgroundColor": "rgb(23, 99, 183)",
  "foregroundColor": "rgb(255, 255, 255)",
  "labelColor": "rgb(200, 220, 255)"
}
```

---

## Complete Semantic Tags Reference

### Event Types

```json
"eventType": "PKEventTypeGeneric"
```

Options:
- `PKEventTypeGeneric` - Default
- `PKEventTypeLivePerformance` - Concerts, theater
- `PKEventTypeMovie` - Film screenings
- `PKEventTypeSports` - Sports events
- `PKEventTypeConference` - Conferences, meetings
- `PKEventTypeConvention` - Conventions
- `PKEventTypeWorkshop` - Workshops
- `PKEventTypeSocialGathering` - Social events

### Venue Information

```json
"venueName": "Madison Square Garden",
"venueLocation": {
  "latitude": 40.7505,
  "longitude": -73.9934
},
"venuePlaceID": "ChIJhRwB-yFawokR5Phil-QQ3zM",  // Apple Maps place ID
"venueEntrance": {
  "latitude": 40.7508,
  "longitude": -73.9935
},
"venuePhoneNumber": "+12125551234",
"venueRoom": "Hall A"
```

### Date & Time

```json
"eventStartDate": "2025-11-15T18:00:00-05:00",
"eventEndDate": "2025-11-15T22:00:00-05:00",
"doorsOpenDate": "2025-11-15T17:00:00-05:00",
"doorsCloseDate": "2025-11-15T17:45:00-05:00"
```

All dates should be ISO 8601 format with timezone.

### Seating

```json
"seats": [
  {
    "seatSection": "Section 101",
    "seatRow": "Row 5",
    "seatNumber": "Seat 12",
    "seatType": "Regular",
    "seatDescription": "Aisle seat"
  }
]
```

### Performers & Teams

```json
"performers": ["Taylor Swift", "Opening Act"],
"genre": "Pop Music",

// For sports events:
"homeTeam": {
  "teamName": "Home Team",
  "teamAbbreviation": "HT"
},
"awayTeam": {
  "teamName": "Away Team",
  "teamAbbreviation": "AT"
},
"league": "MLB",
"sport": "Baseball"
```

### Tickets & Admission

```json
"admissionLevel": "VIP",
"confirmationNumber": "ABC123456",
"ticketNumber": "0001",
"ticketToken": "ey...",  // JWT or similar
"totalPrice": {
  "currencyCode": "USD",
  "amount": "125.00"
}
```

### Organizer Information

```json
"organizerName": "Live Nation",
"organizerPhoneNumber": "+18005551234",
"organizerEmail": "support@example.com"
```

---

## URLs and Images for Event Guide

The Event Guide uses special `urls` and `images` objects:

```json
{
  "urls": {
    "eventInfo": "https://example.com/event-info",
    "ticketPurchase": "https://example.com/buy-tickets",
    "venueInfo": "https://example.com/venue"
  },
  "images": {
    "eventThumbnail": "https://example.com/images/event-thumb.jpg",
    "venueThumbnail": "https://example.com/images/venue-thumb.jpg",
    "eventHero": "https://example.com/images/event-hero.jpg"
  }
}
```

These appear in the Event Guide UI when users tap the button below the pass.

---

## Troubleshooting

### Event Guide / Maps Tile Not Showing

**Possible causes:**

1. **Not using poster style**
   - Fix: Add `"preferredStyle": "PKPosterEventTicketStylePoster"` to `eventTicket`

2. **Missing required semantics**
   - Fix: Ensure you have at minimum: `venueName`, `venueLocation`, `eventStartDate`

3. **Wrong certificate**
   - Fix: Use NFC-entitled Enhanced Pass certificate, not regular Pass Type ID certificate

4. **Pass won't install**
   - Check signing with [PKPASS Validator](https://pkpassvalidator.com/)
   - Verify manifest.json and signature are correct
   - Ensure certificate hasn't expired

5. **Semantics not rendering as text**
   - Expected behavior! Semantics power features, not display
   - Fix: Add visible text to `backFields` or `additionalInfoFields`

### Common Mistakes

**❌ Putting everything in semantics and expecting it to display**
```json
"semantics": {
  "venueName": "Bell Tower Hall",
  "customField": "VIP Lounge Code: 42B"  // Won't show!
}
```

**✅ Use fields for custom display text**
```json
"semantics": {
  "venueName": "Bell Tower Hall"
},
"eventTicket": {
  "backFields": [
    {
      "key": "vip-code",
      "label": "VIP Lounge Code",
      "value": "42B"
    }
  ]
}
```

**❌ Using old event ticket layout**
```json
"eventTicket": {
  "primaryFields": [...]
  // Missing preferredStyle!
}
```

**✅ Specify poster style**
```json
"eventTicket": {
  "preferredStyle": "PKPosterEventTicketStylePoster",
  "primaryFields": [...]
}
```

---

## Official Resources

### Apple Documentation

- [Supporting Semantic Tags in Wallet Passes](https://developer.apple.com/documentation/walletpasses/pass/semantics) - Canonical reference for the `semantics` object and available tags
- [Pass (WalletPasses) Documentation](https://developer.apple.com/documentation/walletpasses/pass) - Complete pass schema with event-ticket-specific keys
- [WWDC 2024 - What's New in Wallet & Apple Pay](https://developer.apple.com/videos/play/wwdc2024/10106/) - Introduces Poster Event Tickets with live demos (has transcript)
- [WWDC 2025 - What's New in Wallet](https://developer.apple.com/videos/play/wwdc2025/10118/) - Multi-event passes, additional semantics examples (has transcript)

### Third-Party Guides

- [PassCreator: Enhanced Event Tickets in Apple Wallet](https://www.passcreator.com/blog/enhanced-event-tickets-apple-wallet/) - Practical triggers for Event Guide, clear screenshots
- [let's dev: New Event Ticket Layout in Apple Wallet](https://lets-dev.com/blog/new-event-ticket-layout-apple-wallet/) - Visual breakdown of layout, maps, weather, Live Activities

### Testing & Tools

- [PKPASS Validator](https://pkpassvalidator.com/) - Upload `.pkpass` files to check signing, manifest, and installation issues
- [passkit-generator (Node.js)](https://github.com/alexandercerutti/passkit-generator) - Actively maintained, supports iOS 18+ semantics and poster layout
- [passes-rs (Rust)](https://github.com/palfrey/passes) - Rust library with semantic tag support
- [PassKit Platform](https://www.passkit.com/) - Hosted service with UI and API for pass creation
- [PassCreator Platform](https://www.passcreator.com/) - UI-based pass builder with semantic tag support

---

## Example: Multi-Event Festival Pass

```json
{
  "formatVersion": 1,
  "passTypeIdentifier": "pass.your.festival",
  "serialNumber": "FESTIVAL-2025-001",
  "teamIdentifier": "YOUR_TEAM_ID",
  "organizationName": "Music Festival Co",
  "description": "Summer Music Festival 3-Day Pass",
  "logoText": "Summer Fest",

  "eventTicket": {
    "preferredStyle": "PKPosterEventTicketStylePoster",
    "primaryFields": [
      {
        "key": "event",
        "value": "Summer Music Festival 2025"
      }
    ],
    "secondaryFields": [
      {
        "key": "dates",
        "label": "Dates",
        "value": "Nov 15-17, 2025"
      },
      {
        "key": "access",
        "label": "Access",
        "value": "General Admission"
      }
    ]
  },

  "semantics": {
    "eventType": "PKEventTypeLivePerformance",
    "eventName": "Summer Music Festival 2025",
    "venueName": "Festival Grounds",
    "venueLocation": {
      "latitude": 37.7749,
      "longitude": -122.4194
    }
  },

  "upcomingPassInformation": [
    {
      "semantics": {
        "eventName": "Friday Night - Headliner A",
        "eventStartDate": "2025-11-15T18:00:00-08:00",
        "eventEndDate": "2025-11-15T23:00:00-08:00",
        "performers": ["Headliner A", "Support Act 1"],
        "genre": "Rock"
      },
      "urls": {
        "eventInfo": "https://example.com/schedule/friday"
      }
    },
    {
      "semantics": {
        "eventName": "Saturday Night - Headliner B",
        "eventStartDate": "2025-11-16T18:00:00-08:00",
        "eventEndDate": "2025-11-16T23:00:00-08:00",
        "performers": ["Headliner B", "Support Act 2"],
        "genre": "Electronic"
      },
      "urls": {
        "eventInfo": "https://example.com/schedule/saturday"
      }
    },
    {
      "semantics": {
        "eventName": "Sunday Night - Headliner C",
        "eventStartDate": "2025-11-17T18:00:00-08:00",
        "eventEndDate": "2025-11-17T23:00:00-08:00",
        "performers": ["Headliner C", "Support Act 3"],
        "genre": "Hip Hop"
      },
      "urls": {
        "eventInfo": "https://example.com/schedule/sunday"
      }
    }
  ],

  "barcodes": [
    {
      "format": "PKBarcodeFormatQR",
      "message": "https://example.com/verify/FESTIVAL-2025-001",
      "messageEncoding": "iso-8859-1"
    }
  ],

  "backgroundColor": "rgb(0, 0, 0)",
  "foregroundColor": "rgb(255, 255, 255)",
  "labelColor": "rgb(200, 200, 200)"
}
```

---

## Best Practices

### 1. Always Provide Core Semantics

Minimum required for Event Guide to appear:
- `venueName`
- `venueLocation` or `venuePlaceID`
- `eventStartDate`

### 2. Use Apple Maps Place IDs When Available

Better than just lat/long:
```json
"venuePlaceID": "ChIJhRwB-yFawokR5Phil-QQ3zM"
```

This provides richer Maps integration with venue details, hours, photos, etc.

### 3. Separate Display Text from Machine Data

- Semantics = for Wallet features
- Fields = for display on pass

### 4. Test on Real Devices

- Simulator may not show all features
- Test on iOS 18+ devices
- Check Event Guide, Maps tile, Live Activities

### 5. Use Relevant Dates for Timely Notifications

```json
"relevantDate": "2025-11-15T17:00:00-05:00"  // 1 hour before event
```

Wallet will show the pass on lock screen at the relevant time.

### 6. Add Locations for Geofencing

```json
"locations": [
  {
    "latitude": 37.7749,
    "longitude": -122.4194,
    "relevantText": "Welcome to the venue! Show this pass at the gate.",
    "distance": 100
  }
]
```

Pass appears on lock screen when user is near the venue.

---

## Summary

To get the enhanced iOS 18+ event ticket experience:

1. ✅ Use `"preferredStyle": "PKPosterEventTicketStylePoster"`
2. ✅ Include `semantics` with `venueName`, `venueLocation`, and `eventStartDate`
3. ✅ Put custom display text in `backFields` or `additionalInfoFields`
4. ✅ Sign with NFC-entitled Enhanced Pass certificate
5. ✅ (Optional) Use `upcomingPassInformation` for multi-event passes

**Key insight:** Semantics power features (Maps, Event Guide), not display. Always pair semantics with appropriate fields for visible text.

---

## Questions or Issues?

- Check the [Apple PassKit Documentation](https://developer.apple.com/documentation/walletpasses)
- Watch [WWDC videos](https://developer.apple.com/videos/walletpasses)
- Validate passes at [pkpassvalidator.com](https://pkpassvalidator.com/)
- Test with known-good implementations like [PassKit](https://www.passkit.com/) or [PassCreator](https://www.passcreator.com/)

---

**Last updated:** November 2025 | **Requires:** iOS 18+ | **Note:** We're currently on iOS 26 (released 2025), but the main semantics pass and NFC features were released for iOS 18 at WWDC 2024
