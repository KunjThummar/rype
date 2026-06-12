import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import { TaxLot, TaxLotDocument } from './schemas/tax-lot.schema';

import { TaxRealizationsService } from '../tax-realizations/tax-realizations.service';

@Injectable()
export class TaxLotsService {
  constructor(
    @InjectModel(TaxLot.name)
    private taxLotModel: Model<TaxLotDocument>,

    private taxRealizationsService: TaxRealizationsService,
  ) {}

  async createBuyLot(data: any) {
    return this.taxLotModel.create({
      userId: data.userId,
      symbol: data.symbol,
      quantity: data.quantity,
      remainingQuantity: data.quantity,
      buyPrice: data.price,
      buyDate: data.transactionDate,
    });
  }

  async consumeLots(
    userId: string,
    symbol: string,
    sellQuantity: number,
    sellPrice: number,
  ) {
    const lots = await this.getLots(userId, symbol);

    const totalAvailable = lots.reduce(
      (sum, lot) => sum + lot.remainingQuantity,
      0,
    );

    if (sellQuantity > totalAvailable) {
      throw new Error('Not enough shares available');
    }

    let remaining = sellQuantity;

    let realizedProfit = 0;

    for (const lot of lots) {
      if (remaining <= 0) break;

      const qtyToSell = Math.min(remaining, lot.remainingQuantity);

      realizedProfit += (sellPrice - lot.buyPrice) * qtyToSell;

      const gain = (sellPrice - lot.buyPrice) * qtyToSell;

      const holdingDays = Math.floor(
        (new Date().getTime() - new Date(lot.buyDate).getTime()) /
          (1000 * 60 * 60 * 24),
      );

      const taxType = holdingDays >= 365 ? 'LTCG' : 'STCG';

      await this.taxRealizationsService.create({
        userId,
        symbol,
        quantity: qtyToSell,
        buyPrice: lot.buyPrice,
        sellPrice,
        buyDate: lot.buyDate,
        sellDate: new Date(),
        gain,
        holdingDays,
        taxType,
      });
      lot.remainingQuantity -= qtyToSell;

      await lot.save();

      remaining -= qtyToSell;
    }

    return {
      realizedProfit,
    };
  }

  async calculateTax(buyDate: Date, sellDate: Date, gain: number) {
    const holdingDays = Math.floor(
      (new Date(sellDate).getTime() - new Date(buyDate).getTime()) /
        (1000 * 60 * 60 * 24),
    );

    const isLTCG = holdingDays >= 365;

    let estimatedTax = 0;

    if (isLTCG) {
      estimatedTax = gain * 0.125;
    } else {
      estimatedTax = gain * 0.2;
    }

    return {
      holdingDays,
      taxType: isLTCG ? 'LTCG' : 'STCG',
      estimatedTax,
    };
  }

  async getLots(userId: string, symbol: string) {
    return this.taxLotModel
      .find({
        userId,
        symbol,
        remainingQuantity: {
          $gt: 0,
        },
      })
      .sort({
        buyDate: 1,
      });
  }
}
