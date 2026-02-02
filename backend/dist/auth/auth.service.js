"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const bcrypt = __importStar(require("bcrypt"));
const uuid_1 = require("uuid");
const prisma_service_1 = require("../prisma/prisma.service");
let AuthService = class AuthService {
    prisma;
    jwtService;
    configService;
    SALT_ROUNDS = 12;
    REFRESH_TOKEN_DAYS = 7;
    constructor(prisma, jwtService, configService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
        this.configService = configService;
    }
    async register(registerDto) {
        const existingUser = await this.prisma.user.findUnique({
            where: { email: registerDto.email },
        });
        if (existingUser) {
            throw new common_1.ConflictException('Email already registered');
        }
        const passwordHash = await bcrypt.hash(registerDto.password, this.SALT_ROUNDS);
        const user = await this.prisma.$transaction(async (tx) => {
            const newUser = await tx.user.create({
                data: {
                    email: registerDto.email,
                    fullName: registerDto.fullName,
                    phone: registerDto.phone,
                    passwordHash,
                    deviceId: registerDto.deviceId,
                    language: registerDto.language || 'en',
                },
            });
            await tx.wallet.create({
                data: {
                    userId: newUser.id,
                    balance: 1000,
                    currency: 'SDG',
                    status: 'ACTIVE',
                },
            });
            return newUser;
        });
        const tokens = await this.generateTokens(user.id, user.email, user.role);
        return {
            user: this.sanitizeUser(user),
            ...tokens,
        };
    }
    async login(loginDto) {
        const user = await this.prisma.user.findUnique({
            where: { email: loginDto.email },
            include: { wallet: true },
        });
        if (!user) {
            throw new common_1.UnauthorizedException('Invalid email or password');
        }
        if (user.status !== 'ACTIVE') {
            throw new common_1.UnauthorizedException('Account is suspended or deleted');
        }
        const isPasswordValid = await bcrypt.compare(loginDto.password, user.passwordHash);
        if (!isPasswordValid) {
            throw new common_1.UnauthorizedException('Invalid email or password');
        }
        if (loginDto.deviceId) {
            await this.prisma.user.update({
                where: { id: user.id },
                data: { deviceId: loginDto.deviceId },
            });
        }
        const tokens = await this.generateTokens(user.id, user.email, user.role);
        return {
            user: this.sanitizeUser(user),
            wallet: user.wallet,
            ...tokens,
        };
    }
    async refreshToken(refreshTokenDto) {
        const storedToken = await this.prisma.refreshToken.findUnique({
            where: { token: refreshTokenDto.refreshToken },
            include: { user: true },
        });
        if (!storedToken) {
            throw new common_1.UnauthorizedException('Invalid refresh token');
        }
        if (new Date() > storedToken.expiresAt) {
            await this.prisma.refreshToken.delete({
                where: { id: storedToken.id },
            });
            throw new common_1.UnauthorizedException('Refresh token has expired');
        }
        if (storedToken.user.status !== 'ACTIVE') {
            throw new common_1.UnauthorizedException('Account is suspended or deleted');
        }
        await this.prisma.refreshToken.delete({
            where: { id: storedToken.id },
        });
        const tokens = await this.generateTokens(storedToken.user.id, storedToken.user.email, storedToken.user.role);
        return tokens;
    }
    async logout(userId, refreshToken) {
        if (refreshToken) {
            await this.prisma.refreshToken.deleteMany({
                where: {
                    userId,
                    token: refreshToken,
                },
            });
        }
        else {
            await this.prisma.refreshToken.deleteMany({
                where: { userId },
            });
        }
        return { message: 'Logged out successfully' };
    }
    async validateUser(userId) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { wallet: true },
        });
        if (!user || user.status !== 'ACTIVE') {
            throw new common_1.UnauthorizedException('User not found or inactive');
        }
        return this.sanitizeUser(user);
    }
    async generateTokens(userId, email, role) {
        const payload = { sub: userId, email, role };
        const expiresInSeconds = 900;
        const accessToken = this.jwtService.sign(payload, {
            expiresIn: expiresInSeconds,
        });
        const refreshToken = (0, uuid_1.v4)();
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + this.REFRESH_TOKEN_DAYS);
        await this.prisma.refreshToken.create({
            data: {
                userId,
                token: refreshToken,
                expiresAt,
            },
        });
        return {
            accessToken,
            refreshToken,
            expiresIn: '15m',
        };
    }
    sanitizeUser(user) {
        const { passwordHash, pinHash, ...sanitized } = user;
        return sanitized;
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService,
        config_1.ConfigService])
], AuthService);
//# sourceMappingURL=auth.service.js.map