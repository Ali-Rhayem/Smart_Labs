import { smart_labs } from "../utils/axios";
import { Semester } from "../types/semester";

export const semesterService = {
	getSemesters: () => smart_labs.getAPI<Semester[]>(`/semester`),
};
