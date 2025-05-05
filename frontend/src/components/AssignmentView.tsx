import React, { useState } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	Box,
	Typography,
	Button,
	TextField,
	Divider,
} from "@mui/material";
import { AnnouncementDTO } from "../types/announcements";
import { useUser } from "../contexts/UserContext";
import { announcementService } from "../services/announcementService";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import AttachFileIcon from "@mui/icons-material/AttachFile";
import { format } from "date-fns";
import { imageUrl } from "../config/config";
import InputField from "../components/InputField";
import ErrorAlert from "./ErrorAlertProps";

interface AssignmentViewProps {
	open: boolean;
	onClose: () => void;
	assignment: AnnouncementDTO;
	labId: number;
}

const AssignmentView: React.FC<AssignmentViewProps> = ({
	open,
	onClose,
	assignment,
	labId,
}) => {
	const { user } = useUser();
	const [message, setMessage] = useState("");
	const [files, setFiles] = useState<File[]>([]);
	const [submissionGrades, setSubmissionGrades] = useState<Record<number, string>>(() => {
		const initialGrades: Record<number, string> = {};
		assignment.submissions.forEach(submission => {
			initialGrades[submission.userId] = submission.grade?.toString() ?? '';
		});
		return initialGrades;
	});
	const queryClient = useQueryClient();
	const isInstructor = user?.role === "instructor" || user?.role === "admin";
	const fileInputRef = React.useRef<HTMLInputElement>(null);

	const [alertMessage, setAlertMessage] = useState("");
	const [showAlert, setShowAlert] = useState(false);
	const [severity, setSeverity] = useState<
		"error" | "success" | "info" | "warning"
	>("success");

	const handleAlertClose = () => {
		setShowAlert(false);
    };
    
    console.log(assignment);

	const userSubmission = assignment.submissions.find(
		(sub) => sub.userId === user?.id
	);

	const submitMutation = useMutation({
		mutationFn: (formData: FormData) =>
			announcementService.submiteAssignment(
				labId,
				assignment.id!,
				formData
			),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["labAnnouncements", labId],
			});
			setMessage("");
			setFiles([]);
			onClose();
		},
	});

	const gradeMutation = useMutation({
		mutationFn: ({
			submissionId,
			grade,
		}: {
			submissionId: number;
			grade: number;
		}) =>
			announcementService.submitGrade(
				labId,
				assignment.id!,
				submissionId,
				grade
			),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["labAnnouncements", labId],
			});
			setAlertMessage("Grade submitted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
        onError: (error: any) => {
            console.log(error);
			let message = "Failed to submit grade";
			if (error.response?.data?.errors)
				message = error.response.data.errors;
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const handleGradeSubmit = (submissionId: number, gradeValue: string) => {
		const grade = parseInt(gradeValue);
		if (!isNaN(grade) && grade >= 0 && grade <= (assignment.grade ?? 0)) {
			gradeMutation.mutate({ submissionId, grade });
		}
	};

	const handleGradeChange = (submissionId: number, value: string) => {
		setSubmissionGrades(prev => ({
		  ...prev,
		  [submissionId]: value
		}));
	  };

	const handleSubmit = async () => {
		const formData = new FormData();
		formData.append("Message", message);
		files.forEach((file) => {
			formData.append("Files", file);
		});
		await submitMutation.mutateAsync(formData);
	};

	return (
		<Dialog
			open={open}
			onClose={onClose}
			maxWidth="md"
			fullWidth
			PaperProps={{
				sx: {
					bgcolor: "var(--color-card)",
					color: "var(--color-text)",
				},
			}}
		>
			<DialogTitle sx={{ borderBottom: 1, borderColor: "divider" }}>
				Assignment Details
			</DialogTitle>
			<DialogContent>
				<Box sx={{ mt: 2 }}>
					<Typography variant="h6">{assignment.message}</Typography>
					<Typography color="var(--color-text-secondary)">
						Due: {format(new Date(assignment.deadline!), "PPp")}
					</Typography>
					<Typography color="var(--color-text-secondary)">
						Grade: {assignment.grade} points
					</Typography>

					{/* Assignment Files */}
					{assignment.files.length > 0 && (
						<Box sx={{ mt: 2 }}>
							<Typography variant="subtitle1">
								Assignment Files:
							</Typography>
							{assignment.files.map((file, index) => (
								<Button
									key={index}
									variant="outlined"
									size="small"
									onClick={() =>
										window.open(
											`${imageUrl}/${file}`,
											"_blank"
										)
									}
									startIcon={<AttachFileIcon />}
									sx={{
										color: "var(--color-primary)",
										borderColor: "var(--color-primary)",
										"&:hover": {
											borderColor: "var(--color-primary)",
											bgcolor: "var(--color-card-hover)",
										},
										mr: 1,
										mt: 1,
									}}
								>
									{file
										.split("/")
										.pop()
										?.split("_")
										.slice(0, -1)
										.join("_")}
								</Button>
							))}
						</Box>
					)}

					<Divider sx={{ my: 3 }} />

					{!isInstructor && (
						<>
							{userSubmission ? (
								<Box>
									<Typography variant="h6">
										Your Submission
									</Typography>
									<Typography>
										{userSubmission.message}
									</Typography>
									{userSubmission.files.map((file, index) => (
										<Button
											key={index}
											variant="outlined"
											size="small"
											onClick={() =>
												window.open(
													`${imageUrl}/${file}`,
													"_blank"
												)
											}
											startIcon={<AttachFileIcon />}
											sx={{
												color: "var(--color-primary)",
												borderColor:
													"var(--color-primary)",
												"&:hover": {
													borderColor:
														"var(--color-primary)",
													bgcolor:
														"var(--color-card-hover)",
												},
												mr: 1,
												mt: 1,
											}}
										>
											{file
												.split("/")
												.pop()
												?.split("_")
												.slice(0, -1)
												.join("_")}
										</Button>
									))}
									{userSubmission.grade !== null && (
										<Typography sx={{ mt: 2 }}>
											Grade: {userSubmission.grade}/
											{assignment.grade}
										</Typography>
									)}
								</Box>
							) : (
								<Box>
									<Typography variant="h6">
										Submit Assignment
									</Typography>
									<TextField
										fullWidth
										multiline
										rows={4}
										value={message}
										onChange={(e) =>
											setMessage(e.target.value)
										}
										placeholder="Your submission message..."
										sx={{
											mt: 2,
											"& .MuiOutlinedInput-root": {
												bgcolor:
													"var(--color-background)",
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
											},
											"& .MuiInputLabel-root": {
												color: "var(--color-text)",
												"&.Mui-focused": {
													color: "var(--color-primary)",
												},
											},
										}}
									/>
									<Button
										variant="outlined"
										onClick={() =>
											fileInputRef.current?.click()
										}
										sx={{
											color: "var(--color-primary)",
											borderColor: "var(--color-primary)",
											"&:hover": {
												borderColor:
													"var(--color-primary)",
												bgcolor:
													"var(--color-card-hover)",
											},
											mr: 1,
											mt: 1,
										}}
									>
										Attach Files
									</Button>
									<input
										type="file"
										multiple
										ref={fileInputRef}
										onChange={(e) =>
											setFiles(
												Array.from(e.target.files || [])
											)
										}
										style={{ display: "none" }}
									/>
									{files.length > 0 && (
										<Typography
											variant="caption"
											sx={{ ml: 2 }}
										>
											{files.length} file(s) selected
										</Typography>
									)}
									<Button
										variant="contained"
										onClick={handleSubmit}
										sx={{
											mt: 2,
											display: "block",
											bgcolor: "var(--color-primary)",
											color: "var(--color-text-button)",
											"&:hover": {
												bgcolor:
													"rgb(from var(--color-primary) r g b / 0.8)",
											},
										}}
										disabled={
											!message.trim() &&
											files.length === 0
										}
									>
										Submit Assignment
									</Button>
								</Box>
							)}
						</>
					)}

					{isInstructor && (
						<Box>
							<Typography variant="h6">
								Submissions ({assignment.submissions.length})
							</Typography>
							{assignment.submissions.map((submission) => (
								<Box key={submission.userId} sx={{ mt: 3 }}>
									<Typography variant="subtitle1">
										{submission.user.name}
									</Typography>
									<Typography>
										{submission.message}
									</Typography>
									{submission.files.map((file, index) => (
										<Button
											key={index}
											variant="outlined"
											size="small"
											onClick={() =>
												window.open(
													`${imageUrl}/${file}`,
													"_blank"
												)
											}
											startIcon={<AttachFileIcon />}
											sx={{
												color: "var(--color-primary)",
												borderColor:
													"var(--color-primary)",
												"&:hover": {
													borderColor:
														"var(--color-primary)",
													bgcolor:
														"var(--color-card-hover)",
												},
												mr: 1,
												mt: 1,
											}}
										>
											{file
												.split("/")
												.pop()
												?.split("_")
												.slice(0, -1)
												.join("_")}
										</Button>
									))}
									<Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mt: 2 }}>
										<InputField
											label="Grade"
											name="grade"
											type="number"
											value={submissionGrades[submission.userId] || ''}
											placeholder="Enter grade"
											id={`grade-${submission.userId}`}
											onChange={(e) => handleGradeChange(submission.userId, e.target.value)}
											disabled={gradeMutation.isPending}
										/>
										<Button
											variant="contained"
											onClick={() => handleGradeSubmit(
												submission.userId,
												submissionGrades[submission.userId] ?? submission.grade?.toString() ?? ''
											)}
											disabled={gradeMutation.isPending || 
												!submissionGrades[submission.userId] && submission.grade !== null}
											sx={{
												bgcolor: submission.grade !== null ? "var(--color-warning)" : "var(--color-primary)",
												color: "var(--color-text-button)",
												whiteSpace: "nowrap",
												minWidth: "120px",
												"&:hover": {
													bgcolor: submission.grade !== null 
													? "rgb(from var(--color-warning) r g b / 0.8)"
													: "rgb(from var(--color-primary) r g b / 0.8)",
												},
											}}
										>
											{submission.grade !== null ? "Update Grade" : "Submit Grade"}
										</Button>
									</Box>
								</Box>
							))}
						</Box>
					)}
				</Box>
			</DialogContent>
			<ErrorAlert
				open={showAlert}
				message={alertMessage}
				severity={severity}
				onClose={handleAlertClose}
			/>
		</Dialog>
	);
};

export default AssignmentView;
