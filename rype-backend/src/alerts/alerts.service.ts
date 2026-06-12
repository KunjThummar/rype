import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Alert, AlertDocument } from './schemas/alert.schema';

import { Stock, StockDocument } from '../stocks/schemas/stock.schema';

@Injectable()
export class AlertsService {
  constructor(
    @InjectModel(Alert.name)
    private alertModel: Model<AlertDocument>,

    @InjectModel(Stock.name)
    private stockModel: Model<StockDocument>,
  ) {}

  async create(data: any) {
    return this.alertModel.create(data);
  }

  async getAlerts(userId: string) {
    return this.alertModel.find({
      userId,
    });
  }

  async evaluateAlerts(userId: string) {
    const alerts = await this.alertModel.find({
      userId,
    });

    const results: any[] = [];

    for (const alert of alerts) {
      const stock = await this.stockModel.findOne({
        userId,
        symbol: alert.symbol,
      });

      if (!stock) continue;

      const triggered = stock.profitPercent >= alert.targetProfitPercent;

      if (triggered && !alert.triggered) {
        alert.triggered = true;
        await alert.save();
      }

      results.push({
        symbol: alert.symbol,

        targetProfitPercent: alert.targetProfitPercent,

        currentProfitPercent: Number(stock.profitPercent.toFixed(2)),

        triggered,
      });
    }

    return results;
  }
}
