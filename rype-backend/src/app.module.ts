import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { PortfolioModule } from './portfolio/portfolio.module';
import { StocksModule } from './stocks/stocks.module';
import { MutualFundsModule } from './mutual-funds/mutual-funds.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { TransactionsModule } from './transactions/transactions.module';
import { HoldingsModule } from './holdings/holdings.module';
import { TaxLotsModule } from './tax-lots/tax-lots.module';
import { TaxReportModule } from './tax-report/tax-report.module';
import { TaxRealizationsModule } from './tax-realizations/tax-realizations.module';
import { TaxDashboardModule } from './tax-dashboard/tax-dashboard.module';
import { WhatIfModule } from './what-if/what-if.module';
import { MarketDataModule } from './market-data/market-data.module';
import { PortfolioCalculatorModule } from './portfolio-calculator/portfolio-calculator.module';
import { DividendsModule } from './dividends/dividends.module';
import { BenchmarkModule } from './benchmark/benchmark.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { RecommendationsModule } from './recommendations/recommendations.module';
import { AlertsModule } from './alerts/alerts.module';
import { ImportsModule } from './imports/imports.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    MongooseModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const uri = config.get<string>('MONGODB_URI');

        if (!uri) {
          throw new Error('MONGODB_URI is missing. Add it to your deployed backend environment variables.');
        }

        return {
          uri,
          serverSelectionTimeoutMS: 10000,
          connectTimeoutMS: 10000,
          socketTimeoutMS: 45000,
          maxPoolSize: 10,
          retryWrites: true,
          connectionFactory: (connection: Connection) => {
            connection.on('connected', () => {
              console.log('MongoDB connected');
            });
            connection.on('disconnected', () => {
              console.warn('MongoDB disconnected');
            });
            connection.on('error', (error) => {
              console.error('MongoDB connection error:', error.message);
            });

            return connection;
          },
        };
      },
    }),

    UsersModule,

    AuthModule,

    PortfolioModule,

    StocksModule,

    MutualFundsModule,

    DashboardModule,

    TransactionsModule,

    HoldingsModule,

    TaxLotsModule,

    TaxReportModule,

    TaxRealizationsModule,

    TaxDashboardModule,

    WhatIfModule,

    MarketDataModule,

    PortfolioCalculatorModule,

    DividendsModule,

    BenchmarkModule,

    AnalyticsModule,

    RecommendationsModule,

    AlertsModule,

    ImportsModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
