import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundDocument,
} from '../mutual-funds/schemas/mutual-fund.schema';

@Injectable()
export class PortfolioCalculatorService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    @InjectModel(MutualFund.name)
    private mutualFundModel: Model<MutualFundDocument>,
  ) {}

  async calculatePortfolio(userId: string) {
    const stocks = await this.stockModel.find({
      userId,
    });

    const funds = await this.mutualFundModel.find({
      userId,
    });

    let totalInvestment = 0;
    let currentValue = 0;

    for (const stock of stocks) {
      totalInvestment += stock.buyPrice * stock.quantity;

      currentValue += stock.currentPrice * stock.quantity;
    }

    for (const fund of funds) {
      totalInvestment += fund.purchaseNav * fund.units;

      currentValue += fund.currentNav * fund.units;
    }

    const totalProfitLoss = currentValue - totalInvestment;

    const profitPercent =
      totalInvestment > 0
        ? ((totalProfitLoss / totalInvestment) * 100).toFixed(2)
        : 0;

    return {
      totalInvestment,

      currentValue,

      totalProfitLoss,

      profitPercent,
    };
  }
}
