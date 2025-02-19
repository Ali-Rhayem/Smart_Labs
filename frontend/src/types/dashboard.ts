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
	total_attendance_bytime?: number[];
	total_ppe_compliance?: number;
	total_ppe_compliance_bytime?: number[];
	ppe_compliance?: {
		[key: string]: number;
	};
	ppe_compliance_bytime?: {
		[key: string]: number[];
	};
	people?: People[];
	people_bytime?: PeopleBytime[];
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

export interface PeopleBytime {
	id: number;
	name: string;
	attendance_percentage: number[];
	ppe_compliance: { [key: string]: number[] };
	user: UserDTO;
}

