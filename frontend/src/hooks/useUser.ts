import { useQuery } from "@tanstack/react-query";
import { userService } from "../services/userService";

export const useUserDetails = (id: number) => {
	return useQuery({
		queryKey: ["User", id],
		queryFn: () => userService.getUser(id),
		staleTime: 30 * 60 * 1000,
	});
};

export const useUsers = () => {
	return useQuery({
		queryKey: ["Users"],
		queryFn: () => userService.getUsers(),
		staleTime: 30 * 60 * 1000,
	});
};
