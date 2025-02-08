import { smart_labs } from "../utils/axios";
import { Lab, CreateLabDto } from "../types/lab";
import { User } from "../types/user";

export const labService = {
	getLabs: () => smart_labs.getAPI<Lab[]>("/lab"),

	getInstructerLabs: (id: number) =>
		smart_labs.getAPI<Lab[]>(`/lab/instructor/${id}`),

	getStudentLabs: (id: number) =>
		smart_labs.getAPI<Lab[]>(`/lab/student/${id}`),

	getStudentsInLab: (id: number) =>
		smart_labs.getAPI<User[]>(`/lab/${id}/students`),

	getInstructorsInLab: (id: number) =>
		smart_labs.getAPI<User[]>(`/lab/${id}/instructors`),

	createLab: (data: CreateLabDto) =>
		smart_labs.postAPI<Lab, CreateLabDto>("/lab", data),

	deleteLab: (id: number) => smart_labs.deleteAPI<void>(`/lab/${id}`),

	updateLab: (id: number, data: Partial<CreateLabDto>) =>
		smart_labs.putAPI<Lab, Partial<CreateLabDto>>(`/lab/${id}`, data),
};
