import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type PortfolioDocument = HydratedDocument<Portfolio>;

@Schema({
  timestamps: true,
})
export class Portfolio {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  userId: Types.ObjectId;

  @Prop({
    default: 0,
  })
  totalInvestment: number;

  @Prop({
    default: 0,
  })
  currentValue: number;

  @Prop({
    default: 0,
  })
  totalProfitLoss: number;
}

export const PortfolioSchema = SchemaFactory.createForClass(Portfolio);
