import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundSchema,
} from '../mutual-funds/schemas/mutual-fund.schema';

import { BenchmarkModule } from '../benchmark/benchmark.module';

import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';

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

    BenchmarkModule,
  ],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
