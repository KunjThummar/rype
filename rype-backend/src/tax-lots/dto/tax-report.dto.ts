export class TaxReportDto {
  symbol: string;

  buyDate: Date;

  sellDate: Date;

  quantity: number;

  buyPrice: number;

  sellPrice: number;

  gain: number;

  holdingDays: number;

  taxType: string;
}
