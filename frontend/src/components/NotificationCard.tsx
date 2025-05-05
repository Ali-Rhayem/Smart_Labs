import React from "react";
import { Card, Box, Typography, IconButton, Divider } from "@mui/material";
import DoneAllIcon from "@mui/icons-material/DoneAll";
import DeleteIcon from "@mui/icons-material/Delete";
import { Notification } from "../types/notification";
import { format } from "date-fns";

interface NotificationCardProps {
	notification: Notification;
	onRead: (id: number) => void;
	onDelete: (id: number) => void;
}

const NotificationCard: React.FC<NotificationCardProps> = ({
	notification,
	onRead,
	onDelete,
}) => {
	return (
		<Card
			sx={{
				mb: 2,
				p: 2,
				bgcolor: notification.isRead
					? "var(--color-card)"
					: "var(--color-card-hover)",
				borderLeft: notification.isRead ? "none" : "4px solid var(--color-primary)",
				transition: "all 0.2s",
				"&:hover": {
					bgcolor: "var(--color-card-hover)",
					transform: "translateX(4px)",
				},
			}}
		>
			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					alignItems: "flex-start",
				}}
			>
				<Box sx={{ flex: 1 }}>
					<Typography
						variant="h6"
						sx={{ 
							color: "var(--color-text)",
							opacity: notification.isRead ? 0.8 : 1,
							mb: 1 
						}}
					>
						{notification.title}
					</Typography>
					<Typography 
						sx={{ 
							color: "var(--color-text)",
							opacity: notification.isRead ? 0.7 : 1,
							mb: 2 
						}}
					>
						{notification.message}
					</Typography>
				</Box>
				<Box sx={{ display: "flex", gap: 1 }}>
					{!notification.isRead && (
						<IconButton
							onClick={() => onRead(notification.id)}
							size="small"
							sx={{
								color: "var(--color-primary)",
							}}
						>
							<DoneAllIcon />
						</IconButton>
					)}
					<IconButton
						onClick={() => onDelete(notification.id)}
						size="small"
						sx={{
							color: "var(--color-danger)",
						}}
					>
						<DeleteIcon />
					</IconButton>
				</Box>
			</Box>
			<Divider sx={{ my: 1 }} />
			<Typography
				variant="caption"
				sx={{ 
					color: "var(--color-text-secondary)",
					opacity: notification.isRead ? 0.7 : 1
				}}
			>
				{format(new Date(notification.date), "PPpp")}
			</Typography>
		</Card>
	);
};

export default NotificationCard;
