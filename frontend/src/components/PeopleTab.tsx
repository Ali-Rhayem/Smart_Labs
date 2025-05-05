import React, { useState } from "react";
import {
	Box,
	Typography,
	Grid,
	Avatar,
	Divider,
	IconButton,
	Button,
	Skeleton,
	Card,
	CardContent,
} from "@mui/material";
import { User } from "../types/user";
import { imageUrl } from "../config/config";
import PersonRemoveIcon from "@mui/icons-material/PersonRemove";
import PersonAddIcon from "@mui/icons-material/PersonAdd";
import SchoolIcon from "@mui/icons-material/School";
import { AddPeopleModal } from "./AddPeopleModal";

interface UserCardProps {
	user: User;
	canRemove?: boolean;
	onRemove?: (user: User) => void;
}

const UserCard: React.FC<UserCardProps> = ({ user, canRemove, onRemove }) => (
	<Box
		sx={{
			p: 2,
			display: "flex",
			alignItems: "center",
			gap: 2,
			bgcolor: "var(--color-card)",
			borderRadius: 1,
			position: "relative",
			"&:hover": {
				bgcolor: "var(--color-card-hover)",
				"& .remove-button": {
					opacity: 1,
				},
			},
		}}
	>
		<Avatar
			src={`${imageUrl}/${user.image}`}
			alt={user.name}
			sx={{ width: 50, height: 50 }}
		/>
		<Box>
			<Typography variant="subtitle1">{user.name}</Typography>
			<Typography variant="body2" color="var(--color-text-secondary)">
				{user.role === "student"
					? user.email
					: user.major || user.faculty || "No department info"}
			</Typography>
		</Box>
		{canRemove && (
			<IconButton
				className="remove-button"
				size="small"
				onClick={() => onRemove?.(user)}
				sx={{
					position: "absolute",
					right: 8,
					top: 8,
					opacity: 100,
					transition: "opacity 0.5s",
					color: "error.main",
					"&:hover": {
						bgcolor: "error.light",
						color: "error.main",
					},
				}}
			>
				<PersonRemoveIcon fontSize="small" />
			</IconButton>
		)}
	</Box>
);

interface PeopleTabProps {
	instructors: User[];
	students: User[];
	isLoading?: boolean;
	canManage?: boolean;
	onAddInstructor?: (emails: string[]) => void;
	onAddStudent?: (emails: string[]) => void;
	onRemoveInstructor?: (user: User) => void;
	onRemoveStudent?: (user: User) => void;
}

