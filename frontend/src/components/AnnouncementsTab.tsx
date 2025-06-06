import React, { useState, useMemo, useRef } from "react";
import {
	Box,
	Card,
	Typography,
	Button,
	TextField,
	IconButton,
	Avatar,
	Divider,
	Paper,
	Collapse,
	Badge,
	Skeleton,
} from "@mui/material";
import { useLabAnnouncements } from "../hooks/useLabsQuery";
import AttachFileIcon from "@mui/icons-material/AttachFile";
import SendIcon from "@mui/icons-material/Send";
import { useUser } from "../contexts/UserContext";
import { format } from "date-fns";
import { imageUrl } from "../config/config";
import CommentIcon from "@mui/icons-material/Comment";
import KeyboardArrowDownIcon from "@mui/icons-material/KeyboardArrowDown";
import KeyboardArrowUpIcon from "@mui/icons-material/KeyboardArrowUp";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { announcementService } from "../services/announcementService";
import { Comment } from "../types/announcements";
import DeleteIcon from "@mui/icons-material/Delete";
import DeleteConfirmDialog from "./DeleteConfirmDialog";
import ErrorAlert from "./ErrorAlertProps";
import AssignmentModal, { AssignmentData } from "./AssignmentModal";
import AssignmentView from "./AssignmentView";
import { AnnouncementDTO } from "../types/announcements";

// Add constants
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB in bytes
const ALLOWED_FILE_TYPES = [
	"application/pdf", // PDF
	"application/msword", // DOC
	"application/vnd.openxmlformats-officedocument.wordprocessingml.document", // DOCX
];

interface AnnouncementsTabProps {
	labId: number;
}

