import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { Dividend, DividendDocument } from './schemas/dividend.schema';

@Injectable()
export class DividendsService {
  constructor(
    @InjectModel(Dividend.name)
    private dividendModel: Model<DividendDocument>,
  ) {}

  async create(data: any) {
    return this.dividendModel.create(data);
  }

  async findAll(userId: string) {
    return this.dividendModel
      .find({
        userId,
      })
      .sort({
        dividendDate: -1,
      });
  }

  async getSummary(userId: string) {
    const dividends = await this.dividendModel.find({
      userId,
    });

    const totalDividends = dividends.reduce(
      (sum, dividend) => sum + dividend.dividendAmount,
      0,
    );

    return {
      totalDividends,
      dividendCount: dividends.length,
    };
  }
}
