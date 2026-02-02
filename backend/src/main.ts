import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Enable CORS for mobile app
  app.enableCors({
    origin: true, // Allow all origins in development
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept-Language'],
    credentials: true,
  });

  // Global validation pipe with transformation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Strip unknown properties
      transform: true, // Transform payloads to DTO instances
      forbidNonWhitelisted: true, // Throw error for unknown properties
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  const port = configService.get<number>('port') || 3000;

  await app.listen(port);
  console.log(`🚀 NFC Wallet Backend running on http://localhost:${port}`);
  console.log(`📱 API Base URL: http://localhost:${port}/api`);
}

bootstrap();
