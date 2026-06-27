import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type PortfolioInsightDocument = HydratedDocument<PortfolioInsight>;

@Schema({
  timestamps: true,
})
export class PortfolioInsight {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  })
  userId: Types.ObjectId;

  @Prop({
    type: Object,
    required: true,
  })
  insights: Record<string, any>;
}

export const PortfolioInsightSchema =
  SchemaFactory.createForClass(PortfolioInsight);

PortfolioInsightSchema.index({ userId: 1, createdAt: -1 });
