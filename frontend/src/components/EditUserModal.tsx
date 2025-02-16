import React, { useState, useEffect } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
	TextField,
	Select,
	MenuItem,
	FormControl,
	InputLabel,
	Box,
} from "@mui/material";
import { User } from "../types/user";

interface EditUserModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (data: {
		name: string;
		email: string;
		faculty: string;
		major: string;
	}) => void;
	user: User | null;
	faculties: { faculty: string; majors: string[] }[];
}

const EditUserModal: React.FC<EditUserModalProps> = ({
	open,
	onClose,
	onSubmit,
	user,
	faculties,
}) => {
	const [formData, setFormData] = useState({
		name: "",
		email: "",
		faculty: "",
		major: "",
	});
	const [errors, setErrors] = useState<Record<string, string>>({});

	useEffect(() => {
		if (user) {
			setFormData({
				name: user.name,
				email: user.email,
				faculty: user.faculty || "",
				major: user.major || "",
			});
		}
	}, [user]);

	const validateEmail = (email: string): boolean => {
		const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
		return emailRegex.test(email);
	};

	const handleSubmit = () => {
		const newErrors: Record<string, string> = {};
		if (!formData.name) newErrors.name = "Name is required";
		if (!formData.email) newErrors.email = "Email is required";
		else if (!validateEmail(formData.email))
			newErrors.email = "Please enter a valid email address";

		if (Object.keys(newErrors).length > 0) {
			setErrors(newErrors);
			return;
		}

		onSubmit(formData);
	};

	const selectedFacultyMajors =
		faculties.find((f) => f.faculty === formData.faculty)?.majors || [];

	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{
				sx: {
					bgcolor: "var(--color-background)",
					color: "var(--color-text)",
					minWidth: "400px",
				},
			}}
		>
			<DialogTitle>Edit User</DialogTitle>
			<DialogContent>
				<Box
					sx={{
						display: "flex",
						flexDirection: "column",
						gap: 2,
						mt: 2,
					}}
				>
					<TextField
						label="Name"
						value={formData.name}
						onChange={(e) =>
							setFormData({ ...formData, name: e.target.value })
						}
						error={!!errors.name}
						helperText={errors.name}
						autoComplete="off"
						sx={{
							"& .MuiOutlinedInput-root": {
								backgroundColor: "var(--color-card)",
								color: "var(--color-text)",
								"& fieldset": {
									borderColor: "var(--color-text-secondary)",
								},
								"&:hover fieldset": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused fieldset": {
									borderColor: "var(--color-primary)",
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
					<TextField
						label="Email"
						type="email"
						value={formData.email}
						onChange={(e) =>
							setFormData({ ...formData, email: e.target.value })
						}
						error={!!errors.email}
						helperText={errors.email}
						autoComplete="off"
						sx={{
							"& .MuiOutlinedInput-root": {
								backgroundColor: "var(--color-card)",
								color: "var(--color-text)",
								"& fieldset": {
									borderColor: "var(--color-text-secondary)",
								},
								"&:hover fieldset": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused fieldset": {
									borderColor: "var(--color-primary)",
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
					<FormControl error={!!errors.faculty}>
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
							value={formData.faculty}
							onChange={(e) =>
								setFormData({
									...formData,
									faculty: e.target.value,
									major: "",
								})
							}
							label="Faculty"
							sx={{
								backgroundColor: "var(--color-card)",
								color: "var(--color-text)",
								"& .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-text-secondary)",
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
										},
									},
								},
							}}
						>
							{faculties.map((f) => (
								<MenuItem key={f.faculty} value={f.faculty}>
									{f.faculty}
								</MenuItem>
							))}
						</Select>
					</FormControl>
					<FormControl
						error={!!errors.major}
						disabled={!formData.faculty}
					>
						<InputLabel
							sx={{
								color: "var(--color-text)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
								transition: "color 0.2s ease-in-out",
							}}
						>
							Major
						</InputLabel>
						<Select
							value={formData.major}
							onChange={(e) =>
								setFormData({
									...formData,
									major: e.target.value,
								})
							}
							label="Major"
							sx={{
								backgroundColor: "var(--color-card)",
								color: "var(--color-text)",
								"& .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-text-secondary)",
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
										},
									},
								},
							}}
						>
							{selectedFacultyMajors.map((major) => (
								<MenuItem key={major} value={major}>
									{major}
								</MenuItem>
							))}
						</Select>
					</FormControl>
				</Box>
			</DialogContent>
			<DialogActions>
				<Button onClick={onClose} sx={{ color: "var(--color-text)" }}>
					Cancel
				</Button>
				<Button
					onClick={handleSubmit}
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-primary) r g b / 0.8)",
						},
					}}
				>
					Update
				</Button>
			</DialogActions>
		</Dialog>
	);
};

export default EditUserModal;
