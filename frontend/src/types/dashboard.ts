import { UserDTO } from "./user";

export interface dashboard {
	total_students?: number;
	labs?: Lab[];
	total_labs?: number;
	avg_attandance?: number;
	ppe_compliance?: number;
}

export interface Lab {
	lab_id?: number;
	lab_name?: string;
	xaxis?: string[];
	total_attendance?: number;
	total_ppe_compliance?: number;
	ppe_compliance?: {
		[key: string]: number;
	};
	people?: People[];
}

export interface PPEComplianceData {
	name: string;
	value: number;
}

export interface People {
	id: number;
	name: string;
	attendance_percentage: number;
	ppe_compliance: { [key: string]: number };
	user: UserDTO;
}
