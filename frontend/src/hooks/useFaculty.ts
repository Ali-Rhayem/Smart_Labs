import { useQuery } from "@tanstack/react-query";
import { facultyService } from "../services/facultyService";

export const useFaculties = () => {
	return useQuery({
		queryKey: ["Faculties"],
		queryFn: () => facultyService.getFaculties(),
		staleTime: 30 * 60 * 1000,
	});
};
