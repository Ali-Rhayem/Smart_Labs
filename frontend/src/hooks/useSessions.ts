import { useQuery } from "@tanstack/react-query";
import { sessionService } from "../services/sessionService";

export const useLabSessions = (lab_id: number) => {
	return useQuery({
		queryKey: ["labSessions", lab_id],
		queryFn: () => sessionService.getLabSessions(lab_id),
		staleTime: 30 * 60 * 1000,
	});
};
