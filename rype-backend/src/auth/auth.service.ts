import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';

import * as bcrypt from 'bcrypt';

import { JwtService } from '@nestjs/jwt';

import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { LoginResponseDto, RegisterResponseDto } from './dto/auth-response.dto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(data: RegisterDto): Promise<RegisterResponseDto> {
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
      user: {
        _id: user._id.toString(),
        email: user.email,
        fullName: user.fullName,
      },
    };
  }

  async login(data: LoginDto): Promise<LoginResponseDto> {
    const email = data.email.trim().toLowerCase();
    const user = await this.usersService.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const storedPassword = user.password ?? '';
    const isBcryptHash = storedPassword.startsWith('$2a$') ||
      storedPassword.startsWith('$2b$') ||
      storedPassword.startsWith('$2y$');
    const passwordMatch = isBcryptHash
      ? await bcrypt.compare(data.password, storedPassword)
      : data.password === storedPassword;

    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
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
