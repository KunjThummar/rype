import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { MutualFund, MutualFundSchema } from './schemas/mutual-fund.schema';

import { MutualFundsController } from './mutual-funds.controller';
import { MutualFundsService } from './mutual-funds.service';
import { MarketDataModule } from '../market-data/market-data.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: MutualFund.name,
        schema: MutualFundSchema,
      },
    ]),
    MarketDataModule,
  ],
  controllers: [MutualFundsController],
  providers: [MutualFundsService],
})
export class MutualFundsModule {}
