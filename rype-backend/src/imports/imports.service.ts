import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import {
  PortfolioImport,
  PortfolioImportDocument,
} from './schemas/portfolio-import.schema';
import {
  ImportTransaction,
  ImportTransactionDocument,
} from './schemas/import-transaction.schema';
import {
  PortfolioMergeService,
  MergeTransaction,
} from './portfolio-merge.service';
import {
  Transaction,
  TransactionDocument,
} from '../transactions/schemas/transaction.schema';
import { TableImportParser } from './parsers/table-import.parser';
import { CasPdfParser } from './parsers/cas-pdf.parser';
import { BrokerPdfParser } from './parsers/broker-pdf.parser';
import { ScreenshotOcrParser } from './parsers/screenshot-ocr.parser';
import {
  NormalizedImportRow,
  PortfolioImportParser,
  RowFailure,
} from './parsers/import-parser.types';

@Injectable()
export class ImportsService {
  private readonly parsers: PortfolioImportParser[] = [
    new ScreenshotOcrParser(),
    new TableImportParser(),
    new CasPdfParser(),
    new BrokerPdfParser(),
  ];

  constructor(
    @InjectModel(PortfolioImport.name)
    private portfolioImportModel: Model<PortfolioImportDocument>,

    @InjectModel(ImportTransaction.name)
    private importTransactionModel: Model<ImportTransactionDocument>,

    @InjectModel(Transaction.name)
    private transactionModel: Model<TransactionDocument>,

    private portfolioMergeService: PortfolioMergeService,
  ) {}

  async upload(userId: string, file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Portfolio file is required.');
    }

    const parser = this.getParser(file);
    const fileType = this.getFileType(file);
    const portfolioImport = await this.portfolioImportModel.create({
      userId,
      fileName: file.originalname,
      fileType,
      uploadedAt: new Date(),
      status: 'PROCESSING',
      importSummary: {
        duplicateRows: 0,
        failedRows: [],
        supportedFormats: [
          'CSV',
          'XLSX',
          'CAMS_CAS_PDF',
          'KFINTECH_CAS_PDF',
          'BROKER_STATEMENT',
          'SCREENSHOT',
        ],
      },
    });

    try {
      const parserResult = await parser.parse(file);
      const { rows, failures, detectedSource, metadata } = parserResult;

      const acceptedRows: NormalizedImportRow[] = [];
      const duplicateRows: RowFailure[] = [];

      for (const row of rows) {
        const duplicate = await this.isDuplicate(userId, row, file.originalname);
        if (duplicate) {
          duplicateRows.push({
            rowNumber: row.rowNumber,
            reason: 'Duplicate transaction skipped',
          });
          continue;
        }

        acceptedRows.push(row);
      }

      const mergeRows: MergeTransaction[] = acceptedRows.map((row) => ({
        userId,
        symbol: row.symbol,
        assetName: row.assetName,
        assetType: row.assetType,
        quantity: row.quantity,
        buyPrice: row.price,
      }));

      if (acceptedRows.length > 0) {
        await this.importTransactionModel.insertMany(
          acceptedRows.map((row) => ({
            importId: portfolioImport._id,
            userId,
            symbol: row.symbol,
            assetName: row.assetName,
            assetType: row.assetType,
            quantity: row.quantity,
            buyPrice: row.price,
            buyDate: row.date,
            sourceFile: file.originalname,
            sourceType: row.sourceType,
            folioNumber: row.folioNumber,
            investedAmount: row.investedAmount ?? row.quantity * row.price,
          })),
          { ordered: false },
        );

        await this.transactionModel.insertMany(
          acceptedRows.map((row) => ({
            userId,
            assetType: row.assetType,
            assetName: row.assetName,
            symbol: row.symbol,
            transactionType: 'BUY',
            quantity: row.quantity,
            price: row.price,
            realizedProfit: 0,
            transactionDate: row.date,
          })),
          { ordered: false },
        );

        await this.portfolioMergeService.merge(userId, mergeRows);
      }

      const failedRows = [...failures, ...duplicateRows];
      return this.portfolioImportModel.findByIdAndUpdate(
        portfolioImport._id,
        {
          status: 'COMPLETED',
          totalRecords: rows.length + failures.length,
          successRecords: acceptedRows.length,
          failedRecords: failedRows.length,
          importSummary: {
            importedSymbols: [...new Set(acceptedRows.map((row) => row.symbol))],
            detectedSource,
            metadata,
            duplicateRows: duplicateRows.length,
            failedRows,
            brokerSyncReady: true,
            casAutoEmailReady: true,
          },
        },
        { new: true },
      );
    } catch (error) {
      await this.portfolioImportModel.findByIdAndUpdate(portfolioImport._id, {
        status: 'FAILED',
        importSummary: {
          error: error instanceof Error ? error.message : 'Import failed',
          brokerSyncReady: true,
          casAutoEmailReady: true,
        },
      });

      throw error;
    }
  }

  async findHistory(userId: string) {
    return this.portfolioImportModel.find({ userId }).sort({ uploadedAt: -1 });
  }

  async findOne(userId: string, id: string) {
    const portfolioImport = await this.portfolioImportModel.findOne({
      _id: id,
      userId,
    });

    if (!portfolioImport) {
      throw new NotFoundException('Import record not found.');
    }

    const transactions = await this.importTransactionModel
      .find({
        userId,
        importId: portfolioImport._id,
      })
      .sort({ buyDate: -1 });

    return {
      import: portfolioImport,
      transactions,
    };
  }

  async delete(userId: string, id: string) {
    const portfolioImport = await this.portfolioImportModel.findOneAndDelete({
      _id: id,
      userId,
    });

    if (!portfolioImport) {
      throw new NotFoundException('Import record not found.');
    }

    await this.importTransactionModel.deleteMany({
      userId,
      importId: portfolioImport._id,
    });

    return { success: true };
  }

  private getParser(file: Express.Multer.File) {
    const parser = this.parsers.find((candidate) =>
      candidate.canParse(file.originalname, file.mimetype),
    );

    if (!parser) {
      throw new BadRequestException(
        'Only CSV, XLSX, PDF, PNG, JPG, JPEG and WEBP imports are supported.',
      );
    }

    return parser;
  }

  private getFileType(file: Express.Multer.File) {
    const normalized = file.originalname.toLowerCase();
    if (normalized.endsWith('.csv')) return 'BROKER_CSV';
    if (normalized.endsWith('.xlsx')) return 'BROKER_XLSX';
    if (normalized.endsWith('.pdf')) {
      return normalized.includes('cas') ||
        normalized.includes('cams') ||
        normalized.includes('kfin')
        ? 'CAS_PDF'
        : 'BROKER_PDF';
    }
    if (file.mimetype?.startsWith('image/')) return 'SCREENSHOT';
    throw new BadRequestException('Unsupported import file type.');
  }

  private async isDuplicate(
    userId: string,
    row: NormalizedImportRow,
    sourceFile: string,
  ) {
    const imported = await this.importTransactionModel.exists({
      userId,
      symbol: row.symbol,
      quantity: row.quantity,
      buyPrice: row.price,
      buyDate: row.date,
      sourceFile,
    });

    if (imported) return true;

    return this.transactionModel.exists({
      userId,
      assetType: row.assetType,
      symbol: row.symbol,
      transactionType: 'BUY',
      quantity: row.quantity,
      price: row.price,
      transactionDate: row.date,
    });
  }
}
