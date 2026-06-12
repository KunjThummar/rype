import { Test, TestingModule } from '@nestjs/testing';
import { WhatIfService } from './what-if.service';

describe('WhatIfService', () => {
  let service: WhatIfService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [WhatIfService],
    }).compile();

    service = module.get<WhatIfService>(WhatIfService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
