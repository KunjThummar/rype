import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';

import { ImportsService } from './imports.service';
import { PortfolioMergeService } from './portfolio-merge.service';
import { PortfolioImport } from './schemas/portfolio-import.schema';
import { ImportTransaction } from './schemas/import-transaction.schema';
import { Transaction } from '../transactions/schemas/transaction.schema';

describe('ImportsService', () => {
  let service: ImportsService;

  const portfolioImportModel = {
    create: jest.fn(),
    find: jest.fn(),
    findOne: jest.fn(),
    findOneAndDelete: jest.fn(),
    findByIdAndUpdate: jest.fn(),
  };

  const importTransactionModel = {
    insertMany: jest.fn(),
    find: jest.fn(() => ({ sort: jest.fn().mockResolvedValue([]) })),
    deleteMany: jest.fn(),
    exists: jest.fn(),
  };

  const transactionModel = {
    insertMany: jest.fn(),
    exists: jest.fn().mockResolvedValue(null),
  };

  const mergeService = {
    merge: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    portfolioImportModel.create.mockResolvedValue({ _id: 'import-1' });
    portfolioImportModel.findByIdAndUpdate.mockImplementation(
      async (_id: string, update: any) => ({
        _id: 'import-1',
        ...update,
      }),
    );
    portfolioImportModel.findOne.mockResolvedValue({
      _id: 'import-1',
      fileName: 'demo.csv',
    });
    portfolioImportModel.findOneAndDelete.mockResolvedValue({
      _id: 'import-1',
      fileName: 'demo.csv',
    });
    portfolioImportModel.find.mockReturnValue({
      sort: jest.fn().mockResolvedValue([]),
    });

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ImportsService,
        {
          provide: getModelToken(PortfolioImport.name),
          useValue: portfolioImportModel,
        },
        {
          provide: getModelToken(ImportTransaction.name),
          useValue: importTransactionModel,
        },
        {
          provide: getModelToken(Transaction.name),
          useValue: transactionModel,
        },
        {
          provide: PortfolioMergeService,
          useValue: mergeService,
        },
      ],
    }).compile();

    service = module.get<ImportsService>(ImportsService);
  });

  it('imports valid csv rows and creates a summary', async () => {
    importTransactionModel.exists.mockResolvedValue(null);

    const result = await service.upload('user-1', {
      originalname: 'portfolio.csv',
      buffer: Buffer.from('Date,Symbol,Qty,Price\n2026-06-01,INFY,10,1500\n2026-06-02,TCS,5,3500'),
    } as Express.Multer.File);

    expect(importTransactionModel.insertMany).toHaveBeenCalledTimes(1);
    expect(transactionModel.insertMany).toHaveBeenCalledTimes(1);
    expect(mergeService.merge).toHaveBeenCalledTimes(1);
    expect(result.status).toBe('COMPLETED');
    expect(result.successRecords).toBe(2);
  });

  it('returns import history', async () => {
    await service.findHistory('user-1');
    expect(portfolioImportModel.find).toHaveBeenCalledWith({ userId: 'user-1' });
  });
});
