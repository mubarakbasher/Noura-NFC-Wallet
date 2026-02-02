import {
    Injectable,
    UnauthorizedException,
    ConflictException,
    BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto, LoginDto, RefreshTokenDto } from './dto';

@Injectable()
export class AuthService {
    private readonly SALT_ROUNDS = 12;
    private readonly REFRESH_TOKEN_DAYS = 7;

    constructor(
        private readonly prisma: PrismaService,
        private readonly jwtService: JwtService,
        private readonly configService: ConfigService,
    ) { }

    async register(registerDto: RegisterDto) {
        // Check if email already exists
        const existingUser = await this.prisma.user.findUnique({
            where: { email: registerDto.email },
        });

        if (existingUser) {
            throw new ConflictException('Email already registered');
        }

        // Hash password
        const passwordHash = await bcrypt.hash(registerDto.password, this.SALT_ROUNDS);

        // Create user and wallet in a transaction
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

            // Create wallet for the user with SDG currency and test balance
            await tx.wallet.create({
                data: {
                    userId: newUser.id,
                    balance: 1000, // Starting test balance
                    currency: 'SDG',
                    status: 'ACTIVE',
                },
            });

            return newUser;
        });

        // Generate tokens
        const tokens = await this.generateTokens(user.id, user.email, user.role);

        return {
            user: this.sanitizeUser(user),
            ...tokens,
        };
    }

    async login(loginDto: LoginDto) {
        // Find user by email
        const user = await this.prisma.user.findUnique({
            where: { email: loginDto.email },
            include: { wallet: true },
        });

        if (!user) {
            throw new UnauthorizedException('Invalid email or password');
        }

        if (user.status !== 'ACTIVE') {
            throw new UnauthorizedException('Account is suspended or deleted');
        }

        // Verify password
        const isPasswordValid = await bcrypt.compare(loginDto.password, user.passwordHash);
        if (!isPasswordValid) {
            throw new UnauthorizedException('Invalid email or password');
        }

        // Update device ID if provided
        if (loginDto.deviceId) {
            await this.prisma.user.update({
                where: { id: user.id },
                data: { deviceId: loginDto.deviceId },
            });
        }

        // Generate tokens
        const tokens = await this.generateTokens(user.id, user.email, user.role);

        return {
            user: this.sanitizeUser(user),
            wallet: user.wallet,
            ...tokens,
        };
    }

    async refreshToken(refreshTokenDto: RefreshTokenDto) {
        // Find the refresh token in database
        const storedToken = await this.prisma.refreshToken.findUnique({
            where: { token: refreshTokenDto.refreshToken },
            include: { user: true },
        });

        if (!storedToken) {
            throw new UnauthorizedException('Invalid refresh token');
        }

        // Check if token is expired
        if (new Date() > storedToken.expiresAt) {
            // Delete the expired token
            await this.prisma.refreshToken.delete({
                where: { id: storedToken.id },
            });
            throw new UnauthorizedException('Refresh token has expired');
        }

        // Check if user is still active
        if (storedToken.user.status !== 'ACTIVE') {
            throw new UnauthorizedException('Account is suspended or deleted');
        }

        // Delete old refresh token
        await this.prisma.refreshToken.delete({
            where: { id: storedToken.id },
        });

        // Generate new tokens
        const tokens = await this.generateTokens(
            storedToken.user.id,
            storedToken.user.email,
            storedToken.user.role,
        );

        return tokens;
    }

    async logout(userId: string, refreshToken?: string) {
        if (refreshToken) {
            // Delete specific refresh token
            await this.prisma.refreshToken.deleteMany({
                where: {
                    userId,
                    token: refreshToken,
                },
            });
        } else {
            // Delete all refresh tokens for user
            await this.prisma.refreshToken.deleteMany({
                where: { userId },
            });
        }

        return { message: 'Logged out successfully' };
    }

    async validateUser(userId: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { wallet: true },
        });

        if (!user || user.status !== 'ACTIVE') {
            throw new UnauthorizedException('User not found or inactive');
        }

        return this.sanitizeUser(user);
    }

    private async generateTokens(userId: string, email: string, role: string) {
        const payload = { sub: userId, email, role };
        const expiresInSeconds = 900; // 15 minutes

        const accessToken = this.jwtService.sign(payload, {
            expiresIn: expiresInSeconds,
        });

        // Generate refresh token
        const refreshToken = uuidv4();
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + this.REFRESH_TOKEN_DAYS);

        // Store refresh token in database
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

    private sanitizeUser(user: any) {
        const { passwordHash, pinHash, ...sanitized } = user;
        return sanitized;
    }
}
