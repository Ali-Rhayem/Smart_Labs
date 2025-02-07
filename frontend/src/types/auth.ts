export interface LoginData {
  email: string;
  password: string;
  fcm_token: string | null;
}

export interface AuthResponse {
  token: string;
  userId: number;
  role: string;
}