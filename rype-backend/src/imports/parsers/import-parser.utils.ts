import { BadRequestException } from '@nestjs/common';
import { RowFailure } from './import-parser.types';

export function normalizeHeader(value: unknown) {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '');
}

export function parseNumber(value: unknown) {
  if (typeof value === 'number') return value;
  return Number(
    String(value ?? '')
      .replace(/[₹,\s]/g, '')
      .trim(),
  );
}

export function parseDate(value: unknown) {
  if (value instanceof Date && !Number.isNaN(value.getTime())) return value;

  const text = String(value ?? '').trim();
  if (!text) return null;

  const parsed = new Date(text);
  if (!Number.isNaN(parsed.getTime())) return parsed;

  const match = text.match(/^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$/);
  if (!match) return null;

  const [, day, month, yearText] = match;
  const year = yearText.length === 2 ? `20${yearText}` : yearText;
  const date = new Date(Number(year), Number(month) - 1, Number(day));
  return Number.isNaN(date.getTime()) ? null : date;
}

export function splitCsvLine(line: string) {
  const cells: string[] = [];
  let current = '';
  let quoted = false;

  for (let index = 0; index < line.length; index++) {
    const char = line[index];
    const next = line[index + 1];

    if (char === '"' && next === '"') {
      current += '"';
      index++;
      continue;
    }

    if (char === '"') {
      quoted = !quoted;
      continue;
    }

    if (char === ',' && !quoted) {
      cells.push(current.trim());
      current = '';
      continue;
    }

    current += char;
  }

  cells.push(current.trim());
  return cells;
}

export function ensureHeader(headers: unknown[]) {
  if (!headers?.length) {
    throw new BadRequestException('Import file header is missing.');
  }
}

export function rowFailure(rowNumber: number, reason: string): RowFailure {
  return { rowNumber, reason };
}
