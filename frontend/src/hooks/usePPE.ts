import { useQuery } from "@tanstack/react-query";
import { ppeService } from "../services/ppeService";

export const usePPE = (ppeList: number[]) => {
	return useQuery({
		queryKey: ["ppe", ppeList],
		queryFn: () => ppeService.getListPPEs(ppeList),
		staleTime: 30 * 60 * 1000,
	});
};
