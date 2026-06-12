import { IsNumber, IsString, Min } from 'class-validator';

export class CreateMutualFundDto {
  @IsString()
  fundName: string;

  @IsString()
  amfiCode: string;

  @IsNumber()
  @Min(1)
  units: number;

  @IsNumber()
  @Min(1)
  purchaseNav: number;

  @IsNumber()
  @Min(1)
  currentNav: number;
}
