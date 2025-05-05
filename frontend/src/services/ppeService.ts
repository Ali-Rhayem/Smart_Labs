import { smart_labs } from "../utils/axios";
import { PPE, CreatePPEDto } from "../types/ppe";

export const ppeService = {
	getPPEs: () => smart_labs.getAPI<PPE[]>("/PPE"),

	getListPPEs: (ppeList: number[]) =>
		smart_labs.postAPI<PPE[], number[]>(`/PPE/list`, ppeList),

	addPPE: (ppe: CreatePPEDto) =>
		smart_labs.postAPI<PPE, CreatePPEDto>(`/PPE`, ppe),

	editPPE: (ppeId: number, ppe: CreatePPEDto) =>
		smart_labs.putAPI<PPE, CreatePPEDto>(`/PPE/${ppeId}`, ppe),

	removePPE: (ppeId: number) => smart_labs.deleteAPI(`/PPE/${ppeId}`),
};
