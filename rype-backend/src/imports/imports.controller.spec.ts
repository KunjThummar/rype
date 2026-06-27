import { Test, TestingModule } from '@nestjs/testing';
import { ImportsController } from './imports.controller';
import { ImportsService } from './imports.service';

describe('ImportsController', () => {
  let controller: ImportsController;
  const service = {
    upload: jest.fn(),
    findHistory: jest.fn(),
    findOne: jest.fn(),
    delete: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ImportsController],
      providers: [{ provide: ImportsService, useValue: service }],
    }).compile();

    controller = module.get<ImportsController>(ImportsController);
  });

  it('should proxy upload requests', async () => {
    const file = { originalname: 'file.csv' } as Express.Multer.File;
    await controller.upload({ user: { userId: 'user-1' } } as any, file);
    expect(service.upload).toHaveBeenCalledWith('user-1', file);
  });

  it('should proxy history requests', async () => {
    await controller.getHistory({ user: { userId: 'user-1' } } as any);
    expect(service.findHistory).toHaveBeenCalledWith('user-1');
  });
});
