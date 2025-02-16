import { faculty } from "../types/faculty";
import { smart_labs } from "../utils/axios";

export const facultyService = {
	getFaculties: () => smart_labs.getAPI<faculty[]>("/faculty"),

	addFaculty: (faculty: faculty) =>
		smart_labs.postAPI<faculty, faculty>("/faculty", faculty),

	updateFaculty: (id: number, faculty: faculty) =>
		smart_labs.putAPI<faculty, faculty>(`/faculty/${id}`, faculty),

	deleteFaculty: (id: number) =>
		smart_labs.deleteAPI<faculty>(`/faculty/${id}`),

	addMajor: (id: number, major: string) =>
		smart_labs.postAPI<faculty, string>(`/faculty/${id}/major`, major),

	deleteMajor: (id: number, major: string) =>
		smart_labs.deleteAPI<faculty, string>(`/faculty/${id}/major/`, major),
};
