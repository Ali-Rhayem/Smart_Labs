import { useQuery } from "@tanstack/react-query";
import { notificationService } from "../services/notificationService";

export const useNotification = (user_id: number) => {
	return useQuery({
		queryKey: ["Notification", user_id],
		queryFn: () => notificationService.getNotifications(user_id),
		staleTime: 30 * 60 * 1000,
	});
};
