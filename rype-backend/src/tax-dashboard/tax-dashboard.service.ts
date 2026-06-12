import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import {
  TaxRealization,
  TaxRealizationDocument,
} from '../tax-realizations/schemas/tax-realization.schema';

@Injectable()
export class TaxDashboardService {
  constructor(
    @InjectModel(TaxRealization.name)
    private realizationModel: Model<TaxRealizationDocument>,
  ) {}

  async getDashboard(userId: string) {
    const realizations = await this.realizationModel.find({
      userId,
    });

    const stcgGain = realizations
      .filter((r) => r.taxType === 'STCG')
      .reduce((sum, record) => sum + record.gain, 0);

    const ltcgGain = realizations
      .filter((r) => r.taxType === 'LTCG')
      .reduce((sum, record) => sum + record.gain, 0);

    const stcgTax = stcgGain * 0.2;

    const ltcgTax = ltcgGain * 0.125;

    const totalLoss = realizations
      .filter((r) => r.gain < 0)
      .reduce((sum, record) => sum + Math.abs(record.gain), 0);

    const netGain = stcgGain + ltcgGain - totalLoss;

    const adjustedStcg = Math.max(0, stcgGain - totalLoss);

    const effectiveTax = adjustedStcg * 0.2 + ltcgTax;

    let taxEfficiency = 100;

    if (netGain > 0) {
      taxEfficiency = Number(
        (((netGain - effectiveTax) / netGain) * 100).toFixed(2),
      );
    }

    return {
      stcgGain,

      ltcgGain,

      totalLoss,

      netGain,

      stcgTax,

      ltcgTax,

      totalGain: stcgGain + ltcgGain,

      totalTax: stcgTax + ltcgTax,

      effectiveTax,

      taxEfficiency,
    };
  }
}
