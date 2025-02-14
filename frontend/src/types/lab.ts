import { Announcement } from "./announcements";

export interface Lab {
	id: number;
	labCode: string;
	labName: string;
	description: string;
	ppe: number[];
	instructors: number[];
	students: number[];
	schedule: Schedule[];
	report: string;
	semesterID: number;
	endLab: boolean;
	room: string;
	announcements: Announcement[];
	started: boolean;
}

export interface LabDto {
	labCode: string;
	labName: string;
	description: string | null;
	ppe: number[];
	schedule: Schedule[];
	semesterID: number | null;
	room: string;
}

export interface CreateLabDto {
	lab: LabDto;
	instructor_Emails: string[];
	student_Emails: string[];
}

type DayOfWeek =
	| "Sunday"
	| "Monday"
	| "Tuesday"
	| "Wednesday"
	| "Thursday"
	| "Friday"
	| "Saturday";

export interface Schedule {
	dayOfWeek: DayOfWeek;
	startTime: string;
	endTime: string;
}

export interface UpdateLabDto
	extends Partial<
		Omit<
			Lab,
			| "id"
			| "ppe"
			| "instructors"
			| "students"
			| "report"
			| "announcements"
			| "started"
			| "endLab"
		>
	> {}
