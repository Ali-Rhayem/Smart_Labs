import { faculty } from "../types/faculty";
import { smart_labs } from "../utils/axios";

export const facultyService = {
	getFaculties: () => smart_labs.getAPI<faculty[]>("/faculty"),
};
