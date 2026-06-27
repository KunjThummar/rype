import {
  NormalizedImportRow,
  ParserResult,
  PortfolioImportParser,
  RowFailure,
} from './import-parser.types';
import { parseNumber, rowFailure } from './import-parser.utils';

export class ScreenshotOcrParser implements PortfolioImportParser {
  canParse(fileName: string, mimeType?: string) {
    const normalized = fileName.toLowerCase();
    return (
      mimeType?.startsWith('image/') ||
      normalized.endsWith('.png') ||
      normalized.endsWith('.jpg') ||
      normalized.endsWith('.jpeg') ||
      normalized.endsWith('.webp')
    );
  }

  async parse(file: Express.Multer.File): Promise<ParserResult> {
    const tesseract = await import('tesseract.js');
    const result = await tesseract.recognize(file.buffer, 'eng');
    const text = result.data.text ?? '';
    const rows: NormalizedImportRow[] = [];
    const failures: RowFailure[] = [];

    text
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
      .forEach((line, index) => {
        const rowNumber = index + 1;
        const match = line.match(
          /^([A-Z][A-Z0-9&.\-\s]{1,40})\s+([\d,.]+)\s+([\d,.]+)\s+([\d,.]+)/i,
        );

        if (!match) return;

        const symbol = match[1].trim().replace(/\s+/g, ' ').toUpperCase();
        const quantity = parseNumber(match[2]);
        const price = parseNumber(match[3]);
        const currentValue = parseNumber(match[4]);

        if (!Number.isFinite(quantity) || !Number.isFinite(price)) {
          failures.push(rowFailure(rowNumber, 'OCR row could not be parsed'));
          return;
        }

        rows.push({
          rowNumber,
          date: new Date(),
          symbol,
          assetName: symbol,
          assetType: 'STOCK',
          quantity,
          price,
          currentValue,
          sourceType: 'SCREENSHOT',
        });
      });

    if (rows.length === 0) {
      failures.push(rowFailure(1, 'No holdings detected from screenshot'));
    }

    return {
      rows,
      failures,
      detectedSource: 'SCREENSHOT',
      metadata: { parser: 'SCREENSHOT_OCR' },
    };
  }
}
