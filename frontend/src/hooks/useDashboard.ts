import { useQuery } from "@tanstack/react-query";
import { dashboardService } from "../services/dashboardService";

export const useDashboard = () => {
	return useQuery({
		queryKey: ["Dashboard"],
		queryFn: () => dashboardService.getDashboard(),
		staleTime: 30 * 60 * 1000,
	});
};
