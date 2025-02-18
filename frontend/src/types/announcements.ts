import { UserDTO } from "./user";

export interface Comment {
	message: string;
}

export interface Announcement {
	message: string;
	files: string[];
}

export interface AnnouncementDTO {
	id?: number;
	user: UserDTO;
	message: string;
	files: string[];
	time: Date;
	comments: CommentDTO[];
	assignment: boolean;
	canSubmit: boolean;
	deadline?: Date;
	grade?: number;
	submissions: SubmissionDTO[];
}

export interface CommentDTO {
	id: number;
	user: UserDTO;
	message: string;
	time: Date;
}

export interface SubmissionDTO {
	userId: number;
	user: UserDTO;
	message: string;
	files: string[];
	time: Date;
	Submitted: boolean;
	grade: number;
}

export interface Submission {
	userId: number;
	message: string;
	files: string[];
	time: Date;
	grade: number;
	Submitted: boolean;
}
