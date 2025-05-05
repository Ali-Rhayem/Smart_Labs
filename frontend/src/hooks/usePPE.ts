import { useQuery } from "@tanstack/react-query";
import { ppeService } from "../services/ppeService";

export const usePPE = (ppeList: number[]) => {
	return useQuery({
		queryKey: ["ppe", ppeList],
		queryFn: () => ppeService.getListPPEs(ppeList),
		staleTime: 30 * 60 * 1000,
	});
};

export const useAllPPEs = () => {
	return useQuery({
		queryKey: ["allPPEs"],
		queryFn: ppeService.getPPEs,
		staleTime: 30 * 60 * 1000,
	});
};
