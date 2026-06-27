import {
  NormalizedImportRow,
  ParserResult,
  PortfolioImportParser,
  RowFailure,
} from './import-parser.types';
import { parseDate, parseNumber, rowFailure } from './import-parser.utils';

export class CasPdfParser implements PortfolioImportParser {
  canParse(fileName: string) {
    const normalized = fileName.toLowerCase();
    return (
      normalized.endsWith('.pdf') &&
      (normalized.includes('cas') ||
        normalized.includes('cams') ||
        normalized.includes('kfin'))
    );
  }

  async parse(file: Express.Multer.File): Promise<ParserResult> {
    const { PDFParse } = await import('pdf-parse');
    const parser = new PDFParse({ data: file.buffer });
    const parsed = await parser.getText();
    await parser.destroy();
    const text = parsed.text ?? '';
    const detectedSource = /kfin|karvy/i.test(text) ? 'KFINTECH_CAS' : 'CAMS_CAS';
    const lines = text
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean);

    const rows: NormalizedImportRow[] = [];
    const failures: RowFailure[] = [];
    let currentFund = '';
    let currentFolio = '';

    lines.forEach((line, index) => {
      const rowNumber = index + 1;
      const folioMatch = line.match(/folio\s*(?:no\.?|number)?\s*[:\-]?\s*([A-Z0-9/-]+)/i);
      if (folioMatch) currentFolio = folioMatch[1];

      if (/fund|scheme/i.test(line) && !/\d{1,2}[/-]\d{1,2}[/-]\d{2,4}/.test(line)) {
        currentFund = line.replace(/scheme\s*name\s*[:\-]?/i, '').trim();
      }

      const txMatch = line.match(
        /(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}).*?([\d,.]+)\s+(?:units?)?.*?(?:nav|price)?\s*([\d,.]+).*?(?:amount|value)?\s*([\d,.]+)/i,
      );

      if (!txMatch) return;

      const date = parseDate(txMatch[1]);
      const units = parseNumber(txMatch[2]);
      const nav = parseNumber(txMatch[3]);
      const investedAmount = parseNumber(txMatch[4]);

      if (!date || !Number.isFinite(units) || !Number.isFinite(nav)) {
        failures.push(rowFailure(rowNumber, 'CAS transaction row could not be parsed'));
        return;
      }

      const fundName = currentFund || 'Mutual Fund';
      rows.push({
        rowNumber,
        date,
        symbol: fundName,
        assetName: fundName,
        assetType: 'MUTUAL_FUND',
        quantity: units,
        price: nav,
        investedAmount: Number.isFinite(investedAmount)
          ? investedAmount
          : units * nav,
        folioNumber: currentFolio,
        sourceType: detectedSource,
      });
    });

    if (rows.length === 0) {
      failures.push(rowFailure(1, 'No CAS transactions detected'));
    }

    return {
      rows,
      failures,
      detectedSource,
      metadata: { parser: 'CAS_PDF', pages: parsed.pages.length },
    };
  }
}
