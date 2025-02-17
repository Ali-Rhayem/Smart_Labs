import { UserDTO } from "./user";

export interface Session {
	id: number;
	lab_id: number;
	date: string;
	outputs: Output[];
	result: ObjectResult[];
	report: string | null;
	totalAttendance: number;
	totalPPECompliance: { [key: string]: number };
	ppE_compliance_bytime: { [key: string]: number[] };
	total_ppe_compliance_bytime: number[];
}

export interface ObjectResult {
	id: number;
	name: string;
	user: UserDTO;
	attendance_percentage: number;
	ppE_compliance: { [key: string]: number };
}

interface Output {
	time: string;
	people: Person[];
}

interface Person {
	id: number;
	name: string;
	ppe: { [key: string]: number };
}
