import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import {
  Transaction,
  TransactionSchema,
} from '../transactions/schemas/transaction.schema';

import { TaxLot, TaxLotSchema } from '../tax-lots/schemas/tax-lot.schema';

import { TaxReportController } from './tax-report.controller';
import { TaxReportService } from './tax-report.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Transaction.name,
        schema: TransactionSchema,
      },
      {
        name: TaxLot.name,
        schema: TaxLotSchema,
      },
    ]),
  ],
  controllers: [TaxReportController],
  providers: [TaxReportService],
})
export class TaxReportModule {}
