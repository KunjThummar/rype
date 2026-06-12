import { Module } from '@nestjs/common';

import { MongooseModule } from '@nestjs/mongoose';

import { ImportJob, ImportJobSchema } from './schemas/import-job.schema';

import { ImportsController } from './imports.controller';
import { ImportsService } from './imports.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: ImportJob.name,
        schema: ImportJobSchema,
      },
    ]),
  ],
  controllers: [ImportsController],
  providers: [ImportsService],
})
export class ImportsModule {}
