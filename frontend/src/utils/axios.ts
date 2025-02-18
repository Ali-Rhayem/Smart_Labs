import axios from "axios";
import { baseUrl } from "../config/config";

const apiClient = axios.create({
	baseURL: baseUrl,
	headers: {
		"Content-Type": "application/json",
	},
});

apiClient.interceptors.request.use(
	(config) => {
		const token = localStorage.getItem("token");
		if (token) {
			config.headers.Authorization = `Bearer ${token}`;
		}
		return config;
	},
	(error) => {
		return Promise.reject(error);
	}
);

interface SmartLabs {
	getAPI: <T>(api_url: string) => Promise<T>;
	postAPI: <T, D>(api_url: string, api_data: D, config?: object) => Promise<T>;
	putAPI: <T, D>(api_url: string, api_data: D) => Promise<T>;
	deleteAPI: <T, D = Record<string, never>>(api_url: string, api_data?: D) => Promise<T>;
}

export const smart_labs: SmartLabs = {
	getAPI: <T>(api_url: string) =>
		apiClient.get<T>(api_url).then((response) => response.data),
	postAPI: <T, D>(api_url: string, api_data: D, config = {}) => {
		const defaultConfig = {
			headers: {
				'Content-Type': 'application/json',
			},
		};

		// Override content-type if FormData is being sent
		if (api_data instanceof FormData) {
			defaultConfig.headers['Content-Type'] = 'multipart/form-data';
		}

		return apiClient
			.post<T>(api_url, api_data, { ...defaultConfig, ...config })
			.then((response) => response.data);
	},
	putAPI: <T, D>(api_url: string, api_data: D) =>
		apiClient.put<T>(api_url, api_data).then((response) => response.data),
	deleteAPI: <T, D = Record<string, never>>(api_url: string, api_data?: D) =>
		apiClient
			.delete<T>(api_url, api_data ? { data: api_data } : undefined)
			.then((response) => response.data),
};

export default apiClient;