const AnnouncementsTab: React.FC<AnnouncementsTabProps> = ({ labId }) => {
	const { user } = useUser();
	const { data: announcements, isLoading } = useLabAnnouncements(labId);
	const [message, setMessage] = useState("");
	const [commentInputs, setCommentInputs] = useState<{
		[key: number]: string;
	}>({});
	const [expandedComments, setExpandedComments] = useState<{
		[key: number]: boolean;
	}>({});
	const [files, setFiles] = useState<File[]>([]);
	const fileInputRef = useRef<HTMLInputElement>(null);
	const queryClient = useQueryClient();
	const isInstructor = user?.role === "instructor";

	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [selectedAnnouncementId, setSelectedAnnouncementId] = useState<
		number | null
	>(null);

	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("error");
	const [showAlert, setShowAlert] = useState(false);

	const [selectedCommentId, setSelectedCommentId] = useState<number | null>(
		null
	);
	const [deleteCommentDialogOpen, setDeleteCommentDialogOpen] =
		useState(false);

	const [assignmentModalOpen, setAssignmentModalOpen] = useState(false);

	// Add state for assignment view
	const [selectedAssignment, setSelectedAssignment] =
		useState<AnnouncementDTO | null>(null);

	const handleCommentChange = (announcementId: number, value: string) => {
		setCommentInputs((prev) => ({
			...prev,
			[announcementId]: value,
		}));
	};

	const handleSubmitComment = (announcementId: number) => {
		const commentText = commentInputs[announcementId];
		if (!commentText?.trim()) return;

		sendCommentMutation
			.mutateAsync({
				announcementId,
				comment: { message: commentText.trim() },
			})
			.then(() => {
				// Clear this announcement's comment after successful submission
				setCommentInputs((prev) => ({
					...prev,
					[announcementId]: "",
				}));
			});
	};

	const toggleComments = (announcementId: number) => {
		setExpandedComments((prev) => ({
			...prev,
			[announcementId]: !prev[announcementId],
		}));
	};

	const sortedAnnouncements = useMemo(() => {
		if (!announcements) return [];

		return [...announcements]
			.sort(
				(a, b) =>
					new Date(a.time).getTime() - new Date(b.time).getTime()
			)
			.map((announcement) => ({
				...announcement,
				comments: [...announcement.comments].sort(
					(a, b) =>
						new Date(b.time).getTime() - new Date(a.time).getTime()
				),
			}));
	}, [announcements]);

	const renderLoadingSkeleton = () => (
		<Box sx={{ p: 2 }}>
			{[1, 2, 3].map((n) => (
				<Card
					key={n}
					sx={{
						mb: 2,
						p: 2,
						backgroundColor: "var(--color-card)",
						color: "var(--color-text)",
					}}
				>
					<Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
						<Skeleton
							variant="circular"
							width={40}
							height={40}
							sx={{ bgcolor: "var(--color-card-hover)" }}
						/>
						<Box sx={{ ml: 2, flex: 1 }}>
							<Skeleton
								variant="text"
								width="30%"
								sx={{ bgcolor: "var(--color-card-hover)" }}
							/>
							<Skeleton
								variant="text"
								width="20%"
								sx={{ bgcolor: "var(--color-card-hover)" }}
							/>
						</Box>
					</Box>
					<Skeleton
						variant="rectangular"
						height={60}
						sx={{ mb: 1, bgcolor: "var(--color-card-hover)" }}
					/>
				</Card>
			))}
		</Box>
	);

	const sendAnnouncementMutation = useMutation({
		mutationFn: (formData: FormData) =>
			announcementService.sendAnnouncement(labId, formData),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["labAnnouncements", labId],
			});
			setMessage("");
			setFiles([]);
			setAlertMessage("Announcement sent successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to send announcement";
			if (error.response?.data?.errors)
				message = error.response?.data?.errors;
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const sendCommentMutation = useMutation({
		mutationFn: ({
			announcementId,
			comment,
		}: {
			announcementId: number;
			comment: Comment;
		}) =>
			announcementService.CommentOnAnnouncement(
				labId,
				announcementId,
				comment
			),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["labAnnouncements", labId],
			});
		},
		onError: (error: any) => {
			let message = "Failed to send comment";
			if (error.response?.data?.errors)
				message = error.response?.data?.errors;
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const deleteAnnouncementMutation = useMutation({
		mutationFn: (announcementId: number) =>
			announcementService.deleteAnnouncement(labId, announcementId),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["labAnnouncements", labId],
			});
			setDeleteDialogOpen(false);
			setSelectedAnnouncementId(null);
			setAlertMessage("Announcement deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to delete announcement";
			if (error.response?.data?.errors)
				message = error.response?.data?.errors;
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const deleteCommentMutation = useMutation({
		mutationFn: ({
			announcementId,
			commentId,
		}: {
			announcementId: number;
			commentId: number;
		}) =>
			announcementService.deleteComment(labId, announcementId, commentId),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["labAnnouncements", labId],
			});
			setDeleteCommentDialogOpen(false);
			setSelectedCommentId(null);
			setAlertMessage("Comment deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to delete comment";
			if (error.response?.data?.errors)
				message = error.response?.data?.errors;
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	// Update handleFileSelect
	const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
		if (event.target.files) {
			const selectedFiles = Array.from(event.target.files);

			// Validate each file
			const invalidFiles = selectedFiles.filter(
				(file) =>
					!ALLOWED_FILE_TYPES.includes(file.type) ||
					file.size > MAX_FILE_SIZE
			);

			if (invalidFiles.length > 0) {
				setAlertMessage(
					"Only PDF and Word documents up to 10MB are allowed"
				);
				setSeverity("error");
				setShowAlert(true);
				event.target.value = ""; // Clear file input
				return;
			}

			setFiles(selectedFiles);
		}
	};

	// Update handleSendAnnouncement
	const handleSendAnnouncement = async () => {
		if (!message.trim()) return;

		try {
			const formData = new FormData();
			formData.append("Message", message.trim());

			files.forEach((file) => {
				if (
					file.size <= MAX_FILE_SIZE &&
					ALLOWED_FILE_TYPES.includes(file.type)
				) {
					formData.append("Files", file);
				}
			});

			await sendAnnouncementMutation.mutateAsync(formData);
		} catch (error) {
			setAlertMessage("Failed to send announcement");
			setSeverity("error");
			setShowAlert(true);
		}
	};

	const handleAssignmentSubmit = async (data: AssignmentData) => {
		const formData = new FormData();
		formData.append("Message", data.message);
		formData.append("Deadline", data.deadline.toISOString());
		formData.append("Grade", data.grade.toString());
		formData.append("assignment", "true");
		formData.append("canSubmit", "true");

		data.files.forEach((file) => {
			formData.append("Files", file);
		});

		await sendAnnouncementMutation.mutateAsync(formData);
	};

	const handleDeleteClick = (announcementId: number) => {
		setSelectedAnnouncementId(announcementId);
		setDeleteDialogOpen(true);
	};

	const handleConfirmDelete = () => {
		if (selectedAnnouncementId) {
			deleteAnnouncementMutation.mutate(selectedAnnouncementId);
		}
		setDeleteDialogOpen(false);
	};

	const handleDeleteComment = (announcementId: number, commentId: number) => {
		setSelectedCommentId(commentId);
		setSelectedAnnouncementId(announcementId);
		setDeleteCommentDialogOpen(true);
	};

	const handleConfirmDeleteComment = () => {
		if (selectedCommentId && selectedAnnouncementId) {
			deleteCommentMutation.mutate({
				announcementId: selectedAnnouncementId,
				commentId: selectedCommentId,
			});
			setDeleteCommentDialogOpen(false);
		}
	};

	// Add click handler for assignment cards
	const handleAssignmentClick = (announcement: AnnouncementDTO) => {
		if (announcement.assignment) {
			setSelectedAssignment(announcement);
		}
	};

	return (
		<Box sx={{ height: "100%", display: "flex", flexDirection: "column" }}>
			{isLoading ? (
				renderLoadingSkeleton()
			) : (
				<Box sx={{ flexGrow: 1, overflow: "auto", mb: 2 }}>
					{sortedAnnouncements.map((announcement) => (
						<Card
							key={announcement.id}
							sx={{
								mb: 2,
								p: 2,
								backgroundColor: "var(--color-card)",
								color: "var(--color-text)",
								cursor: announcement.assignment
									? "pointer"
									: "default",
							}}
							onClick={() => handleAssignmentClick(announcement)}
						>
							{/* Announcement Header */}
							<Box
								sx={{
									display: "flex",
									alignItems: "center",
									mb: 2,
								}}
							>
								<Avatar
									src={`${imageUrl}/${announcement.user.image}`}
								/>
								<Box sx={{ ml: 2, flex: 1 }}>
									<Typography
										variant="subtitle1"
										fontWeight="bold"
									>
										{announcement.user.name}
									</Typography>
									<Typography
										variant="caption"
										color="var(--color-text-secondary)"
									>
										{format(
											new Date(announcement.time),
											"PPp"
										)}
									</Typography>
								</Box>
								{announcement.user.id === user?.id && (
									<IconButton
										onClick={() =>
											handleDeleteClick(announcement.id!)
										}
										sx={{
											color: "var(--color-danger)",
											"&:hover": {
												bgcolor:
													"rgb(from var(--color-danger) r g b / 0.08)",
											},
										}}
									>
										<DeleteIcon />
									</IconButton>
								)}
							</Box>

							{/* Announcement Content */}
							<Typography sx={{ mb: 2 }}>
								{announcement.message}
							</Typography>

							{/* Files */}
							{announcement.files.length > 0 && (
								<Box sx={{ mb: 2 }}>
									{announcement.files.map((file, index) => (
										// onclick file download
										<Button
											key={index}
											variant="outlined"
											size="small"
											onClick={(e) => {
												e.stopPropagation();
												window.open(
													`${imageUrl}/${file}`,
													"_blank"
												);
											}}
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
								</Box>
							)}

							<Box
								sx={{
									display: "flex",
									justifyContent: "space-between",
									alignItems: "center",
									mb: 1,
								}}
							>
								<Badge
									badgeContent={announcement.comments.length}
									sx={{
										"& .MuiBadge-badge": {
											bgcolor: "var(--color-primary)",
											color: "var(--color-text-button)",
											zIndex: 1,
										},
									}}
								>
									<IconButton
										onClick={() =>
											toggleComments(announcement.id!)
										}
										sx={{
											color: "var(--color-text-secondary)",
										}}
									>
										<CommentIcon />
										{expandedComments[announcement.id!] ? (
											<KeyboardArrowUpIcon />
										) : (
											<KeyboardArrowDownIcon />
										)}
									</IconButton>
								</Badge>
							</Box>

							<Collapse
								in={expandedComments[announcement.id!]}
								timeout="auto"
							>
								<Divider sx={{ my: 2 }} />

								{/* Comments Section */}
								<Box sx={{ pl: 2 }}>
									{announcement.comments.map((comment) => (
										<Box
											key={comment.id}
											sx={{ display: "flex", mb: 2 }}
										>
											<Avatar
												src={`${imageUrl}/${comment.user.image}`}
												sx={{ width: 32, height: 32 }}
											/>
											<Box sx={{ ml: 1, flex: 1 }}>
												<Box
													sx={{
														display: "flex",
														alignItems: "baseline",
													}}
												>
													<Typography variant="subtitle2">
														{comment.user.name}
													</Typography>
													<Typography
														variant="caption"
														color="var(--color-text-secondary)"
														sx={{ ml: 1 }}
													>
														{format(
															new Date(
																comment.time
															),
															"PPp"
														)}
													</Typography>
												</Box>
												<Typography variant="body2">
													{comment.message}
												</Typography>
											</Box>
											{(comment.user.id === user?.id ||
												isInstructor) && (
												<IconButton
													onClick={() =>
														handleDeleteComment(
															announcement.id!,
															comment.id!
														)
													}
													sx={{
														color: "var(--color-danger)",
														p: 0.5,
														"&:hover": {
															bgcolor:
																"rgb(from var(--color-danger) r g b / 0.08)",
														},
													}}
												>
													<DeleteIcon fontSize="small" />
												</IconButton>
											)}
										</Box>
									))}

									{/* Comment Input */}
									<Box
										sx={{
											display: "flex",
											alignItems: "center",
											mt: 2,
										}}
									>
										<TextField
											size="small"
											fullWidth
											placeholder="Add a comment..."
											value={
												commentInputs[
													announcement.id!
												] || ""
											}
											onChange={(e) =>
												handleCommentChange(
													announcement.id!,
													e.target.value
												)
											}
											sx={{
												mr: 1,
												"& .MuiOutlinedInput-root": {
													bgcolor:
														"var(--color-card)",
													"& fieldset": {
														borderColor:
															"var(--color-text-secondary)",
													},
													"&:hover fieldset": {
														borderColor:
															"var(--color-primary)",
													},
													"&.Mui-focused fieldset": {
														borderColor:
															"var(--color-primary)",
													},
													input: {
														color: "var(--color-text)",
													},
												},
												"& .MuiInputLabel-root": {
													color: "var(--color-text-secondary)",
													"&.Mui-focused": {
														color: "var(--color-primary)",
													},
												},
											}}
										/>
										<IconButton
											sx={{
												color: "var(--color-primary)",
											}}
											onClick={() =>
												handleSubmitComment(
													announcement.id!
												)
											}
											disabled={
												!commentInputs[
													announcement.id!
												]?.trim()
											}
										>
											<SendIcon />
										</IconButton>
									</Box>
								</Box>
							</Collapse>
						</Card>
					))}
				</Box>
			)}

			{/* Announcement Input */}
			{isInstructor && (
				<Paper
					elevation={3}
					sx={{
						zIndex: 2,
						p: 2,
						position: "sticky",
						bottom: 0,
						bgcolor: "var(--color-card)",
					}}
				>
					<input
						type="file"
						multiple
						ref={fileInputRef}
						onChange={handleFileSelect}
						style={{ display: "none" }}
					/>

					<TextField
						fullWidth
						multiline
						rows={2}
						placeholder="Write an announcement..."
						value={message}
						onChange={(e) => setMessage(e.target.value)}
						sx={{
							mb: 2,
							"& .MuiOutlinedInput-root": {
								"& fieldset": {
									borderColor: "var(--color-text-secondary)",
								},
								"&:hover fieldset": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused fieldset": {
									borderColor: "var(--color-primary)",
								},
								textarea: {
									color: "var(--color-text)",
								},
							},
							"& .MuiInputLabel-root": {
								color: "var(--color-text-secondary)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
							},
						}}
					/>
					<Box
						sx={{
							display: "flex",
							justifyContent: "space-between",
						}}
					>
						<Box
							sx={{
								display: "flex",
								gap: 1,
								alignItems: "center",
							}}
						>
							<Button
								variant="outlined"
								onClick={() => fileInputRef.current?.click()}
								sx={{
									color: "var(--color-primary)",
									borderColor: "var(--color-primary)",
								}}
								startIcon={<AttachFileIcon />}
							>
								Attach Files
							</Button>
							{files.length > 0 && (
								<Typography
									variant="caption"
									color="var(--color-text-secondary)"
								>
									{files.length} file(s) selected
								</Typography>
							)}
						</Box>
						<Box sx={{ display: "flex", gap: 1 }}>
							<Button
								variant="contained"
								onClick={() => setAssignmentModalOpen(true)}
								sx={{
									backgroundColor: "var(--color-primary)",
									color: "var(--color-text-button)",
								}}
							>
								Create Assignment
							</Button>
							<Button
								variant="contained"
								onClick={handleSendAnnouncement}
								disabled={
									!message.trim() ||
									sendAnnouncementMutation.isPending
								}
								sx={{
									backgroundColor: "var(--color-primary)",
									color: "var(--color-text-button)",
								}}
								endIcon={<SendIcon />}
							>
								{sendAnnouncementMutation.isPending
									? "Sending..."
									: "Announce"}
							</Button>
						</Box>
					</Box>
				</Paper>
			)}
			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={handleConfirmDelete}
				title="Delete Announcement"
				message="Are you sure you want to delete this announcement? This action cannot be undone."
			/>
			<DeleteConfirmDialog
				open={deleteCommentDialogOpen}
				onClose={() => setDeleteCommentDialogOpen(false)}
				onConfirm={handleConfirmDeleteComment}
				title="Delete Comment"
				message="Are you sure you want to delete this comment?"
			/>
			<ErrorAlert
				open={showAlert}
				message={alertMessage}
				severity={severity}
				onClose={() => setShowAlert(false)}
			/>
			<AssignmentModal
				open={assignmentModalOpen}
				onClose={() => setAssignmentModalOpen(false)}
				onSubmit={handleAssignmentSubmit}
			/>
			{/* Add AssignmentView */}
			{selectedAssignment && (
				<AssignmentView
					open={!!selectedAssignment}
					onClose={() => setSelectedAssignment(null)}
					assignment={selectedAssignment}
					labId={labId}
				/>
			)}
		</Box>
	);
};

export default AnnouncementsTab;
