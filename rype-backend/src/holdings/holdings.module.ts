import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import {
  Transaction,
  TransactionSchema,
} from '../transactions/schemas/transaction.schema';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';

import { HoldingsController } from './holdings.controller';
import { HoldingsService } from './holdings.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Transaction.name,
        schema: TransactionSchema,
      },
      {
        name: Stock.name,
        schema: StockSchema,
      },
    ]),
  ],
  controllers: [HoldingsController],
  providers: [HoldingsService],
})
export class HoldingsModule {}
