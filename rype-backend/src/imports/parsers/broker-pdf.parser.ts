import {
  NormalizedImportRow,
  ParserResult,
  PortfolioImportParser,
  RowFailure,
} from './import-parser.types';
import { parseDate, parseNumber, rowFailure } from './import-parser.utils';

export class BrokerPdfParser implements PortfolioImportParser {
  canParse(fileName: string) {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  async parse(file: Express.Multer.File): Promise<ParserResult> {
    const { PDFParse } = await import('pdf-parse');
    const parser = new PDFParse({ data: file.buffer });
    const parsed = await parser.getText();
    await parser.destroy();
    const text = parsed.text ?? '';
    const detectedSource = this.detectBroker(`${file.originalname}\n${text}`);
    const rows: NormalizedImportRow[] = [];
    const failures: RowFailure[] = [];

    text
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
      .forEach((line, index) => {
        const rowNumber = index + 1;
        const match = line.match(
          /(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})\s+([A-Z][A-Z0-9&.-]{1,20})\s+([\d,.]+)\s+([\d,.]+)/,
        );

        if (!match) return;

        const date = parseDate(match[1]);
        const symbol = match[2].toUpperCase();
        const quantity = parseNumber(match[3]);
        const price = parseNumber(match[4]);

        if (!date || !Number.isFinite(quantity) || !Number.isFinite(price)) {
          failures.push(rowFailure(rowNumber, 'Broker PDF row could not be parsed'));
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

    if (rows.length === 0) {
      failures.push(rowFailure(1, 'No broker transactions detected'));
    }

    return {
      rows,
      failures,
      detectedSource,
      metadata: { parser: 'BROKER_PDF', pages: parsed.pages.length },
    };
  }

  private detectBroker(text: string) {
    if (/zerodha|kite|console/i.test(text)) return 'ZERODHA';
    if (/groww/i.test(text)) return 'GROWW';
    if (/angel\s*one|angel broking/i.test(text)) return 'ANGEL_ONE';
    if (/upstox/i.test(text)) return 'UPSTOX';
    return 'GENERIC';
  }
}
