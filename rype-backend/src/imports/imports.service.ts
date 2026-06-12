import { Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { ImportJob, ImportJobDocument } from './schemas/import-job.schema';

@Injectable()
export class ImportsService {
  constructor(
    @InjectModel(ImportJob.name)
    private importModel: Model<ImportJobDocument>,
  ) {}

  async createJob(data: any) {
    return this.importModel.create(data);
  }

  async findAll(userId: string) {
    return this.importModel.find({
      userId,
    });
  }
}
