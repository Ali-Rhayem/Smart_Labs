import { smart_labs } from "../utils/axios";
import { Notification, NotificationDTO } from "../types/notification";

export const notificationService = {
	getNotifications: (id: number) =>
		smart_labs.getAPI<Notification[]>(`/notification/user/${id}`),

	readNotification: (id: number) =>
		smart_labs.putAPI(`/notification/mark-as-read/${id}`, {}),

	readAllNotifications: () =>
		smart_labs.putAPI(`/notification/mark-all-as-read`, {}),

	deleteNotification: (id: number) =>
		smart_labs.putAPI(`/notification/mark-as-deleted/${id}`, {}),

	deleteAllNotifications: () =>
		smart_labs.putAPI(`/notification/mark-all-as-deleted`, {}),

	sendNotification: (notification: NotificationDTO) =>
		smart_labs.postAPI<NotificationDTO, NotificationDTO>(
			`/notification/send`,
			notification
		),
};
