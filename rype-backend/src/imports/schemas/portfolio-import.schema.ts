import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type PortfolioImportDocument = HydratedDocument<PortfolioImport>;

export type ImportStatus = 'PENDING' | 'PROCESSING' | 'COMPLETED' | 'FAILED';

@Schema({
  timestamps: true,
})
export class PortfolioImport {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  })
  userId: Types.ObjectId;

  @Prop({
    required: true,
    trim: true,
  })
  fileName: string;

  @Prop({
    required: true,
    enum: [
      'CSV',
      'XLSX',
      'CAS_PDF',
      'BROKER_CSV',
      'BROKER_XLSX',
      'BROKER_PDF',
      'SCREENSHOT',
    ],
  })
  fileType: string;

  @Prop({
    required: true,
    default: Date.now,
  })
  uploadedAt: Date;

  @Prop({
    required: true,
    enum: ['PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'],
    default: 'PENDING',
    index: true,
  })
  status: ImportStatus;

  @Prop({
    default: 0,
    min: 0,
  })
  totalRecords: number;

  @Prop({
    default: 0,
    min: 0,
  })
  successRecords: number;

  @Prop({
    default: 0,
    min: 0,
  })
  failedRecords: number;

  @Prop({
    type: Object,
    default: {},
  })
  importSummary: Record<string, any>;
}

export const PortfolioImportSchema =
  SchemaFactory.createForClass(PortfolioImport);

PortfolioImportSchema.index({ userId: 1, uploadedAt: -1 });
