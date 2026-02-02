"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = () => ({
    port: parseInt(process.env.PORT || '3000', 10),
    nodeEnv: process.env.NODE_ENV || 'development',
    database: {
        url: process.env.DATABASE_URL,
    },
    jwt: {
        secret: process.env.JWT_SECRET || 'development-secret',
        accessTokenExpiration: process.env.JWT_ACCESS_TOKEN_EXPIRATION || '15m',
        refreshTokenExpiration: process.env.JWT_REFRESH_TOKEN_EXPIRATION || '7d',
    },
    encryption: {
        key: process.env.ENCRYPTION_KEY || 'default-encryption-key-32bytes!',
    },
    nfc: {
        signingSecret: process.env.NFC_SIGNING_SECRET || 'nfc-development-signing-secret-key',
        tokenValidityMs: parseInt(process.env.NFC_TOKEN_VALIDITY_MS || '120000', 10),
    },
    throttle: {
        ttl: parseInt(process.env.THROTTLE_TTL || '60', 10),
        limit: parseInt(process.env.THROTTLE_LIMIT || '100', 10),
    },
});
//# sourceMappingURL=configuration.js.map