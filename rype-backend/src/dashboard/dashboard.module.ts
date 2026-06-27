import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundSchema,
} from '../mutual-funds/schemas/mutual-fund.schema';

import { BenchmarkModule } from '../benchmark/benchmark.module';
import {
  Transaction,
  TransactionSchema,
} from '../transactions/schemas/transaction.schema';
import { Dividend, DividendSchema } from '../dividends/schemas/dividend.schema';

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
      {
        name: Transaction.name,
        schema: TransactionSchema,
      },
      {
        name: Dividend.name,
        schema: DividendSchema,
      },
    ]),

    BenchmarkModule,
  ],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
