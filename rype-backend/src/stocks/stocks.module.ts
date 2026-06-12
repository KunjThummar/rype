import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Stock, StockSchema } from './schemas/stock.schema';

import { StocksController } from './stocks.controller';
import { StocksService } from './stocks.service';
import { TransactionsModule } from '../transactions/transactions.module';
import { MarketDataModule } from '../market-data/market-data.module';
import { PortfolioModule } from '../portfolio/portfolio.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Stock.name,
        schema: StockSchema,
      },
    ]),
    TransactionsModule,
    MarketDataModule,
    PortfolioModule,
  ],
  controllers: [StocksController],
  providers: [StocksService],
})
export class StocksModule {}
