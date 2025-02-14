import React from "react";
import { Box, Button, FormHelperText, IconButton } from "@mui/material";
import DeleteIcon from "@mui/icons-material/Delete";
import Dropdown from "./Dropdown";
import InputField from "./InputField";
import { Schedule } from "../types/lab";

interface ScheduleSelectProps {
	schedules: Schedule[];
	onChange: (schedules: Schedule[]) => void;
	error?: string[] | null;
}

const days = [
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
	"Sunday",
];

const ScheduleSelect: React.FC<ScheduleSelectProps> = ({
	schedules,
	onChange,
	error,
}) => {
	const handleAdd = () => {
		onChange([
			...schedules,
			{ dayOfWeek: "Monday", startTime: "", endTime: "" },
		]);
	};

	const handleDelete = (index: number) => {
		const newSchedules = [...schedules];
		newSchedules.splice(index, 1);
		onChange(newSchedules);
	};

	const updateSchedule = (
		index: number,
		field: keyof Schedule,
		value: string
	) => {
		const newSchedules = [...schedules];
		newSchedules[index] = { ...newSchedules[index], [field]: value };
		onChange(newSchedules);
	};

	return (
		<Box sx={{ mb: 2 }}>
			{schedules.map((schedule, index) => (
				<Box
					key={index}
					sx={{
						display: "flex",
						gap: 2,
						mb: 2,
						alignItems: "flex-start",
					}}
				>
					<Dropdown
						label="Day"
						value={schedule.dayOfWeek}
						options={days.map((day) => ({
							value: day,
							label: day,
						}))}
						onChange={(value) =>
							updateSchedule(index, "dayOfWeek", value)
						}
					/>
					<InputField
						label="Start Time"
						type="time"
						name={`startTime-${index}`}
						placeholder="Start Time"
						id={`startTime-${index}`}
						value={schedule.startTime}
						onChange={(e) =>
							updateSchedule(index, "startTime", e.target.value)
						}
					/>
					<InputField
						label="End Time"
						type="time"
						name={`endTime-${index}`}
						placeholder="End Time"
						id={`endTime-${index}`}
						value={schedule.endTime}
						onChange={(e) =>
							updateSchedule(index, "endTime", e.target.value)
						}
					/>
					<IconButton
						onClick={() => handleDelete(index)}
						sx={{
							color: "var(--color-danger)",
							mt: 2,
						}}
					>
						<DeleteIcon />
					</IconButton>
				</Box>
			))}
			<Button
				onClick={handleAdd}
				sx={{
					color: "var(--color-primary)",
					"&:hover": {
						bgcolor: "rgb(from var(--color-primary) r g b / 0.08)",
					},
				}}
			>
				Add Schedule
			</Button>
			{error && error.length > 0 && (
				<FormHelperText error>{error.join(", ")}</FormHelperText>
			)}
		</Box>
	);
};

export default ScheduleSelect;
