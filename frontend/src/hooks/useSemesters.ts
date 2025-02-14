import { useQuery } from "@tanstack/react-query";
import { semesterService } from "../services/semesterService";

export const useRooms = () => {
	return useQuery({
		queryKey: ["Semesters"],
		queryFn: () => semesterService.getSemesters(),
		staleTime: 30 * 60 * 1000,
	});
};
