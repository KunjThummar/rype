import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import { HydratedDocument, Types } from 'mongoose';

export type ImportJobDocument = HydratedDocument<ImportJob>;

@Schema({
  timestamps: true,
})
export class ImportJob {
  @Prop({
    type: Types.ObjectId,
    ref: 'User',
  })
  userId: Types.ObjectId;

  @Prop()
  fileName: string;

  @Prop()
  filePath: string;

  @Prop()
  importType: string;

  @Prop({
    default: 'PENDING',
  })
  status: string;
}

export const ImportJobSchema = SchemaFactory.createForClass(ImportJob);
