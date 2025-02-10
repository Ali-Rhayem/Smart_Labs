export interface Session {
	id: number;
	lab_id: number;
	date: string;
	outputs: Output[];
	result: { [key: number]: ObjectResult };
	report: string | null;
	totalAttendance: number;
	totalPPECompliance: { [key: string]: number };
}

interface ObjectResult {
	name: string;
	attendance_percentage: number;
	ppe_compliance: { [key: string]: number };
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
