import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type TaxLotDocument = HydratedDocument<TaxLot>;

@Schema({
  timestamps: true,
})
export class TaxLot {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  userId: Types.ObjectId;

  @Prop()
  symbol: string;

  @Prop()
  quantity: number;

  @Prop()
  remainingQuantity: number;

  @Prop({
    default: 0,
  })
  realizedQuantity: number;

  @Prop()
  buyPrice: number;

  @Prop()
  buyDate: Date;
}

export const TaxLotSchema = SchemaFactory.createForClass(TaxLot);
