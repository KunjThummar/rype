import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundSchema,
} from '../mutual-funds/schemas/mutual-fund.schema';

import { AnalyticsController } from './analytics.controller';
import { AnalyticsService } from './analytics.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Stock.name,
        schema: StockSchema,
      },
      {
        name: MutualFund.name,
        schema: MutualFundSchema,
      },
    ]),
  ],
  controllers: [AnalyticsController],
  providers: [AnalyticsService],
})
export class AnalyticsModule {}
