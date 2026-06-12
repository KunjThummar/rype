import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type DividendDocument = HydratedDocument<Dividend>;

@Schema({
  timestamps: true,
})
export class Dividend {
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
  companyName: string;

  @Prop({
    required: true,
  })
  dividendAmount: number;

  @Prop({
    required: true,
  })
  dividendDate: Date;
}

export const DividendSchema = SchemaFactory.createForClass(Dividend);
