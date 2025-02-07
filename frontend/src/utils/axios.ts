import axios from "axios";
import { baseUrl } from "../config/config";

const token = localStorage.getItem("token");

const apiClient = axios.create({
	baseURL: baseUrl,
	headers: {
		"Content-Type": "application/json",
		Authorization: token ? `token ${token}` : "",
	},
});

interface SmartLabs {
	getAPI: <T>(api_url: string) => Promise<T>;
	postAPI: <T, D>(api_url: string, api_data: D) => Promise<T>;
	putAPI: <T, D>(api_url: string, api_data: D) => Promise<T>;
	deleteAPI: <T>(api_url: string) => Promise<T>;
}

export const smart_labs: SmartLabs = {
	getAPI: <T>(api_url: string) =>
		apiClient.get<T>(api_url).then((response) => response.data),
	postAPI: <T, D>(api_url: string, api_data: D) =>
		apiClient.post<T>(api_url, api_data).then((response) => response.data),
	putAPI: <T, D>(api_url: string, api_data: D) =>
		apiClient.put<T>(api_url, api_data).then((response) => response.data),
	deleteAPI: <T>(api_url: string) =>
		apiClient.delete<T>(api_url).then((response) => response.data),
};

export default apiClient;
