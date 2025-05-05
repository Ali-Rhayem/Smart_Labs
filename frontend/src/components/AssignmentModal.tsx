import React, { useRef, useState } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
	Box,
} from "@mui/material";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DateTimePicker } from "@mui/x-date-pickers/DateTimePicker";
import dayjs, { Dayjs } from "dayjs";
import InputField from "./InputField";

interface AssignmentModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (data: AssignmentData) => void;
}

export interface AssignmentData {
	message: string;
	files: File[];
	deadline: Dayjs;
	grade: number;
}

const AssignmentModal: React.FC<AssignmentModalProps> = ({
	open,
	onClose,
	onSubmit,
}) => {
	const [message, setMessage] = useState("");
	const [files, setFiles] = useState<File[]>([]);
	const [deadline, setDeadline] = useState<Dayjs | null>(dayjs());
	const [grade, setGrade] = useState<number>(100);
	const fileInputRef = useRef<HTMLInputElement>(null);

	const resetForm = () => {
		setMessage("");
		setFiles([]);
		setDeadline(dayjs());
		setGrade(100);
	};

	const handleSubmit = () => {
		if (!message.trim() || !deadline || grade <= 0) return;
		onSubmit({ message, files, deadline, grade });
		resetForm();
		onClose();
	};

	const handleClose = () => {
		resetForm();
		onClose();
	};

	return (
		<Dialog
			open={open}
			onClose={handleClose}
			maxWidth="sm"
			fullWidth
			PaperProps={{
				sx: {
					bgcolor: "var(--color-card)",
					color: "var(--color-text)",
				},
			}}
		>
			<DialogTitle sx={{ borderBottom: 1, borderColor: "divider" }}>
				Create Assignment
			</DialogTitle>
			<DialogContent>
				<Box
					sx={{
						display: "flex",
						flexDirection: "column",
						gap: 2,
						mt: 2,
					}}
				>
					<InputField
						label="Assignment Description"
						name="description"
						type="text"
						value={message}
						placeholder="Enter assignment description"
						id="assignment-description"
						onChange={(e) => setMessage(e.target.value)}
						multiline
						rows={4}
					/>
					<InputField
						label="Total Grade"
						name="grade"
						type="number"
						value={grade.toString()}
						placeholder="Enter total grade"
						id="assignment-grade"
						onChange={(e) => setGrade(Number(e.target.value))}
					/>

					<LocalizationProvider dateAdapter={AdapterDayjs}>
						<DateTimePicker
							label="Deadline"
							value={deadline}
							onChange={(newValue) => setDeadline(newValue)}
							slotProps={{
								textField: {
									required: true,
									sx: {
										"& .MuiOutlinedInput-root": {
											borderRadius: "10px",
											bgcolor: "var(--color-background)",
											color: "var(--color-text)",
											"& fieldset": {
												borderColor:
													"var(--color-border)",
											},
											"&:hover fieldset": {
												borderColor:
													"var(--color-border)",
											},
											"&.Mui-focused fieldset": {
												borderColor:
													"var(--color-primary)",
											},
											"& .MuiInputAdornment-root": {
												color: "var(--color-primary)",
											},
											"& .MuiSvgIcon-root": {
												color: "var(--color-primary)",
											},
										},
										"& .MuiInputLabel-root": {
											color: "var(--color-text)",
											"&.Mui-focused": {
												color: "var(--color-primary)",
											},
										},
									},
								},
								popper: {
									sx: {
										"& .MuiPaper-root": {
											bgcolor: "var(--color-card)",
											color: "var(--color-text)",
											border: "1px solid var(--color-border)",
										},
										"& .MuiPickersDay-root": {
											color: "var(--color-text)",
											"&:hover": {
												bgcolor:
													"var(--color-card-hover)",
											},
											"&.Mui-selected": {
												bgcolor: "var(--color-primary)",
												color: "var(--color-text-button)",
											},
										},
										"& .MuiClock-clock": {
											bgcolor: "var(--color-card)",
											color: "var(--color-text)",
										},
										"& .MuiClockPointer-root": {
											bgcolor: "var(--color-primary)",
										},
										"& .MuiClockPointer-thumb": {
											border: "16px solid var(--color-primary)",
										},
									},
								},
							}}
						/>
					</LocalizationProvider>

					<Button
						variant="outlined"
						onClick={() => fileInputRef.current?.click()}
						sx={{
							color: "var(--color-primary)",
							borderColor: "var(--color-primary)",
							"&:hover": {
								borderColor: "var(--color-primary)",
							},
						}}
					>
						Attach Files
					</Button>
					<input
						type="file"
						multiple
						ref={fileInputRef}
						onChange={(e) =>
							setFiles(Array.from(e.target.files || []))
						}
						style={{ display: "none" }}
					/>
					{files.length > 0 && (
						<Box sx={{ color: "var(--color-text)" }}>
							{files.length} file(s) selected
						</Box>
					)}
				</Box>
			</DialogContent>
			<DialogActions sx={{ p: 2, borderTop: 1, borderColor: "divider" }}>
				<Button
					onClick={handleClose}
					sx={{ color: "var(--color-danger)" }}
				>
					Cancel
				</Button>
				<Button
					onClick={handleSubmit}
					disabled={!message.trim() || !deadline || grade <= 0}
					variant="contained"
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-primary) r g b / 0.8)",
						},
					}}
				>
					Create Assignment
				</Button>
			</DialogActions>
		</Dialog>
	);
};

export default AssignmentModal;
