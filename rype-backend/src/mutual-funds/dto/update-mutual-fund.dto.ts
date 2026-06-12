import { PartialType } from '@nestjs/swagger';
import { CreateMutualFundDto } from './create-mutual-fund.dto';

export class UpdateMutualFundDto extends PartialType(CreateMutualFundDto) {}
