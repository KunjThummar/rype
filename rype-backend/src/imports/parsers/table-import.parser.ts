import * as XLSX from 'xlsx';

import {
  NormalizedImportRow,
  ParserResult,
  PortfolioImportParser,
  RowFailure,
} from './import-parser.types';
import {
  ensureHeader,
  normalizeHeader,
  parseDate,
  parseNumber,
  rowFailure,
  splitCsvLine,
} from './import-parser.utils';

type ColumnMap = Record<'date' | 'symbol' | 'quantity' | 'price', number>;

export class TableImportParser implements PortfolioImportParser {
  canParse(fileName: string) {
    const normalized = fileName.toLowerCase();
    return normalized.endsWith('.csv') || normalized.endsWith('.xlsx');
  }

  parse(file: Express.Multer.File): ParserResult {
    const table = file.originalname.toLowerCase().endsWith('.csv')
      ? this.parseCsv(file.buffer)
      : this.parseWorkbook(file.buffer);

    return this.normalizeTable(table);
  }

  private parseCsv(buffer: Buffer) {
    const text = buffer.toString('utf8').replace(/^\uFEFF/, '');
    const lines = text
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean);

    return lines.map((line) => splitCsvLine(line));
  }

  private parseWorkbook(buffer: Buffer) {
    const workbook = XLSX.read(buffer, { type: 'buffer', cellDates: true });
    const sheetName = workbook.SheetNames[0];
    if (!sheetName) return [];

    return XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {
      header: 1,
      blankrows: false,
      raw: false,
    }) as unknown[][];
  }

  private normalizeTable(rawRows: unknown[][]): ParserResult {
    const [headers, ...dataRows] = rawRows;
    ensureHeader(headers);

    const detectedSource = this.detectBroker(headers);
    const columnMap = this.detectColumns(headers);
    const rows: NormalizedImportRow[] = [];
    const failures: RowFailure[] = [];

    dataRows.forEach((row, index) => {
      const rowNumber = index + 2;
      const date = parseDate(row[columnMap.date]);
      const symbol = String(row[columnMap.symbol] ?? '')
        .trim()
        .toUpperCase();
      const quantity = parseNumber(row[columnMap.quantity]);
      const price = parseNumber(row[columnMap.price]);

      if (!date) {
        failures.push(rowFailure(rowNumber, 'Invalid date'));
        return;
      }
      if (!symbol) {
        failures.push(rowFailure(rowNumber, 'Missing symbol'));
        return;
      }
      if (!Number.isFinite(quantity) || quantity <= 0) {
        failures.push(rowFailure(rowNumber, 'Quantity must be greater than 0'));
        return;
      }
      if (!Number.isFinite(price) || price <= 0) {
        failures.push(rowFailure(rowNumber, 'Price must be greater than 0'));
        return;
      }

      rows.push({
        rowNumber,
        date,
        symbol,
        assetName: symbol,
        assetType: 'STOCK',
        quantity,
        price,
        sourceType: detectedSource,
      });
    });

    return {
      rows,
      failures,
      detectedSource,
      metadata: { parser: 'TABLE' },
    };
  }

  private detectColumns(headers: unknown[]): ColumnMap {
    const normalized = headers.map((header) => normalizeHeader(header));
    const find = (names: string[]) =>
      normalized.findIndex((header) => names.includes(header));

    const columnMap = {
      date: find([
        'date',
        'buydate',
        'tradedate',
        'transactiondate',
        'purchasedate',
      ]),
      symbol: find(['symbol', 'ticker', 'scrip', 'isin', 'tradingsymbol']),
      quantity: find(['qty', 'quantity', 'units']),
      price: find(['price', 'buyprice', 'avgprice', 'averageprice', 'nav']),
    };

    const missing = Object.entries(columnMap)
      .filter(([, index]) => index < 0)
      .map(([name]) => name);

    if (missing.length > 0) {
      throw new Error(`Missing required columns: ${missing.join(', ')}`);
    }

    return columnMap;
  }

  private detectBroker(headers: unknown[]) {
    const headerText = headers.map((header) => normalizeHeader(header)).join('|');
    if (headerText.includes('tradingsymbol') || headerText.includes('exchange')) {
      return 'ZERODHA';
    }
    if (headerText.includes('groww') || headerText.includes('instrument')) {
      return 'GROWW';
    }
    if (headerText.includes('angel') || headerText.includes('scripname')) {
      return 'ANGEL_ONE';
    }
    if (headerText.includes('upstox') || headerText.includes('isin')) {
      return 'UPSTOX';
    }
    return 'GENERIC';
  }
}
