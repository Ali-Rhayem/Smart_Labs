import { useQuery } from "@tanstack/react-query";
import { userService } from "../services/userService";

export const useUserDetails = (id: number) => {
	return useQuery({
		queryKey: ["User", id],
		queryFn: () => userService.getUser(id),
		staleTime: 30 * 60 * 1000,
	});
};
