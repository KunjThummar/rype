import { Injectable } from '@nestjs/common';

@Injectable()
export class NavProvider {
  async getNav(amfiCode: string) {
    return 25.45;
  }
}
