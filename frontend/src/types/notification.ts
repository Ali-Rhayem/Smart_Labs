export interface Notification {
	id: number;
	title: string;
	message: string;
	data: { [key: string]: string };
	date: Date;
	userID: number;
	isRead: boolean;
	isDeleted: boolean;
}
