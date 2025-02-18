export interface dashboard {
	total_students: number;
	labs: { [key: string]: object }[];
	total_labs: number;
	avg_attandance: number;
	ppe_compliance: number;
}