const PeopleTab: React.FC<PeopleTabProps> = ({
	instructors,
	students,
	isLoading,
	canManage,
	onAddInstructor,
	onAddStudent,
	onRemoveInstructor,
	onRemoveStudent,
}) => {
	const [modalOpen, setModalOpen] = useState(false);
	const [modalType, setModalType] = useState<"student" | "instructor">(
		"student"
	);

	const handleOpenModal = (type: "student" | "instructor") => {
		setModalType(type);
		setModalOpen(true);
	};

	const renderLoadingSkeleton = () => (
		<Box>
			{/* Instructors Section */}
			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
					mb: 2,
				}}
			>
				<Skeleton
					variant="text"
					width={150}
					height={32}
					sx={{ bgcolor: "var(--color-card-hover)" }}
				/>
				<Skeleton
					variant="rectangular"
					width={150}
					height={36}
					sx={{
						bgcolor: "var(--color-card-hover)",
						borderRadius: 1,
					}}
				/>
			</Box>

			<Grid container spacing={2} sx={{ mb: 4 }}>
				{[1, 2, 3].map((item) => (
					<Grid item xs={12} sm={6} md={4} key={`instructor-${item}`}>
						<Card sx={{ bgcolor: "var(--color-card)" }}>
							<CardContent>
								<Box
									sx={{
										display: "flex",
										alignItems: "center",
										mb: 2,
									}}
								>
									<Skeleton
										variant="circular"
										width={40}
										height={40}
										sx={{
											bgcolor: "var(--color-card-hover)",
											mr: 2,
										}}
									/>
									<Box sx={{ flex: 1 }}>
										<Skeleton
											variant="text"
											width="80%"
											height={24}
											sx={{
												bgcolor: "var(--color-card-hover)",
												mb: 0.5,
											}}
										/>
										<Skeleton
											variant="text"
											width="60%"
											height={20}
											sx={{
												bgcolor: "var(--color-card-hover)",
											}}
										/>
									</Box>
								</Box>
								<Skeleton
									variant="text"
									width="40%"
									height={20}
									sx={{
										bgcolor: "var(--color-card-hover)",
										mb: 1,
									}}
								/>
								<Skeleton
									variant="text"
									width="30%"
									height={20}
									sx={{
										bgcolor: "var(--color-card-hover)",
									}}
								/>
							</CardContent>
						</Card>
					</Grid>
				))}
			</Grid>

			{/* Students Section */}
			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
					mb: 2,
				}}
			>
				<Skeleton
					variant="text"
					width={150}
					height={32}
					sx={{ bgcolor: "var(--color-card-hover)" }}
				/>
				<Skeleton
					variant="rectangular"
					width={150}
					height={36}
					sx={{
						bgcolor: "var(--color-card-hover)",
						borderRadius: 1,
					}}
				/>
			</Box>

			<Grid container spacing={2}>
				{[1, 2, 3, 4, 5, 6].map((item) => (
					<Grid item xs={12} sm={6} md={4} key={`student-${item}`}>
						<Card sx={{ bgcolor: "var(--color-card)" }}>
							<CardContent>
								<Box
									sx={{
										display: "flex",
										alignItems: "center",
										mb: 2,
									}}
								>
									<Skeleton
										variant="circular"
										width={40}
										height={40}
										sx={{
											bgcolor: "var(--color-card-hover)",
											mr: 2,
										}}
									/>
									<Box sx={{ flex: 1 }}>
										<Skeleton
											variant="text"
											width="80%"
											height={24}
											sx={{
												bgcolor: "var(--color-card-hover)",
												mb: 0.5,
											}}
										/>
										<Skeleton
											variant="text"
											width="60%"
											height={20}
											sx={{
												bgcolor: "var(--color-card-hover)",
											}}
										/>
									</Box>
								</Box>
								<Skeleton
									variant="text"
									width="40%"
									height={20}
									sx={{
										bgcolor: "var(--color-card-hover)",
										mb: 1,
									}}
								/>
								<Skeleton
									variant="text"
									width="30%"
									height={20}
									sx={{
										bgcolor: "var(--color-card-hover)",
									}}
								/>
							</CardContent>
						</Card>
					</Grid>
				))}
			</Grid>
		</Box>
	);

	if (isLoading) {
		return renderLoadingSkeleton();
	}

	return (
		<Box>
			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
					mb: 2,
				}}
			>
				<Typography variant="h6">
					Instructors ({instructors.length})
				</Typography>
				{canManage && (
					<Button
						variant="contained"
						size="small"
						startIcon={<PersonAddIcon />}
						onClick={() => handleOpenModal("instructor")}
						sx={{
							bgcolor: "var(--color-primary)",
							color: "var(--color-text-button)",
						}}
					>
						Add Instructor
					</Button>
				)}
			</Box>
			<Grid container spacing={2} sx={{ mb: 4 }}>
				{instructors.map((instructor) => (
					<Grid item xs={12} sm={6} md={4} key={instructor.id}>
						<UserCard
							user={instructor}
							canRemove={canManage}
							onRemove={onRemoveInstructor}
						/>
					</Grid>
				))}
			</Grid>

			<Divider sx={{ my: 4 }} />

			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
					mb: 2,
				}}
			>
				<Typography variant="h6">
					Students ({students.length})
				</Typography>
				{canManage && (
					<Button
						variant="contained"
						size="small"
						startIcon={<SchoolIcon />}
						onClick={() => handleOpenModal("student")}
						sx={{
							bgcolor: "var(--color-primary)",
							color: "var(--color-text-button)",
						}}
					>
						Add Student
					</Button>
				)}
			</Box>
			<Grid container spacing={2}>
				{students.map((student) => (
					<Grid item xs={12} sm={6} md={4} key={student.id}>
						<UserCard
							user={student}
							canRemove={canManage}
							onRemove={onRemoveStudent}
						/>
					</Grid>
				))}
			</Grid>

			<AddPeopleModal
				open={modalOpen}
				onClose={() => setModalOpen(false)}
				onSubmit={
					modalType === "student"
						? onAddStudent || (() => {})
						: onAddInstructor || (() => {})
				}
				type={modalType}
			/>
		</Box>
	);
};

export default PeopleTab;
