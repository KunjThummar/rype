import {
  Controller,
  Get,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';

import { FileInterceptor } from '@nestjs/platform-express';

import { diskStorage } from 'multer';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { ImportsService } from './imports.service';

@Controller('imports')
export class ImportsController {
  constructor(private importsService: ImportsService) {}

  @UseGuards(JwtAuthGuard)
  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',

        filename: (req, file, callback) => {
          callback(null, Date.now() + '-' + file.originalname);
        },
      }),
    }),
  )
  async upload(
    @Req() req,

    @UploadedFile()
    file: Express.Multer.File,
  ) {
    return this.importsService.createJob({
      userId: req.user.userId,

      fileName: file.originalname,

      filePath: file.path,

      importType: 'MANUAL_IMPORT',

      status: 'PENDING',
    });
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  getJobs(@Req() req) {
    return this.importsService.findAll(req.user.userId);
  }
}
