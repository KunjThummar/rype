import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type TransactionDocument = HydratedDocument<Transaction>;

@Schema({
  timestamps: true,
})
export class Transaction {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  userId: Types.ObjectId;

  @Prop({
    required: true,
  })
  assetType: string;

  @Prop({
    required: true,
  })
  assetName: string;

  @Prop({
    required: true,
  })
  symbol: string;

  @Prop({
    required: true,
  })
  transactionType: string;

  @Prop({
    required: true,
  })
  quantity: number;

  @Prop({
    required: true,
  })
  price: number;

  @Prop({
    default: 0,
  })
  realizedProfit: number;

  @Prop({
    required: true,
  })
  transactionDate: Date;
}

export const TransactionSchema = SchemaFactory.createForClass(Transaction);
