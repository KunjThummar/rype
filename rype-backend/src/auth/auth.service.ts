import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';

import * as bcrypt from 'bcrypt';

import { JwtService } from '@nestjs/jwt';

import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(data: any) {
    const email = data.email.trim().toLowerCase();
    const userExists = await this.usersService.findByEmail(email);

    if (userExists) {
      throw new BadRequestException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(data.password, 10);

    const user = await this.usersService.create({
      ...data,
      email,
      password: hashedPassword,
    });

    return {
      success: true,
      user,
    };
  }

  async login(data: any) {
    const email = data.email.trim().toLowerCase();
    const user = await this.usersService.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Invalid Credentials');
    }

    const storedPassword = user.password ?? '';
    const isBcryptHash = storedPassword.startsWith('$2a$') ||
      storedPassword.startsWith('$2b$') ||
      storedPassword.startsWith('$2y$');
    const passwordMatch = isBcryptHash
      ? await bcrypt.compare(data.password, storedPassword)
      : data.password === storedPassword;

    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid Credentials');
    }

    if (!isBcryptHash) {
      user.password = await bcrypt.hash(data.password, 10);
      await user.save();
    }

    const token = await this.jwtService.signAsync({
      id: user._id,
      email: user.email,
    });

    return {
      success: true,
      token,
    };
  }
}
