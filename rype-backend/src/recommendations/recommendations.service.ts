import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';

import {
  MutualFund,
  MutualFundDocument,
} from '../mutual-funds/schemas/mutual-fund.schema';

@Injectable()
export class RecommendationsService {
  constructor(
    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,

    @InjectModel(MutualFund.name)
    private mfModel: Model<MutualFundDocument>,
  ) {}

  async getRecommendations(userId: string) {
    const recommendations: any[] = [];

    const stocks = await this.stockModel.find({
      userId,
    });

    for (const stock of stocks) {
      const profitPercent = stock.profitPercent;

      if (profitPercent >= 20) {
        recommendations.push({
          assetType: 'STOCK',
          symbol: stock.symbol,
          action: 'SELL',
          reason: 'Profit target reached',
          profitPercent: Number(profitPercent.toFixed(2)),
        });
      } else {
        recommendations.push({
          assetType: 'STOCK',
          symbol: stock.symbol,
          action: 'HOLD',
          reason: 'Profit target not reached',
          profitPercent: Number(profitPercent.toFixed(2)),
        });
      }
    }

    const funds = await this.mfModel.find({
      userId,
    });

    for (const fund of funds) {
      const profitPercent = fund.profitPercent;

      if (profitPercent >= 15) {
        recommendations.push({
          assetType: 'MUTUAL_FUND',

          fundName: fund.fundName,

          action: 'PARTIAL_REDEEM',

          reason: 'Book partial profits',

          profitPercent: Number(profitPercent.toFixed(2)),
        });
      } else {
        recommendations.push({
          assetType: 'MUTUAL_FUND',

          fundName: fund.fundName,

          action: 'HOLD',

          reason: 'Continue investment',

          profitPercent: Number(profitPercent.toFixed(2)),
        });
      }
    }

    return recommendations;
  }
}
