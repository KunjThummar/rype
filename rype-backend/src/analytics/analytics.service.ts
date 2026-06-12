import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundDocument,
} from '../mutual-funds/schemas/mutual-fund.schema';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    @InjectModel(MutualFund.name)
    private mfModel: Model<MutualFundDocument>,
  ) {}

  async getAllocation(userId: string) {
    const stocks = await this.stockModel.find({
      userId,
    });

    const mutualFunds = await this.mfModel.find({
      userId,
    });

    const stockValue = stocks.reduce(
      (sum, stock) => sum + stock.currentValue,
      0,
    );

    const mfValue = mutualFunds.reduce((sum, mf) => sum + mf.currentValue, 0);

    const totalPortfolioValue = stockValue + mfValue;

    return {
      totalPortfolioValue,

      allocation: [
        {
          category: 'Stocks',

          value: stockValue,

          percentage:
            totalPortfolioValue > 0
              ? Number(((stockValue / totalPortfolioValue) * 100).toFixed(2))
              : 0,
        },

        {
          category: 'Mutual Funds',

          value: mfValue,

          percentage:
            totalPortfolioValue > 0
              ? Number(((mfValue / totalPortfolioValue) * 100).toFixed(2))
              : 0,
        },
      ],
    };
  }
}
