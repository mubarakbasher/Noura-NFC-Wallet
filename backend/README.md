# NFC Wallet Backend

Secure and scalable NestJS backend for the NFC-based electronic payment application.

## Features

- 🔐 JWT Authentication with refresh tokens
- 💳 Wallet management with SDG currency
- 📱 NFC payment validation with double-spend prevention
- 📜 Transaction history with pagination
- 🏷️ NFC device (card/wristband) linkage
- 🌍 Arabic/English i18n support
- 🛡️ Rate limiting and security middleware

## Quick Start

```bash
# Install dependencies
npm install

# Generate Prisma client
npx prisma generate

# Push database schema
npx prisma db push

# Start development server
npm run start:dev
```

Server runs at **http://localhost:3000**

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout user

### Wallet
- `GET /api/wallet` - Get user wallet
- `GET /api/wallet/balance` - Get balance
- `POST /api/wallet/topup` - Top-up wallet

### Transactions
- `POST /api/transaction/validate` - Process NFC payment
- `GET /api/transaction/history` - Get transaction history
- `GET /api/transaction/:id` - Get transaction details

### User Profile
- `GET /api/user/profile` - Get profile
- `PUT /api/user/profile` - Update profile
- `PUT /api/user/pin` - Update PIN

### NFC Devices
- `POST /api/nfc-devices` - Link NFC device
- `GET /api/nfc-devices` - List linked devices
- `DELETE /api/nfc-devices/:id` - Unlink device

### Health
- `GET /health` - Server health check

## Environment Variables

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="your-secret-key"
PORT=3000
```

## Project Structure

```
src/
├── auth/           # Authentication module
├── users/          # User profile module
├── wallets/        # Wallet operations
├── transactions/   # Transaction processing
├── nfc-devices/    # NFC device management
├── prisma/         # Database service
├── config/         # Configuration
└── common/         # Shared utilities
```

## License

Private - Graduation Project
