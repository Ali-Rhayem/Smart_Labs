import { PPE } from "./ppe";
import { Announcement } from "./announcements";

export interface Lab {
	id: number;
	labCode: string;
	labName: string;
	description: string;
	ppe: PPE[];
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

export interface CreateLabDto {
	name: string;
	labCode: string;
	labName: string;
	description: string | null;
	ppe: PPE[] | [];
	instructors: number[] | [];
	students: number[] | [];
	schedule: Schedule[];
	semesterID: number | null;
	room: string;
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
