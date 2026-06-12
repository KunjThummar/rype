import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { Transaction, TransactionSchema } from './schemas/transaction.schema';

import { TransactionsController } from './transactions.controller';
import { TransactionsService } from './transactions.service';
import { TaxLotsModule } from '../tax-lots/tax-lots.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: Transaction.name,
        schema: TransactionSchema,
      },
    ]),
    TaxLotsModule,
  ],
  controllers: [TransactionsController],
  providers: [TransactionsService],
  exports: [TransactionsService],
})
export class TransactionsModule {}
