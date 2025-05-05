import React, { useState } from "react";
import {
	Box,
	Button,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
	IconButton,
	Typography,
	Skeleton,
	Avatar,
	Chip,
	MenuItem,
	Select,
	FormControl,
	InputLabel,
} from "@mui/material";
import { useUsers } from "../hooks/useUser";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { userService } from "../services/userService";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import ErrorIcon from "@mui/icons-material/Error";
import SearchField from "../components/SearchField";
import TableSortLabel from "@mui/material/TableSortLabel";
import DeleteConfirmDialog from "../components/DeleteConfirmDialog";
import ErrorAlert from "../components/ErrorAlertProps";
import { User, Role, CreateUserDto } from "../types/user";
import { imageUrl } from "../config/config";
import AddUserModal from "../components/AddUserModal";
import { useFaculties } from "../hooks/useFaculty";
import EditUserModal from "../components/EditUserModal";
import LockResetIcon from "@mui/icons-material/LockReset";

type Order = "asc" | "desc";
type OrderBy = "name" | "email" | "faculty" | "major" | "role";

const UsersPage: React.FC = () => {
	const { data: users = [], isLoading, error } = useUsers();
	const { data: facultiesData = [] } = useFaculties();
	const [orderBy, setOrderBy] = useState<OrderBy>("name");
	const [order, setOrder] = useState<Order>("asc");
	const [searchQuery, setSearchQuery] = useState("");
	const [roleFilter, setRoleFilter] = useState<Role | "all">("all");
	const [facultyFilter, setFacultyFilter] = useState<string>("all");
	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [selectedUser, setSelectedUser] = useState<User | null>(null);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("success");
	const [showAlert, setShowAlert] = useState(false);
	const [openAddDialog, setOpenAddDialog] = useState(false);
	const [editingUser, setEditingUser] = useState<User | null>(null);
	const [resetPasswordUser, setResetPasswordUser] = useState<User | null>(
		null
	);

	const queryClient = useQueryClient();

	const handleRequestSort = (property: OrderBy) => {
		const isAsc = orderBy === property && order === "asc";
		setOrder(isAsc ? "desc" : "asc");
		setOrderBy(property);
	};

	const sortedUsers = React.useMemo(() => {
		const filtered = users.filter((user) => {
			const matchesSearch =
				user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
				user.email.toLowerCase().includes(searchQuery.toLowerCase());
			const matchesRole =
				roleFilter === "all" || user.role === roleFilter;
			const matchesFaculty =
				facultyFilter === "all" || user.faculty === facultyFilter;
			return matchesSearch && matchesRole && matchesFaculty;
		});

		return filtered.sort((a, b) => {
			const aValue = a[orderBy] || "";
			const bValue = b[orderBy] || "";
			return (order === "asc" ? 1 : -1) * aValue.localeCompare(bValue);
		});
	}, [users, order, orderBy, searchQuery, roleFilter, facultyFilter]);

	const facultiesWithMajors = React.useMemo(
		() =>
			facultiesData.map((faculty) => ({
				faculty: faculty.faculty,
				majors: faculty.major,
			})),
		[facultiesData]
	);

	const deleteUserMutation = useMutation({
		mutationFn: (id: number) => userService.deleteUser(id),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Users"] });
			setDeleteDialogOpen(false);
			setSelectedUser(null);
			setAlertMessage("User deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const createUserMutation = useMutation({
		mutationFn: (userData: CreateUserDto) =>
			userService.createUser(userData),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Users"] });
			setOpenAddDialog(false);
			setAlertMessage("User created successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to create user";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const editUserMutation = useMutation({
		mutationFn: (data: { id: number; userData: Partial<User> }) =>
			userService.editUser(data.id, data.userData),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Users"] });
			setEditingUser(null);
			setAlertMessage("User updated successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to update user";
			if (error.response?.data?.message)
				message = error.response.data.message;
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const resetPasswordMutation = useMutation({
		mutationFn: (email: string) => userService.resetPassword(email),
		onSuccess: () => {
			setResetPasswordUser(null);
			setAlertMessage("Password reset email sent successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to reset password";
			if (error.response?.data?.message)
				message = error.response.data.message;
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const renderLoadingSkeleton = () => (
		<Box sx={{ p: 3 }}>
			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
					mb: 3,
				}}
			>
				<Skeleton
					variant="text"
					width={200}
					height={40}
					sx={{ bgcolor: "var(--color-card-hover)" }}
				/>
				<Skeleton
					variant="rounded"
					width={300}
					height={40}
					sx={{ bgcolor: "var(--color-card-hover)" }}
				/>
			</Box>

			<Box sx={{ display: "flex", gap: 2, mb: 3 }}>
				<Skeleton
					variant="rounded"
					width={120}
					height={40}
					sx={{ bgcolor: "var(--color-card-hover)" }}
				/>
				<Skeleton
					variant="rounded"
					width={120}
					height={40}
					sx={{ bgcolor: "var(--color-card-hover)" }}
				/>
			</Box>

			<TableContainer
				component={Paper}
				sx={{ bgcolor: "var(--color-card)" }}
			>
				<Table>
					<TableHead>
						<TableRow>
							{[
								"User",
								"Email",
								"Faculty",
								"Major",
								"Role",
								"Actions",
							].map((header) => (
								<TableCell key={header}>
									<Skeleton
										variant="text"
										sx={{
											bgcolor: "var(--color-card-hover)",
										}}
									/>
								</TableCell>
							))}
						</TableRow>
					</TableHead>
					<TableBody>
						{[1, 2, 3, 4, 5].map((row) => (
							<TableRow key={row}>
								<TableCell>
									<Box
										sx={{
											display: "flex",
											alignItems: "center",
											gap: 2,
										}}
									>
										<Skeleton
											variant="circular"
											width={40}
											height={40}
											sx={{
												bgcolor:
													"var(--color-card-hover)",
											}}
										/>
										<Skeleton
											variant="text"
											width={120}
											sx={{
												bgcolor:
													"var(--color-card-hover)",
											}}
										/>
									</Box>
								</TableCell>
								<TableCell>
									<Skeleton
										variant="text"
										width={200}
										sx={{
											bgcolor: "var(--color-card-hover)",
										}}
									/>
								</TableCell>
								<TableCell>
									<Skeleton
										variant="text"
										width={100}
										sx={{
											bgcolor: "var(--color-card-hover)",
										}}
									/>
								</TableCell>
								<TableCell>
									<Skeleton
										variant="text"
										width={100}
										sx={{
											bgcolor: "var(--color-card-hover)",
										}}
									/>
								</TableCell>
								<TableCell>
									<Skeleton
										variant="rounded"
										width={80}
										height={24}
										sx={{
											bgcolor: "var(--color-card-hover)",
										}}
									/>
								</TableCell>
								<TableCell align="right">
									<Box
										sx={{
											display: "flex",
											justifyContent: "flex-end",
											gap: 1,
										}}
									>
										<Skeleton
											variant="circular"
											width={32}
											height={32}
											sx={{
												bgcolor:
													"var(--color-card-hover)",
											}}
										/>
									</Box>
								</TableCell>
							</TableRow>
						))}
					</TableBody>
				</Table>
			</TableContainer>
		</Box>
	);

	if (isLoading) return renderLoadingSkeleton();

	if (error) {
		return (
			<Box
				sx={{
					p: 3,
					display: "flex",
					flexDirection: "column",
					alignItems: "center",
					gap: 2,
				}}
			>
				<ErrorIcon
					sx={{ fontSize: 60, color: "var(--color-danger)" }}
				/>
				<Typography variant="h6" sx={{ color: "var(--color-text)" }}>
					Failed to load users
				</Typography>
				<Button
					onClick={() =>
						queryClient.invalidateQueries({ queryKey: ["Users"] })
					}
					sx={{ color: "var(--color-primary)" }}
				>
					Retry
				</Button>
			</Box>
		);
	}

	return (
		<Box sx={{ p: 3 }}>
			<Box
				sx={{
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
					mb: 3,
				}}
			>
				<Typography variant="h4" color="var(--color-text)">
					Users
				</Typography>
				<Box sx={{ display: "flex", gap: 2 }}>
					<Button
						variant="contained"
						startIcon={<AddIcon />}
						onClick={() => setOpenAddDialog(true)}
						sx={{
							bgcolor: "var(--color-primary)",
							color: "var(--color-text-button)",
						}}
					>
						Add User
					</Button>
				</Box>
			</Box>

			<Box
				sx={{
					display: "flex",
					gap: 2,
					mb: 3,
					alignItems: "center",
					justifyContent: "space-between",
				}}
			>
				<Box sx={{ display: "flex", gap: 2 }}>
					<FormControl size="small" sx={{ minWidth: 120 }}>
						<InputLabel
							sx={{
								color: "var(--color-text)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
								transition: "color 0.2s ease-in-out",
							}}
						>
							Role
						</InputLabel>
						<Select
							value={roleFilter}
							onChange={(e) =>
								setRoleFilter(e.target.value as Role | "all")
							}
							label="Role"
							sx={{
								color: "var(--color-text)",
								"& .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-border)",
								},
								"&:hover .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused .MuiOutlinedInput-notchedOutline":
									{
										borderColor: "var(--color-primary)",
									},
								"& .MuiSvgIcon-root": {
									color: "var(--color-text)",
								},
							}}
							MenuProps={{
								PaperProps: {
									sx: {
										bgcolor: "var(--color-card)",
										"& .MuiMenuItem-root": {
											color: "var(--color-text)",
											"&:hover": {
												bgcolor:
													"var(--color-card-hover)",
											},
											"&.Mui-selected": {
												bgcolor:
													"rgb(from var(--color-primary) r g b / 0.1)",
												"&:hover": {
													bgcolor:
														"rgb(from var(--color-primary) r g b / 0.2)",
												},
											},
										},
									},
								},
							}}
						>
							<MenuItem value="all">All Roles</MenuItem>
							<MenuItem value="student">Student</MenuItem>
							<MenuItem value="instructor">Instructor</MenuItem>
							<MenuItem value="admin">Admin</MenuItem>
						</Select>
					</FormControl>

					<FormControl size="small" sx={{ minWidth: 120 }}>
						<InputLabel
							sx={{
								color: "var(--color-text)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
								transition: "color 0.2s ease-in-out",
							}}
						>
							Faculty
						</InputLabel>
						<Select
							value={facultyFilter}
							onChange={(e) => setFacultyFilter(e.target.value)}
							label="Faculty"
							sx={{
								color: "var(--color-text)",
								"& .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-border)",
								},
								"&:hover .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused .MuiOutlinedInput-notchedOutline":
									{
										borderColor: "var(--color-primary)",
									},
								"& .MuiSvgIcon-root": {
									color: "var(--color-text)",
								},
							}}
							MenuProps={{
								PaperProps: {
									sx: {
										bgcolor: "var(--color-card)",
										"& .MuiMenuItem-root": {
											color: "var(--color-text)",
											"&:hover": {
												bgcolor:
													"var(--color-card-hover)",
											},
											"&.Mui-selected": {
												bgcolor:
													"rgb(from var(--color-primary) r g b / 0.1)",
												"&:hover": {
													bgcolor:
														"rgb(from var(--color-primary) r g b / 0.2)",
												},
											},
										},
									},
								},
							}}
						>
							<MenuItem value="all">All Faculties</MenuItem>
							{facultiesWithMajors.map((faculty) => (
								<MenuItem
									key={faculty.faculty}
									value={faculty.faculty}
								>
									{faculty.faculty}
								</MenuItem>
							))}
						</Select>
					</FormControl>
				</Box>
				<SearchField
					value={searchQuery}
					onChange={(e) => setSearchQuery(e.target.value)}
					placeholder="Search users..."
				/>
			</Box>

			<TableContainer
				component={Paper}
				sx={{ bgcolor: "var(--color-card)" }}
			>
				<Table>
					<TableHead>
						<TableRow>
							<TableCell
								sx={{
									color: "var(--color-text)",
									fontWeight: "bold",
								}}
							>
								User
							</TableCell>
							{["email", "faculty", "major", "role"].map(
								(column) => (
									<TableCell key={column}>
										<TableSortLabel
											active={orderBy === column}
											direction={
												orderBy === column
													? order
													: "asc"
											}
											onClick={() =>
												handleRequestSort(
													column as OrderBy
												)
											}
											sx={{
												color: "var(--color-text) !important",
												"& .MuiTableSortLabel-icon": {
													color: "var(--color-text-secondary) !important",
												},
											}}
										>
											{column.charAt(0).toUpperCase() +
												column.slice(1)}
										</TableSortLabel>
									</TableCell>
								)
							)}
							<TableCell
								align="right"
								sx={{
									color: "var(--color-text)",
									fontWeight: "bold",
								}}
							>
								Actions
							</TableCell>
						</TableRow>
					</TableHead>
					<TableBody>
						{sortedUsers.map((user) => (
							<TableRow
								key={user.id}
								sx={{
									"&:hover": {
										backgroundColor:
											"var(--color-card-hover)",
									},
								}}
							>
								<TableCell sx={{ color: "var(--color-text)" }}>
									<Box
										sx={{
											display: "flex",
											alignItems: "center",
											gap: 2,
										}}
									>
										<Avatar
											alt={user.name}
											src={`${imageUrl}/${user.image}`}
										/>
										{user.name}
									</Box>
								</TableCell>
								<TableCell sx={{ color: "var(--color-text)" }}>
									{user.email}
								</TableCell>
								<TableCell sx={{ color: "var(--color-text)" }}>
									{user.faculty || "-"}
								</TableCell>
								<TableCell sx={{ color: "var(--color-text)" }}>
									{user.major || "-"}
								</TableCell>
								<TableCell>
									<Chip
										label={user.role}
										sx={{
											bgcolor:
												user.role === "admin"
													? "var(--color-danger)"
													: user.role === "instructor"
													? "var(--color-primary)"
													: "var(--color-text-secondary)",
											color: "var(--color-text-button)",
										}}
									/>
								</TableCell>
								<TableCell align="right">
									<IconButton
										onClick={() => {
											setSelectedUser(user);
											setDeleteDialogOpen(true);
										}}
										sx={{ color: "var(--color-danger)" }}
									>
										<DeleteIcon />
									</IconButton>
									<IconButton
										onClick={() => setEditingUser(user)}
										sx={{
											color: "var(--color-primary)",
											"&:hover": {
												backgroundColor:
													"rgb(from var(--color-primary) r g b / 0.1)",
											},
										}}
									>
										<EditIcon />
									</IconButton>
									<IconButton
										onClick={() =>
											setResetPasswordUser(user)
										}
										sx={{
											color: "var(--color-text)",
											"&:hover": {
												color: "var(--color-primary)",
												bgcolor:
													"rgb(from var(--color-primary) r g b / 0.1)",
											},
										}}
									>
										<LockResetIcon />
									</IconButton>
								</TableCell>
							</TableRow>
						))}
					</TableBody>
				</Table>
			</TableContainer>

			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={() => {
					if (selectedUser) {
						deleteUserMutation.mutate(selectedUser.id);
					}
				}}
				title="Delete User"
				message={`Are you sure you want to delete ${selectedUser?.name}?`}
			/>

			<ErrorAlert
				open={showAlert}
				message={alertMessage}
				severity={severity}
				onClose={() => setShowAlert(false)}
			/>

			<AddUserModal
				open={openAddDialog}
				onClose={() => setOpenAddDialog(false)}
				onSubmit={(data) => createUserMutation.mutate(data)}
				faculties={facultiesWithMajors}
			/>

			<EditUserModal
				open={Boolean(editingUser)}
				onClose={() => setEditingUser(null)}
				onSubmit={(data) => {
					if (editingUser) {
						editUserMutation.mutate({
							id: editingUser.id,
							userData: data,
						});
					}
				}}
				user={editingUser}
				faculties={facultiesWithMajors}
			/>

			<DeleteConfirmDialog
				open={Boolean(resetPasswordUser)}
				onClose={() => setResetPasswordUser(null)}
				onConfirm={() => {
					if (resetPasswordUser) {
						resetPasswordMutation.mutate(resetPasswordUser.email);
					}
				}}
				title="Reset Password"
				message={`Are you sure you want to reset password for ${resetPasswordUser?.name}?`}
				submitLabel="Reset"
				submitColor="var(--color-primary)"
			/>
		</Box>
	);
};

export default UsersPage;
