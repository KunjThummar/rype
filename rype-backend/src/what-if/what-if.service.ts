import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { TaxLot, TaxLotDocument } from '../tax-lots/schemas/tax-lot.schema';

@Injectable()
export class WhatIfService {
  constructor(
    @InjectModel(TaxLot.name)
    private taxLotModel: Model<TaxLotDocument>,
  ) {}

  async analyze(
    userId: string,
    symbol: string,
    quantity: number,
    sellPrice: number,
  ) {
    const lots = await this.taxLotModel
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

    const totalAvailable = lots.reduce(
      (sum, lot) => sum + lot.remainingQuantity,
      0,
    );

    if (quantity > totalAvailable) {
      return {
        error: 'Not enough shares available',
      };
    }

    let remaining = quantity;

    let profit = 0;

    let stcgGain = 0;

    let ltcgGain = 0;

    for (const lot of lots) {
      if (remaining <= 0) break;

      const qtyToSell = Math.min(remaining, lot.remainingQuantity);

      const gain = (sellPrice - lot.buyPrice) * qtyToSell;

      const holdingDays = Math.floor(
        (Date.now() - new Date(lot.buyDate).getTime()) / (1000 * 60 * 60 * 24),
      );

      if (holdingDays >= 365) {
        ltcgGain += gain;
      } else {
        stcgGain += gain;
      }

      profit += gain;

      remaining -= qtyToSell;
    }

    const stcgTax = stcgGain * 0.2;

    const ltcgTax = ltcgGain * 0.125;

    const estimatedTax = stcgTax + ltcgTax;

    const netProfit = profit - estimatedTax;

    let recommendation = 'HOLD';

    if (netProfit > 0) {
      recommendation = 'SELL';
    }

    if (estimatedTax > netProfit * 0.3) {
      recommendation = 'WAIT_FOR_LTCG';
    }

    const potentialTaxSaving = stcgGain * 0.075;

    return {
      symbol,

      quantity,

      estimatedProfit: profit,

      stcgGain,

      ltcgGain,

      estimatedTax,

      netProfit,

      potentialTaxSaving,

      recommendation,

      remainingQuantity: totalAvailable - quantity,
    };
  }
}
