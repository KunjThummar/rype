import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { Portfolio, PortfolioSchema } from './schemas/portfolio.schema';

import { PortfolioController } from './portfolio.controller';
import { PortfolioService } from './portfolio.service';
import { PortfolioCalculatorModule } from '../portfolio-calculator/portfolio-calculator.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Portfolio.name,
        schema: PortfolioSchema,
      },
    ]),
    PortfolioCalculatorModule,
  ],
  controllers: [PortfolioController],
  providers: [PortfolioService],
  exports: [PortfolioService],
})
export class PortfolioModule {}
