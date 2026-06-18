import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

type CacheEntry<T> = {
  expiresAt: number;
  value: T;
};

export type StockPriceResult = {
  symbol: string;
  price: number | null;
  open?: number;
  high?: number;
  low?: number;
  previousClose?: number;
  change: number;
  changePercent: string;
  latestTradingDay?: string;
  source: string;
  error?: string;
};

export type NavResult = {
  amfiCode: string;
  nav: number | null;
  date?: string;
  source: string;
  error?: string;
};

@Injectable()
export class MarketDataService {
  private readonly logger = new Logger(MarketDataService.name);
  private readonly cache = new Map<string, CacheEntry<any>>();
  private readonly cacheTtlMs = 5 * 60 * 1000;

  constructor(private configService: ConfigService) {}

  private async withRetry<T>(operation: () => Promise<T>, attempts = 3) {
    let lastError: any;

    for (let attempt = 1; attempt <= attempts; attempt++) {
      try {
        return await operation();
      } catch (error: any) {
        lastError = error;
        if (attempt < attempts) {
          await new Promise((resolve) => setTimeout(resolve, attempt * 300));
        }
      }
    }

    throw lastError;
  }

  private getCached<T>(key: string): T | null {
    const cached = this.cache.get(key);
    if (!cached || cached.expiresAt < Date.now()) {
      this.cache.delete(key);
      return null;
    }
    return cached.value as T;
  }

  private setCached<T>(key: string, value: T) {
    this.cache.set(key, {
      value,
      expiresAt: Date.now() + this.cacheTtlMs,
    });
  }

  /**
   * Fetch live stock price from Alpha Vantage.
   * Symbol format for Indian stocks: e.g.  TCS.BSE  or  INFY.NSE
   */
  async getStockPrice(symbol: string): Promise<StockPriceResult> {
    const normalizedSymbol = symbol.trim().toUpperCase();
    const cacheKey = `stock:${normalizedSymbol}`;
    const cached = this.getCached<StockPriceResult>(cacheKey);
    if (cached) return cached;

    try {
      const apiKey = this.configService.get<string>('STOCK_API_KEY');
      if (!apiKey) {
        throw new Error('STOCK_API_KEY is missing in environment variables');
      }

      const response = await this.withRetry(() =>
        axios.get('https://www.alphavantage.co/query', {
          params: {
            function: 'GLOBAL_QUOTE',
            symbol: normalizedSymbol,
            apikey: apiKey,
          },
          timeout: 10000,
        }),
      );

      const quote = response.data?.['Global Quote'];

      if (!quote || !quote['05. price']) {
        this.logger.warn(`No price returned for symbol: ${normalizedSymbol}`);
        return {
          symbol: normalizedSymbol,
          price: null,
          change: 0,
          changePercent: '0%',
          source: 'alpha_vantage',
          error: 'No data',
        };
      }

      const result = {
        symbol: normalizedSymbol,
        price: parseFloat(quote['05. price']),
        open: parseFloat(quote['02. open']),
        high: parseFloat(quote['03. high']),
        low: parseFloat(quote['04. low']),
        previousClose: parseFloat(quote['08. previous close']),
        change: parseFloat(quote['09. change']),
        changePercent: quote['10. change percent'],
        latestTradingDay: quote['07. latest trading day'],
        source: 'alpha_vantage',
      };

      this.setCached(cacheKey, result);
      return result;
    } catch (error: any) {
      this.logger.error(
        `Failed to fetch price for ${normalizedSymbol}: ${error.message}`,
      );
      return {
        symbol: normalizedSymbol,
        price: null,
        change: 0,
        changePercent: '0%',
        source: 'error',
        error: error.message,
      };
    }
  }

  /**
   * Fetch live NAV from AMFI India (free, no API key needed).
   * amfiCode: the 6-digit scheme code from AMFI (e.g. "120503" for Mirae Asset)
   */
  async getNav(amfiCode: string): Promise<NavResult> {
    const normalizedCode = amfiCode.trim();
    const cacheKey = `nav:${normalizedCode}`;
    const cached = this.getCached<NavResult>(cacheKey);
    if (cached) return cached;

    try {
      const amfiUrl =
        this.configService.get<string>('AMFI_API_URL') ??
        'https://www.amfiindia.com/spages/NAVAll.txt';

      const response = await this.withRetry(() =>
        axios.get(amfiUrl, {
          responseType: 'text',
          timeout: 15000,
        }),
      );

      const lines: string[] = (response.data as string).split('\n');

      for (const line of lines) {
        const parts = line.split(';');

        if (parts.length >= 5 && parts[0].trim() === amfiCode.trim()) {
          const nav = parseFloat(parts[4].trim());
          const date = parts[5]?.trim() ?? '';

          const result = {
            amfiCode: normalizedCode,
            nav: isNaN(nav) ? 0 : nav,
            date,
            source: 'amfi',
          };

          this.setCached(cacheKey, result);
          return result;
        }
      }

      this.logger.warn(`NAV not found for AMFI code: ${normalizedCode}`);

      return {
        amfiCode: normalizedCode,
        nav: null,
        source: 'amfi',
        error: 'Code not found',
      };
    } catch (error: any) {
      this.logger.error(
        `Failed to fetch NAV for ${amfiCode}: ${error.message}`,
      );

      return {
        amfiCode: normalizedCode,
        nav: null,
        source: 'error',
        error: error.message,
      };
    }
  }
}
