import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, RefreshTokenDto } from './dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
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
    logout(userId: string, body: {
        refreshToken?: string;
    }): Promise<{
        message: string;
    }>;
    getCurrentUser(userId: string): Promise<any>;
}
