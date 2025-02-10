import { UserDTO } from "./user";

export interface Comment {
	id: number;
	userId: number;
	content: string;
	time: Date;
}

export interface Announcement {
	id: number;
	sender: number;
	message: string;
	files: string[];
	time: Date;
	comments: Comment[];
}

export interface AnnouncementDTO {
	id?: number;
	user: UserDTO;
	message: string;
	files: string[];
	time: Date;
	comments: CommentDTO[];
}

export interface CommentDTO {
	id: number;
	user: UserDTO;
	message: string;
	time: Date;
}
