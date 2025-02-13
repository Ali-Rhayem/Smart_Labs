import React, { useMemo, useState } from "react";
import { Box, Typography, CircularProgress, Card, Button } from "@mui/material";
import { useUser } from "../contexts/UserContext";
import { useNotification } from "../hooks/useNotification";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { notificationService } from "../services/notificationService";
import NotificationCard from "../components/NotificationCard";
import ErrorAlert from "../components/ErrorAlertProps";
import { format } from "date-fns";
import DeleteIcon from "@mui/icons-material/Delete";
import DoneAllIcon from "@mui/icons-material/DoneAll";
import DeleteConfirmDialog from "../components/DeleteConfirmDialog";

const NotificationsPage: React.FC = () => {
	const queryClient = useQueryClient();
	const { user: authUser } = useUser();
	const {
		data: notifications,
		isLoading,
		error,
	} = useNotification(authUser?.id ?? 0);
	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [selectedNotification, setSelectedNotification] = useState<
		number | null
	>(null);
	const [alertMessage, setAlertMessage] = useState("");
	const [showAlert, setShowAlert] = useState(false);
	const [severity, setSeverity] = useState<"success" | "error">("success");
	const [deleteAllDialogOpen, setDeleteAllDialogOpen] = useState(false);

	const readMutation = useMutation({
		mutationFn: notificationService.readNotification,
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["Notification", authUser?.id],
			});
			setAlertMessage("Notification marked as read");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const readAllMutation = useMutation({
		mutationFn: notificationService.readAllNotifications,
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["Notification", authUser?.id],
			});
			setAlertMessage("All notifications marked as read");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const deleteMutation = useMutation({
		mutationFn: notificationService.deleteNotification,
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["Notification", authUser?.id],
			});
			setAlertMessage("Notification deleted");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const deleteAllMutation = useMutation({
		mutationFn: () =>
			notificationService.deleteAllNotifications(authUser!.id),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["Notification", authUser?.id],
			});
			setAlertMessage("All notifications deleted");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: () => {
			setAlertMessage("Failed to delete notifications");
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const handleReadAll = () => {
		readAllMutation.mutate();
	};

	const handleDelete = (id: number) => {
		setSelectedNotification(id);
		setDeleteDialogOpen(true);
	};

	const confirmDelete = () => {
		if (selectedNotification) {
			deleteMutation.mutate(selectedNotification);
			setDeleteDialogOpen(false);
			setSelectedNotification(null);
		}
	};

	const handleDeleteAll = () => {
		setDeleteAllDialogOpen(true);
	};

	const confirmDeleteAll = () => {
		deleteAllMutation.mutate();
		setDeleteAllDialogOpen(false);
	};

	const groupedNotifications = useMemo(() => {
		if (!notifications) return {};

		// Sort notifications by date (newest first)
		const sortedNotifications = [...notifications].sort(
			(a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()
		);

		// Group by date
		return sortedNotifications.reduce(
			(groups: { [key: string]: typeof notifications }, notification) => {
				const date = format(new Date(notification.date), "PP");
				if (!groups[date]) {
					groups[date] = [];
				}
				groups[date].push(notification);
				return groups;
			},
			{}
		);
	}, [notifications]);

	if (isLoading) {
		return (
			<Box sx={{ display: "flex", justifyContent: "center", p: 3 }}>
				<CircularProgress />
			</Box>
		);
	}

	if (error) {
		return (
			<ErrorAlert
				open={true}
				message="Failed to load notifications"
				severity="error"
				onClose={() => {}}
			/>
		);
	}

	return (
		<Box sx={{ p: 3, maxWidth: 800, mx: "auto" }}>
			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					mb: 3,
					alignItems: "center",
				}}
			>
				<Typography variant="h4" sx={{ color: "var(--color-text)" }}>
					Notifications
				</Typography>
				<Box sx={{ display: "flex", gap: 2 }}>
					<Button
						startIcon={<DoneAllIcon />}
						onClick={handleReadAll}
						disabled={!notifications?.some((n) => !n.isRead)}
						sx={{ color: "var(--color-primary)" }}
					>
						Mark all as read
					</Button>
					<Button
						startIcon={<DeleteIcon />}
						onClick={handleDeleteAll}
						disabled={!notifications?.length}
						sx={{
							color: "var(--color-danger)",
							"&:hover": {
								bgcolor:
									"rgb(from var(--color-danger) r g b / 0.08)",
							},
						}}
					>
						Delete All
					</Button>
				</Box>
			</Box>

			{!notifications || notifications.length === 0 ? (
				<Card
					sx={{
						p: 3,
						textAlign: "center",
						bgcolor: "var(--color-card)",
					}}
				>
					<Typography color="var(--color-text-secondary)">
						No notifications yet
					</Typography>
				</Card>
			) : (
				Object.entries(groupedNotifications).map(
					([date, dateNotifications]) => (
						<Box key={date} sx={{ mb: 4 }}>
							<Typography
								variant="h6"
								sx={{
									color: "var(--color-text-secondary)",
									mb: 2,
									pl: 1,
									borderLeft:
										"4px solid var(--color-primary)",
								}}
							>
								{date}
							</Typography>
							{dateNotifications.map((notification) => (
								<NotificationCard
									key={notification.id}
									notification={notification}
									onRead={() =>
										readMutation.mutate(notification.id)
									}
									onDelete={() =>
										handleDelete(notification.id)
									}
								/>
							))}
						</Box>
					)
				)
			)}

			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={confirmDelete}
				title="Delete Notification"
				message="Are you sure you want to delete this notification?"
			/>

			<DeleteConfirmDialog
				open={deleteAllDialogOpen}
				onClose={() => setDeleteAllDialogOpen(false)}
				onConfirm={confirmDeleteAll}
				title="Delete All Notifications"
				message="Are you sure you want to delete all notifications? This action cannot be undone."
			/>

			<ErrorAlert
				open={showAlert}
				message={alertMessage}
				severity={severity}
				onClose={() => setShowAlert(false)}
			/>
		</Box>
	);
};

export default NotificationsPage;
