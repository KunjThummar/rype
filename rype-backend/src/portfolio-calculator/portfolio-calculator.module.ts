import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundSchema,
} from '../mutual-funds/schemas/mutual-fund.schema';

import { PortfolioCalculatorService } from './portfolio-calculator.service';

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
  providers: [PortfolioCalculatorService],
  exports: [PortfolioCalculatorService],
})
export class PortfolioCalculatorModule {}
