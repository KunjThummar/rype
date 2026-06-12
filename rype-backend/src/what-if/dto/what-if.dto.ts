import { IsNumber, IsString, Min } from 'class-validator';

export class WhatIfDto {
  @IsString()
  symbol: string;

  @IsNumber()
  @Min(1)
  quantity: number;

  @IsNumber()
  @Min(1)
  sellPrice: number;
}
