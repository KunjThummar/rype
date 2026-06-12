import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type MutualFundDocument = HydratedDocument<MutualFund>;

@Schema({
  timestamps: true,
})
export class MutualFund {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  userId: Types.ObjectId;

  @Prop({
    required: true,
  })
  fundName: string;

  @Prop()
  amfiCode: string;

  @Prop({
    required: true,
  })
  units: number;

  @Prop({
    required: true,
  })
  purchaseNav: number;

  @Prop({
    required: true,
  })
  currentNav: number;

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
}

export const MutualFundSchema = SchemaFactory.createForClass(MutualFund);
