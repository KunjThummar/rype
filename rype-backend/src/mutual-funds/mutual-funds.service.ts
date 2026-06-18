import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { MutualFund, MutualFundDocument } from './schemas/mutual-fund.schema';
import { MarketDataService } from '../market-data/market-data.service';

@Injectable()
export class MutualFundsService {
  constructor(
    @InjectModel(MutualFund.name)
    private mfModel: Model<MutualFundDocument>,

    private marketDataService: MarketDataService,
  ) {}

  async create(data: any) {
    const investmentAmount = data.units * data.purchaseNav;

    const currentValue = data.units * data.currentNav;

    const profitLoss = currentValue - investmentAmount;

    const profitPercent = (profitLoss / investmentAmount) * 100;

    return this.mfModel.create({
      ...data,
      investmentAmount,
      currentValue,
      profitLoss,
      profitPercent,
    });
  }

  async findAll(userId: string) {
    return this.mfModel.find({
      userId,
    });
  }

  async getNav(amfiCode: string) {
    return this.marketDataService.getNav(amfiCode);
  }

  async findOne(id: string) {
    return this.mfModel.findById(id);
  }

  async update(id: string, body: any) {
    return this.mfModel.findByIdAndUpdate(id, body, {
      new: true,
    });
  }

  async delete(id: string) {
    return this.mfModel.findByIdAndDelete(id);
  }

  async refreshNavs(userId: string) {
    const funds = await this.mfModel.find({
      userId,
    });

    for (const fund of funds) {
      const navData = await this.marketDataService.getNav(fund.amfiCode);

      if (navData.nav === null || navData.nav <= 0) {
        continue;
      }

      fund.currentNav = navData.nav;

      fund.currentValue = fund.units * fund.currentNav;

      fund.profitLoss = fund.currentValue - fund.investmentAmount;

      fund.profitPercent =
        fund.investmentAmount > 0
          ? (fund.profitLoss / fund.investmentAmount) * 100
          : 0;

      await fund.save();
    }

    return {
      success: true,
    };
  }
}
