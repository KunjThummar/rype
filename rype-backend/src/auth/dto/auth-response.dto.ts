export class AuthResponseDto {
  success: boolean;
  message?: string;
}

export class LoginResponseDto {
  success: boolean;
  token: string;
}

export class RegisterResponseDto {
  success: boolean;
  user: {
    _id: string;
    email: string;
    fullName: string;
  };
}
