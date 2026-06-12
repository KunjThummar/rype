import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';

import { Model } from 'mongoose';

import { User, UserDocument } from './schemas/user.schema';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name)
    private userModel: Model<UserDocument>,
  ) {}

  async create(userData: any) {
    return this.userModel.create({
      ...userData,
      email: userData.email?.trim().toLowerCase(),
    });
  }

  async findByEmail(email: string) {
    return this.userModel.findOne({ email: email.trim().toLowerCase() });
  }
}
