import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { PortfolioModule } from '../portfolio/portfolio.module';
import { Stock, StockSchema } from '../stocks/schemas/stock.schema';
import {
  MutualFund,
  MutualFundSchema,
} from '../mutual-funds/schemas/mutual-fund.schema';
import {
  Transaction,
  TransactionSchema,
} from '../transactions/schemas/transaction.schema';
import { ImportsController } from './imports.controller';
import { ImportsService } from './imports.service';
import { PortfolioMergeService } from './portfolio-merge.service';
import {
  ImportTransaction,
  ImportTransactionSchema,
} from './schemas/import-transaction.schema';
import {
  PortfolioImport,
  PortfolioImportSchema,
} from './schemas/portfolio-import.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: PortfolioImport.name,
        schema: PortfolioImportSchema,
      },
      {
        name: ImportTransaction.name,
        schema: ImportTransactionSchema,
      },
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
    ]),
    PortfolioModule,
  ],
  controllers: [ImportsController],
  providers: [ImportsService, PortfolioMergeService],
})
export class ImportsModule {}
