import React from "react";
import { Box, Typography } from "@mui/material";
import AccessTimeIcon from "@mui/icons-material/AccessTime";
import { Schedule } from "../types/lab";

interface ScheduleViewProps {
	schedules: Schedule[];
}

const ScheduleView: React.FC<ScheduleViewProps> = ({ schedules }) => {
	const formatTime = (time: string) => {
		return time.substring(0, 5);
	};

	if (!schedules || schedules.length === 0) {
		return (
			<Typography variant="body2" color="var(--color-text-secondary)">
				No schedule available
			</Typography>
		);
	}

	return (
		<Box sx={{ display: "flex", flexDirection: "column" }}>
			<Box sx={{ display: "flex", alignItems: "center", gap: 0.5 }}>
				<AccessTimeIcon
					fontSize="small"
					sx={{ color: "var(--color-text-secondary)" }}
				/>
				<Typography variant="body2" color="var(--color-text-secondary)">
					Schedule:
				</Typography>
			</Box>
			{schedules.map((schedule, index) => (
				<Typography
					key={index}
					variant="body2"
					sx={{
						pl: 4,
						color: "var(--color-text-secondary)",
					}}
				>
					{schedule.dayOfWeek}: {formatTime(schedule.startTime)} -{" "}
					{formatTime(schedule.endTime)}
				</Typography>
			))}
		</Box>
	);
};

export default ScheduleView;
