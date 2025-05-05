import React from "react";
import { Card, CardContent, Typography, Chip, Box } from "@mui/material";
import { Lab } from "../types/lab";
import RoomIcon from "@mui/icons-material/Room";
import ScheduleView from "./ScheduleView";

interface LabCardProps {
	lab: Lab;
	onView: (lab: Lab) => void;
}

const LabCard: React.FC<LabCardProps> = ({ lab, onView }) => {
	return (
		<Card
			sx={{
				bgcolor: "var(--color-card)",
				color: "var(--color-text)",
				borderRadius: 2,
				height: "100%",
				display: "flex",
				flexDirection: "column",
				transition: "all 0.3s ease-in-out",
				"&:hover": {
					transform: "translateY(-4px)",
					boxShadow: "0 4px 20px rgba(0,0,0,0.1)",
					cursor: "pointer",
				},
			}}
			onClick={() => onView(lab)}
		>
			<CardContent sx={{ flexGrow: 1, position: "relative" }}>
				{lab.started && (
					<Box
						sx={{
							position: "absolute",
							top: 8,
							right: 8,
							display: "flex",
							gap: 1,
							p: 1,
							borderRadius: 1,
							bgcolor: "rgba(0,0,0,0.03)",
						}}
					>
						<Chip
							size="small"
							color={"success"}
							label={"In Progress"}
						/>
					</Box>
				)}
				<Typography
					variant="h5"
					gutterBottom
					sx={{
						fontWeight: "bold",
						color: "var(--color-text)",
						mb: 0.5,
					}}
				>
					{lab.labName}
				</Typography>

				<Typography
					variant="subtitle2"
					color="var(--color-text)"
					gutterBottom
					sx={{ mb: 1 }}
				>
					Code: {lab.labCode}
				</Typography>

				<Typography
					variant="body2"
					color="var(--color-text-secondary)"
					sx={{
						display: "-webkit-box",
						WebkitLineClamp: 2,
						WebkitBoxOrient: "vertical",
						overflow: "hidden",
						textOverflow: "ellipsis",
						mb: 2,
						minHeight: "40px",
					}}
				>
					{lab.description || "No description available"}
				</Typography>

				<Box sx={{ mt: 2, mb: 1 }}>
					<Typography
						variant="body2"
						color="var(--color-text)"
						sx={{
							display: "flex",
							alignItems: "center",
							gap: 1,
							mb: 1,
						}}
					>
						<RoomIcon fontSize="small" />
						{lab.room || "Room not assigned"}
					</Typography>
					<ScheduleView schedules={lab.schedule} />
				</Box>
			</CardContent>
		</Card>
	);
};

export default LabCard;
