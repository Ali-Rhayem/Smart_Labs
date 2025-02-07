import { smart_labs } from "../utils/axios";
import { LoginData, AuthResponse } from "../types/auth";

export const authService = {
  login: (data: LoginData) => 
    smart_labs.postAPI<AuthResponse, LoginData>('/User/login', data),
};