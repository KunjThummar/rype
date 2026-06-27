import {
  BadRequestException,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ImportsService } from './imports.service';

const MAX_IMPORT_FILE_SIZE = 12 * 1024 * 1024;
const ALLOWED_IMPORT_EXTENSIONS = [
  '.csv',
  '.xlsx',
  '.pdf',
  '.png',
  '.jpg',
  '.jpeg',
  '.webp',
];

@Controller('imports')
@UseGuards(JwtAuthGuard)
export class ImportsController {
  constructor(private importsService: ImportsService) {}

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: {
        fileSize: MAX_IMPORT_FILE_SIZE,
      },
      fileFilter: (_req, file, callback) => {
        const fileName = file.originalname.toLowerCase();
        const allowed = ALLOWED_IMPORT_EXTENSIONS.some((extension) =>
          fileName.endsWith(extension),
        );

        if (!allowed) {
          callback(
            new BadRequestException(
              'Only CSV, XLSX, PDF, PNG, JPG, JPEG and WEBP files are supported.',
            ),
            false,
          );
          return;
        }

        callback(null, true);
      },
    }),
  )
  upload(@Req() req, @UploadedFile() file: Express.Multer.File) {
    return this.importsService.upload(req.user.userId, file);
  }

  @Get('history')
  getHistory(@Req() req) {
    return this.importsService.findHistory(req.user.userId);
  }

  @Get(':id')
  getImport(@Req() req, @Param('id') id: string) {
    return this.importsService.findOne(req.user.userId, id);
  }

  @Delete(':id')
  deleteImport(@Req() req, @Param('id') id: string) {
    return this.importsService.delete(req.user.userId, id);
  }
}
