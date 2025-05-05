export interface Semester {
	id: number;
	name: string;
	currentSemester: boolean;
}

export interface CreateSemesterDTO {
	name: string;
}
