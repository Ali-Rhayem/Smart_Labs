import { useMutation } from "@tanstack/react-query";
import { smart_labs } from "../utils/axios";

// Define types for login request/response if desired.
// For example:
// defualt empty string for email and password
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

const login = async (data: LoginData): Promise<AuthResponse> => {
	// Call your login API and return the response data.
	const res = await smart_labs.postAPI<AuthResponse, LoginData>(
		"/User/login",
		data
	);
	return res;
};

export const useLogin = () => {
	// Optionally, add generics for useMutation (e.g., useMutation<AuthResponse, Error, LoginData>)
	return useMutation<AuthResponse, Error, LoginData>({ mutationFn: login });
};
