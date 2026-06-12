import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';
import { TaxLotsService } from '../tax-lots/tax-lots.service';

import { Transaction, TransactionDocument } from './schemas/transaction.schema';

@Injectable()
export class TransactionsService {
  constructor(
    @InjectModel(Transaction.name)
    private transactionModel: Model<TransactionDocument>,

    private taxLotsService: TaxLotsService,
  ) {}

  async create(data: any) {
    let realizedProfit = 0;

    if (data.transactionType === 'SELL') {
      const result = await this.taxLotsService.consumeLots(
        data.userId,
        data.symbol,
        data.quantity,
        data.price,
      );

      realizedProfit = result.realizedProfit;
    }

    const transaction = await this.transactionModel.create({
      ...data,
      realizedProfit,
    });

    if (data.transactionType === 'BUY') {
      await this.taxLotsService.createBuyLot(data);
    }

    return transaction;
  }

  async findAll(userId: string) {
    return this.transactionModel
      .find({
        userId,
      })
      .sort({
        transactionDate: -1,
      });
  }

  async findByAsset(userId: string, symbol: string) {
    return this.transactionModel
      .find({
        userId,
        symbol,
      })
      .sort({
        transactionDate: 1,
      });
  }
}
