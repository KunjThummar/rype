import { Test, TestingModule } from '@nestjs/testing';
import { WhatIfController } from './what-if.controller';

describe('WhatIfController', () => {
  let controller: WhatIfController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [WhatIfController],
    }).compile();

    controller = module.get<WhatIfController>(WhatIfController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
