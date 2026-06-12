import { Test, TestingModule } from '@nestjs/testing';
import { DividendsController } from './dividends.controller';

describe('DividendsController', () => {
  let controller: DividendsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [DividendsController],
    }).compile();

    controller = module.get<DividendsController>(DividendsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
