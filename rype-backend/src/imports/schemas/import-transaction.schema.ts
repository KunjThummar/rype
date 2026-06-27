import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type ImportTransactionDocument = HydratedDocument<ImportTransaction>;

@Schema({
  timestamps: true,
})
export class ImportTransaction {
  @Prop({
    type: Types.ObjectId,
    ref: 'PortfolioImport',
    required: true,
    index: true,
  })
  importId: Types.ObjectId;

  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  })
  userId: Types.ObjectId;

  @Prop({
    required: true,
    uppercase: true,
    trim: true,
    index: true,
  })
  symbol: string;

  @Prop({
    required: true,
    enum: ['STOCK', 'MUTUAL_FUND'],
    default: 'STOCK',
  })
  assetType: string;

  @Prop({
    trim: true,
  })
  assetName: string;

  @Prop({
    required: true,
    min: 0.000001,
  })
  quantity: number;

  @Prop({
    required: true,
    min: 0.000001,
  })
  buyPrice: number;

  @Prop({
    required: true,
  })
  buyDate: Date;

  @Prop({
    required: true,
    trim: true,
  })
  sourceFile: string;

  @Prop({
    trim: true,
  })
  sourceType: string;

  @Prop({
    trim: true,
  })
  folioNumber: string;

  @Prop({
    default: 0,
    min: 0,
  })
  investedAmount: number;
}

export const ImportTransactionSchema =
  SchemaFactory.createForClass(ImportTransaction);

ImportTransactionSchema.index(
  {
    userId: 1,
    importId: 1,
    symbol: 1,
    quantity: 1,
    buyPrice: 1,
    buyDate: 1,
    sourceFile: 1,
  },
  { unique: true },
);
