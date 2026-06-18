import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type StockDocument = HydratedDocument<Stock>;

@Schema({
  timestamps: true,
})
export class Stock {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  userId: Types.ObjectId;

  @Prop({
    required: true,
  })
  stockName: string;

  @Prop({
    required: true,
  })
  symbol: string;

  @Prop({
    required: true,
  })
  quantity: number;

  @Prop({
    required: true,
  })
  buyPrice: number;

  @Prop({
    required: true,
  })
  currentPrice: number;

  @Prop({
    default: 0,
  })
  investmentAmount: number;

  @Prop({
    default: 0,
  })
  currentValue: number;

  @Prop({
    default: 0,
  })
  profitLoss: number;

  @Prop({
    default: 0,
  })
  profitPercent: number;

  @Prop({
    default: 0,
  })
  todaysGainLoss: number;
}

export const StockSchema = SchemaFactory.createForClass(Stock);
