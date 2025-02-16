import { UserDTO } from "./user";

export interface Comment {
	id: number;
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
}

export interface CommentDTO {
	id: number;
	user: UserDTO;
	message: string;
	time: Date;
}
