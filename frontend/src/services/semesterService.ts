import { smart_labs } from "../utils/axios";
import { CreateSemesterDTO, Semester } from "../types/semester";

export const semesterService = {
	getSemesters: () => smart_labs.getAPI<Semester[]>(`/semester`),

	getSemester: (id: string) => smart_labs.getAPI<Semester>(`/semester/${id}`),

	createSemester: (semester: Semester) =>
		smart_labs.postAPI<Semester, CreateSemesterDTO>(`/semester`, semester),

	updateSemester: (id: number, semester: Semester) =>
		smart_labs.putAPI<Semester, CreateSemesterDTO>(
			`/semester/${id}`,
			semester
		),

	deleteSemester: (id: string) =>
		smart_labs.deleteAPI<Semester>(`/semester/${id}`),

	toggleCurrentSemester: (id: number) =>
		smart_labs.putAPI<never, unknown>(`/semester/${id}/current`, {}),
};
