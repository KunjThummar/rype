import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import {
  Transaction,
  TransactionDocument,
} from '../transactions/schemas/transaction.schema';

@Injectable()
export class TaxReportService {
  constructor(
    @InjectModel(Transaction.name)
    private transactionModel: Model<TransactionDocument>,
  ) {}

  async getSummary(userId: string) {
    const sells = await this.transactionModel.find({
      userId,
      transactionType: 'SELL',
    });

    const totalProfit = sells.reduce(
      (sum, tx) => sum + (tx.realizedProfit || 0),
      0,
    );

    return {
      totalProfit,
      sellTransactions: sells.length,
    };
  }
}
