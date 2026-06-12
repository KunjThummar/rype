import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class MarketDataService {
  private readonly logger = new Logger(MarketDataService.name);

  constructor(private configService: ConfigService) { }

  /**
   * Fetch live stock price from Alpha Vantage.
   * Symbol format for Indian stocks: e.g.  TCS.BSE  or  INFY.NSE
   */
  async getStockPrice(symbol: string) {
    try {
      const apiKey = this.configService.get<string>('STOCK_API_KEY');

      const response = await axios.get('https://www.alphavantage.co/query', {
        params: {
          function: 'GLOBAL_QUOTE',
          symbol,
          apikey: apiKey,
        },
        timeout: 10000,
      });

      const quote = response.data?.['Global Quote'];

      if (!quote || !quote['05. price']) {
        this.logger.warn(`No price returned for symbol: ${symbol}`);
        return {
          symbol,
          price: 0,
          change: 0,
          changePercent: '0%',
          source: 'alpha_vantage',
          error: 'No data',
        };
      }

      return {
        symbol,
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
    } catch (error: any) {
      this.logger.error(
        `Failed to fetch price for ${symbol}: ${error.message}`,
      );
      return {
        symbol,
        price: 0,
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
  async getNav(amfiCode: string) {
    try {
      const amfiUrl = this.configService.get<string>('AMFI_API_URL');

      if (!amfiUrl) {
        throw new Error('AMFI_API_URL is missing in .env');
      }

      const response = await axios.get(amfiUrl, {
        responseType: 'text',
        timeout: 15000,
      });

      const lines: string[] = (response.data as string).split('\n');

      for (const line of lines) {
        const parts = line.split(';');

        if (
          parts.length >= 5 &&
          parts[0].trim() === amfiCode.trim()
        ) {
          const nav = parseFloat(parts[4].trim());
          const date = parts[5]?.trim() ?? '';

          return {
            amfiCode,
            nav: isNaN(nav) ? 0 : nav,
            date,
            source: 'amfi',
          };
        }
      }

      this.logger.warn(
        `NAV not found for AMFI code: ${amfiCode}`,
      );

      return {
        amfiCode,
        nav: 0,
        source: 'amfi',
        error: 'Code not found',
      };
    } catch (error: any) {
      this.logger.error(
        `Failed to fetch NAV for ${amfiCode}: ${error.message}`,
      );

      return {
        amfiCode,
        nav: 0,
        source: 'error',
        error: error.message,
      };
    }
  }
}
