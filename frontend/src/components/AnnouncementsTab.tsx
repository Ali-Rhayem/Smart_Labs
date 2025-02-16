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
import { Announcement } from "../types/announcements";

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

	const handleCommentChange = (announcementId: number, value: string) => {
		setCommentInputs((prev) => ({
			...prev,
			[announcementId]: value,
		}));
	};

	const handleSubmitComment = (announcementId: number) => {
		// Your submit logic here
		const commentText = commentInputs[announcementId];
		if (!commentText?.trim()) return;

		// After submission, clear only this announcement's comment
		setCommentInputs((prev) => ({
			...prev,
			[announcementId]: "",
		}));
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
		mutationFn: (announcement: Announcement) =>
			announcementService.sendAnnouncement(labId, announcement),
		onSuccess: () => {
			queryClient.invalidateQueries({
				queryKey: ["labAnnouncements", labId],
			});
			setMessage("");
			setFiles([]);
		},
		onError: (error) => {
			console.error("Failed to send announcement:", error);
		},
	});

	const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
		if (event.target.files) {
			setFiles(Array.from(event.target.files));
		}
	};

	const handleSendAnnouncement = async () => {
		if (!message.trim()) return;

		const formData = new FormData();
		files.forEach((file) => {
			formData.append("files", file);
		});
		formData.append("message", message);

		await sendAnnouncementMutation.mutateAsync({
			message,
			files: [],
		} as Announcement);
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
							}}
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
								<Box sx={{ ml: 2 }}>
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
							</Box>

							{/* Announcement Content */}
							<Typography sx={{ mb: 2 }}>
								{announcement.message}
							</Typography>

							{/* Files */}
							{announcement.files.length > 0 && (
								<Box sx={{ mb: 2 }}>
									{announcement.files.map((file, index) => (
										<Button
											key={index}
											variant="outlined"
											size="small"
											startIcon={<AttachFileIcon />}
											sx={{ mr: 1, mb: 1 }}
										>
											{file.split("/").pop()}
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
												src={`${imageUrl}/${announcement.user.image}`}
												sx={{ width: 32, height: 32 }}
											/>
											<Box sx={{ ml: 1 }}>
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
				</Paper>
			)}
		</Box>
	);
};

export default AnnouncementsTab;
