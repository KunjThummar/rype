import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundSchema,
} from '../mutual-funds/schemas/mutual-fund.schema';

import { RecommendationsController } from './recommendations.controller';
import { RecommendationsService } from './recommendations.service';

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
  controllers: [RecommendationsController],
  providers: [RecommendationsService],
})
export class RecommendationsModule {}
