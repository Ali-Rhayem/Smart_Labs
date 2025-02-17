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

export interface LabAnalytics {
	total_attendance: number;
	total_attendance_bytime: number[];
	total_ppe_compliance: number;
	total_ppe_compliance_bytime: number[];
	ppe_compliance: Record<string, number>;
	ppe_compliance_bytime: Record<string, number[]>;
	people: Array<{
		name: string;
		attendance_percentage: number;
		ppE_compliance: Record<string, number>;
	}>;
	people_bytime: Array<{
		name: string;
		attendance_percentage: number[];
		ppE_compliance: Record<string, number[]>;
	}>;
}
