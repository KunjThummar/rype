import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { Stock, StockSchema } from '../stocks/schemas/stock.schema';
import {
  MutualFund,
  MutualFundSchema,
} from '../mutual-funds/schemas/mutual-fund.schema';
import { TaxLot, TaxLotSchema } from '../tax-lots/schemas/tax-lot.schema';
import {
  Dividend,
  DividendSchema,
} from '../dividends/schemas/dividend.schema';
import {
  Transaction,
  TransactionSchema,
} from '../transactions/schemas/transaction.schema';
import {
  PortfolioInsight,
  PortfolioInsightSchema,
} from './schemas/portfolio-insight.schema';
import { PortfolioIntelligenceController } from './portfolio-intelligence.controller';
import { PortfolioIntelligenceService } from './portfolio-intelligence.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Stock.name, schema: StockSchema },
      { name: MutualFund.name, schema: MutualFundSchema },
      { name: TaxLot.name, schema: TaxLotSchema },
      { name: Dividend.name, schema: DividendSchema },
      { name: Transaction.name, schema: TransactionSchema },
      { name: PortfolioInsight.name, schema: PortfolioInsightSchema },
    ]),
  ],
  controllers: [PortfolioIntelligenceController],
  providers: [PortfolioIntelligenceService],
})
export class PortfolioIntelligenceModule {}
