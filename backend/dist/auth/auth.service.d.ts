import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto, LoginDto, RefreshTokenDto } from './dto';
export declare class AuthService {
    private readonly prisma;
    private readonly jwtService;
    private readonly configService;
    private readonly SALT_ROUNDS;
    private readonly REFRESH_TOKEN_DAYS;
    constructor(prisma: PrismaService, jwtService: JwtService, configService: ConfigService);
    register(registerDto: RegisterDto): Promise<{
        accessToken: string;
        refreshToken: string;
        expiresIn: string;
        user: any;
    }>;
    login(loginDto: LoginDto): Promise<{
        accessToken: string;
        refreshToken: string;
        expiresIn: string;
        user: any;
        wallet: {
            id: string;
            status: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            balance: number;
            currency: string;
        } | null;
    }>;
    refreshToken(refreshTokenDto: RefreshTokenDto): Promise<{
        accessToken: string;
        refreshToken: string;
        expiresIn: string;
    }>;
    logout(userId: string, refreshToken?: string): Promise<{
        message: string;
    }>;
    validateUser(userId: string): Promise<any>;
    private generateTokens;
    private sanitizeUser;
}
