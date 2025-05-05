import { smart_labs } from "../utils/axios";
import { Lab, CreateLabDto, UpdateLabDto, LabAnalytics } from "../types/lab";
import { User } from "../types/user";
import { AnnouncementDTO } from "../types/announcements";

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

	editLabPPES: (id: number, ppe: number[]) =>
		smart_labs.postAPI<void, number[]>(`/lab/${id}/ppe`, ppe),

	getAnnouncements: (id: number) =>
		smart_labs.getAPI<AnnouncementDTO[]>(`/lab/${id}/announcements`),

	createLab: (data: CreateLabDto) =>
		smart_labs.postAPI<Lab, CreateLabDto>("/lab", data),

	addStudents: (id: number, emails: string[]) =>
		smart_labs.postAPI<number[], string[]>(`/lab/${id}/students`, emails),

	addInstructors: (id: number, emails: string[]) =>
		smart_labs.postAPI<number[], string[]>(
			`/lab/${id}/instructors`,
			emails
		),

	removeStudent: (labId: number, studentId: number) =>
		smart_labs.deleteAPI<void>(`/lab/${labId}/students/${studentId}`),

	removeInstructor: (labId: number, instructorId: number) =>
		smart_labs.deleteAPI<void>(`/lab/${labId}/instructors/${instructorId}`),

	deleteLab: (id: number) => smart_labs.deleteAPI<void>(`/lab/${id}`),

	updateLab: (id: number, data: UpdateLabDto) =>
		smart_labs.putAPI<Lab, UpdateLabDto>(`/lab/${id}`, data),

	archiveLab: (id: number) =>
		smart_labs.postAPI<void, void>(`/lab/${id}/endlab`, undefined),

	startSession: (id: number) =>
		smart_labs.postAPI<void, void>(`/lab/${id}/startSession`, undefined),

	endSession: (id: number) =>
		smart_labs.postAPI<void, void>(`/lab/${id}/endSession`, undefined),

	getLabAnalytics: (id: number) =>
		smart_labs.getAPI<LabAnalytics>(`/lab/${id}/analyze`),
};
