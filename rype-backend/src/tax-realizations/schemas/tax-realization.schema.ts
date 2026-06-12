import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type TaxRealizationDocument = HydratedDocument<TaxRealization>;

@Schema({
  timestamps: true,
})
export class TaxRealization {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
  })
  userId: Types.ObjectId;

  @Prop()
  symbol: string;

  @Prop()
  quantity: number;

  @Prop()
  buyPrice: number;

  @Prop()
  sellPrice: number;

  @Prop()
  buyDate: Date;

  @Prop()
  sellDate: Date;

  @Prop()
  gain: number;

  @Prop()
  holdingDays: number;

  @Prop()
  taxType: string;
}

export const TaxRealizationSchema =
  SchemaFactory.createForClass(TaxRealization);
