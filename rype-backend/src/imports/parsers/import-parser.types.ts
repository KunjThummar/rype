export type ImportAssetType = 'STOCK' | 'MUTUAL_FUND';

export type ImportSourceType =
  | 'GENERIC'
  | 'CAMS_CAS'
  | 'KFINTECH_CAS'
  | 'ZERODHA'
  | 'GROWW'
  | 'ANGEL_ONE'
  | 'UPSTOX'
  | 'SCREENSHOT';

export interface NormalizedImportRow {
  rowNumber: number;
  date: Date;
  symbol: string;
  assetName: string;
  assetType: ImportAssetType;
  quantity: number;
  price: number;
  investedAmount?: number;
  currentValue?: number;
  folioNumber?: string;
  sourceType: ImportSourceType;
}

export interface RowFailure {
  rowNumber: number;
  reason: string;
}

export interface ParserResult {
  rows: NormalizedImportRow[];
  failures: RowFailure[];
  detectedSource: ImportSourceType;
  metadata?: Record<string, any>;
}

export interface PortfolioImportParser {
  canParse(fileName: string, mimeType?: string): boolean;
  parse(file: Express.Multer.File): Promise<ParserResult> | ParserResult;
}
