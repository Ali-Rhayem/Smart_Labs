import React from "react";
import {
	Box,
	Typography,
	Grid,
	Avatar,
	Divider,
	CircularProgress,
	IconButton,
} from "@mui/material";
import { User } from "../types/user";
import { imageUrl } from "../config/config";
import PersonRemoveIcon from "@mui/icons-material/PersonRemove";

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
	onRemoveInstructor?: (user: User) => void;
	onRemoveStudent?: (user: User) => void;
}

const PeopleTab: React.FC<PeopleTabProps> = ({
	instructors,
	students,
	isLoading,
	canManage,
	onRemoveInstructor,
	onRemoveStudent,
}) => {
	if (isLoading) {
		return <CircularProgress />;
	}

	return (
		<Box>
			<Typography variant="h6" sx={{ mb: 2 }}>
				Instructors ({instructors.length})
			</Typography>
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

			<Typography variant="h6" sx={{ mb: 2 }}>
				Students ({students.length})
			</Typography>
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
		</Box>
	);
};

export default PeopleTab;
