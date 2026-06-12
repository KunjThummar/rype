import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type AlertDocument = HydratedDocument<Alert>;

@Schema({
  timestamps: true,
})
export class Alert {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  userId: Types.ObjectId;

  @Prop({
    required: true,
  })
  symbol: string;

  @Prop({
    required: true,
  })
  targetProfitPercent: number;

  @Prop({
    default: false,
  })
  triggered: boolean;
}

export const AlertSchema = SchemaFactory.createForClass(Alert);
