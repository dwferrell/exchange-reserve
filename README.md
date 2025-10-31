# Exchange Reserve

> Regenerative Capital Framework with Apple Wallet and Google Wallet Integration

## Project Structure

This is a monorepo containing multiple applications and shared packages:

```
exchange-reserve/
├── apps/
│   ├── passkit-apple/     # Apple Wallet pass generation
│   ├── passkit-google/    # Google Wallet integration
│   ├── web/               # Next.js website (ExchangeReserve.org)
│   └── api/               # Backend API server
├── packages/
│   ├── shared-types/      # Shared TypeScript types
│   ├── ui/                # Shared React components
│   └── pass-core/         # Pass generation utilities
└── supabase/              # Supabase migrations and config
```

## Quick Start

### Prerequisites

- Node.js >= 18.0.0
- pnpm >= 8.0.0
- macOS (for PassKit signing with native OpenSSL)
- Apple Developer account with Pass Type ID certificate

### Installation

```bash
# Install dependencies
pnpm install

# Copy environment variables
cp .env.example .env.local
# Edit .env.local with your credentials
```

### Development

```bash
# Run web app
pnpm dev

# Run API server
pnpm dev:api

# Build all packages
pnpm build

# Build PassKit passes
pnpm build:passes
```

### Local Mobile Testing

For testing on mobile devices over LAN:

```bash
# Start Next.js on all network interfaces
cd apps/web
pnpm dev -H 0.0.0.0 -p 3001

# Access from mobile: http://<your-lan-ip>:3001
```

For Apple Wallet passes:
- Use AirDrop to send .pkpass files from Mac to iPhone
- Or email the .pkpass file to yourself

## PassKit Certificate Setup

1. Download Pass Type ID certificate from [Apple Developer](https://developer.apple.com/account/resources/identifiers/list/passTypeId)
2. Export as `.p12` file with a strong password
3. Download Apple WWDR G3 certificate
4. Place certificates in `apps/passkit-apple/certificates/` (gitignored)
5. Set `PASSKIT_CERT_PASSWORD` in `.env.local`

## Project Phases

### ✅ Phase 1: Hello World Pass
- [x] Monorepo setup
- [ ] Basic pass generation
- [ ] Valid signature
- [ ] AirDrop test

### 🚧 Phase 2: Event Poster Pass
- [ ] Enhanced pass layout
- [ ] Geofencing
- [ ] Time-based notifications
- [ ] PassKit Web Service

### 📋 Phase 3: Web Application
- [ ] Next.js app
- [ ] Pass distribution
- [ ] QR verification

### 📋 Phase 4: Backend & Supabase
- [ ] Database schema
- [ ] PassKit Web Service API
- [ ] Push notifications

### 📋 Phase 5: Google Wallet
- [ ] Google Pay API integration
- [ ] JWT signing

### 📋 Phase 6: CI/CD
- [ ] GitHub Actions
- [ ] Netlify deployment
- [ ] Automated testing

## Pass Type Details

- **Pass Type ID**: `pass.exchangereserve.lift`
- **Organization**: LocalFund
- **Format**: Event Ticket / Poster style

## Resources

- [Apple PassKit Documentation](https://developer.apple.com/documentation/passkit)
- [Google Wallet API](https://developers.google.com/wallet)
- [PassKit Web Service Reference](https://developer.apple.com/documentation/passkit/wallet/implementing_wallet_with_a_server)

## License

UNLICENSED - Proprietary
