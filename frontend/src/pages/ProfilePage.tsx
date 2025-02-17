import React, { useState, useEffect } from "react";
import {
	Box,
	Card,
	Avatar,
	Typography,
	Button,
	Grid,
	CircularProgress,
	IconButton,
	AlertColor,
} from "@mui/material";
import { useUser } from "../contexts/UserContext";
import { UpdateUserDto } from "../types/user";
import { imageUrl } from "../config/config";
import EditIcon from "@mui/icons-material/Edit";
import CameraAltIcon from "@mui/icons-material/CameraAlt";
import { useNavigate } from "react-router-dom";
import { useUserDetails } from "../hooks/useUser";
import InputField from "../components/InputField";
import { useFaculties } from "../hooks/useFaculty";
import Dropdown from "../components/Dropdown";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { userService } from "../services/userService";
import ErrorAlert from "../components/ErrorAlertProps";
import ChangePasswordModal from "../components/ChangePasswordModal";
import LockIcon from "@mui/icons-material/Lock";

const ProfilePage: React.FC = () => {
	const navigate = useNavigate();
	const { user: authUser } = useUser();
	const {
		data: userDetails,
		isLoading,
		error,
	} = useUserDetails(authUser?.id ?? 0);
	const [isEditing, setIsEditing] = useState(false);
	const [formData, setFormData] = useState<UpdateUserDto>({});
	const { data: faculties = [] } = useFaculties();
	const [selectedFaculty, setSelectedFaculty] = useState("");
	const getMajorsForFaculty = (facultyName: string) => {
		const faculty = faculties.find((f) => f.faculty === facultyName);
		return faculty?.major || [];
	};

	const queryClient = useQueryClient();
	const [severity, setSeverity] = useState<AlertColor>("success");
	const [openSnackbar, setOpenSnackbar] = useState(false);
	const [alertMessage, setAlertMessage] = useState("");
	const [changePasswordOpen, setChangePasswordOpen] = useState(false);

	// Convert file to base64
	const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		const file = e.target.files?.[0];
		if (file) {
			const reader = new FileReader();
			reader.readAsDataURL(file);
			reader.onload = () => {
				if (reader.result) {
					setFormData({
						...formData,
						image: reader.result.toString(),
					});
				}
			};
		}
	};

	const updateUserMutation = useMutation({
		mutationFn: (data: UpdateUserDto) =>
			userService.editUser(authUser!.id, data),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["User", authUser!.id] });
			setIsEditing(false);
			setFormData({});
			setSeverity("success");
			setAlertMessage("Profile updated successfully");
			setOpenSnackbar(true);
		},
		onError: (error: any) => {
			setSeverity("error");
			setAlertMessage(error.message || "Failed to update profile");
			setOpenSnackbar(true);
		},
	});

	const changePasswordMutation = useMutation({
		mutationFn: ({
			oldPassword,
			newPassword,
			confirmPassword,
		}: {
			oldPassword: string;
			newPassword: string;
			confirmPassword: string;
		}) =>
			userService.changePassword(
				oldPassword,
				newPassword,
				confirmPassword
			),
		onSuccess: () => {
			setChangePasswordOpen(false);
			setSeverity("success");
			setAlertMessage("Password changed successfully");
			setOpenSnackbar(true);
		},
		onError: (error: any) => {
			console.error(error);
			let message = "Failed to change password";
			if (error.response?.data?.errors)
				message = error.response.data.errors;
			setSeverity("error");
			setAlertMessage(message);
			setChangePasswordOpen(false);
			setOpenSnackbar(true);
		},
	});

	const handleSubmit = () => {
		if (
			!formData.name &&
			!formData.email &&
			!formData.faculty &&
			!formData.major &&
			!formData.image
		) {
			setSeverity("error");
			setAlertMessage("No changes to save");
			setOpenSnackbar(true);
			return;
		}
		if (!formData.name) formData.name = userDetails?.name;
		if (!formData.email) formData.email = userDetails?.email;
		updateUserMutation.mutate(formData);
	};

	useEffect(() => {
		if (!authUser) {
			navigate("/login");
		}
	}, [authUser, navigate]);

	if (!authUser) {
		return null;
	}

	if (isLoading) {
		return (
			<Box
				sx={{
					display: "flex",
					justifyContent: "center",
					alignItems: "center",
					minHeight: "100vh",
				}}
			>
				<CircularProgress />
			</Box>
		);
	}

	if (error || !userDetails) {
		return (
			<Box
				sx={{
					display: "flex",
					flexDirection: "column",
					alignItems: "center",
					justifyContent: "center",
					minHeight: "100vh",
					gap: 2,
				}}
			>
				<Typography variant="h5" color="error">
					Unable to load profile
				</Typography>
				<Button variant="contained" onClick={() => navigate("/")}>
					Go Home
				</Button>
			</Box>
		);
	}

	return (
		<Box sx={{ p: 3, maxWidth: 800, mx: "auto" }}>
			<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
				{/* Profile Header */}
				<Box sx={{ display: "flex", alignItems: "center", mb: 4 }}>
					<Box sx={{ position: "relative" }}>
						<Avatar
							src={
								formData.image
									? formData.image
									: userDetails.image
									? `${imageUrl}/${userDetails.image}`
									: undefined
							}
							alt={userDetails.name}
							sx={{ width: 120, height: 120 }}
						/>
						{isEditing && (
							<IconButton
								sx={{
									position: "absolute",
									bottom: 0,
									right: 0,
									bgcolor: "var(--color-primary)",
									"&:hover": {
										bgcolor: "var(--color-primary)",
									},
								}}
								component="label"
							>
								<CameraAltIcon />
								<input
									type="file"
									accept="image/*"
									hidden
									onChange={handleFileChange}
								/>
							</IconButton>
						)}
					</Box>

					<Box sx={{ ml: 3, flex: 1 }}>
						<Box
							sx={{
								display: "flex",
								justifyContent: "space-between",
							}}
						>
							<Typography
								variant="h4"
								sx={{ color: "var(--color-text)" }}
							>
								{userDetails.name}
							</Typography>
							{!isEditing && (
								<Box sx={{ display: "flex" }}>
									<Button
										startIcon={<EditIcon />}
										sx={{ color: "var(--color-primary)" }}
										onClick={() => {
											setIsEditing(!isEditing);
											setSelectedFaculty(
												userDetails.faculty || ""
											);
										}}
									>
										Edit Profile
									</Button>
									<Button
										startIcon={<LockIcon />}
										sx={{
											color: "var(--color-primary)",
											ml: 2,
										}}
										onClick={() =>
											setChangePasswordOpen(true)
										}
									>
										Change Password
									</Button>
								</Box>
							)}
						</Box>
					</Box>
				</Box>

				{/* Profile Details */}
				<Grid container spacing={3}>
					<Grid item xs={12} sm={6}>
						<InputField
							id="name"
							label="Name"
							name="name"
							type="text"
							value={
								isEditing
									? formData.name || userDetails?.name
									: userDetails?.name || ""
							}
							placeholder="Enter your name"
							onChange={(e) =>
								setFormData({
									...formData,
									name: e.target.value,
								})
							}
							disabled={!isEditing}
							error={null}
						/>
					</Grid>
					<Grid item xs={12} sm={6}>
						<InputField
							id="email"
							label="Email"
							name="email"
							type="email"
							value={
								isEditing
									? formData.email || userDetails?.email
									: userDetails?.email || ""
							}
							placeholder="Enter your email"
							onChange={(e) =>
								setFormData({
									...formData,
									email: e.target.value,
								})
							}
							disabled={!isEditing}
							error={null}
						/>
					</Grid>
					{["student", "instructor"].includes(authUser.role) && (
						<>
							<Grid item xs={12} sm={6}>
								<Dropdown
									label="Faculty"
									value={
										isEditing
											? formData.faculty ||
											  userDetails?.faculty ||
											  ""
											: userDetails?.faculty || ""
									}
									options={
										faculties.map((f) => ({
											value: f.faculty,
											label: f.faculty,
										})) || []
									}
									onChange={(value) => {
										setFormData({
											...formData,
											faculty: value,
											major: "", // Reset major when faculty changes
										});
										setSelectedFaculty(value);
									}}
									disabled={!isEditing}
								/>
							</Grid>
							<Grid item xs={12} sm={6}>
								<Dropdown
									label="Major"
									value={
										isEditing
											? formData.major ||
											  userDetails.major ||
											  ""
											: userDetails.major || ""
									}
									options={getMajorsForFaculty(
										selectedFaculty ||
											userDetails?.faculty ||
											""
									).map((m) => ({
										value: m,
										label: m,
									}))}
									onChange={(value) =>
										setFormData({
											...formData,
											major: value,
										})
									}
									disabled={!isEditing || !selectedFaculty}
								/>
							</Grid>
						</>
					)}
				</Grid>

				{isEditing && (
					<Box
						sx={{
							mt: 3,
							display: "flex",
							justifyContent: "flex-end",
							gap: 2,
						}}
					>
						<Button
							variant="outlined"
							sx={{
								color: "var(--color-danger)",
								borderColor: "var(--color-danger)",
							}}
							onClick={() => {
								setIsEditing(false);
								setFormData({});
								setIsEditing(false);
								setFormData({});
							}}
							disabled={updateUserMutation.isPending}
						>
							Cancel
						</Button>
						<Button
							variant="contained"
							sx={{
								bgcolor: "var(--color-primary)",
								color: "var(--color-text-button)",
								"&:hover": {
									bgcolor: "var(--color-primary)",
								},
							}}
							onClick={handleSubmit}
							disabled={updateUserMutation.isPending}
						>
							{updateUserMutation.isPending ? (
								<CircularProgress size={24} color="inherit" />
							) : (
								"Save Changes"
							)}
						</Button>
					</Box>
				)}
			</Card>

			<ErrorAlert
				open={openSnackbar}
				message={alertMessage}
				severity={severity}
				onClose={() => setOpenSnackbar(false)}
			/>

			<ChangePasswordModal
				open={changePasswordOpen}
				onClose={() => setChangePasswordOpen(false)}
				onSubmit={(oldPassword, newPassword, confirmPassword) => {
					changePasswordMutation.mutate({
						oldPassword,
						newPassword,
						confirmPassword,
					});
				}}
				loading={changePasswordMutation.isPending}
			/>
		</Box>
	);
};

export default ProfilePage;
