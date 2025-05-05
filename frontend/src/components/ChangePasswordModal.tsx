import React, { useState } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
	Box,
	TextField,
} from "@mui/material";
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { IconButton, InputAdornment } from '@mui/material';

interface ChangePasswordModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (
		oldPassword: string,
		newPassword: string,
		confirmPassword: string
	) => void;
	loading?: boolean;
}

const ChangePasswordModal: React.FC<ChangePasswordModalProps> = ({
	open,
	onClose,
	onSubmit,
	loading,
}) => {
	const [passwords, setPasswords] = useState({
		oldPassword: "",
		newPassword: "",
		confirmPassword: "",
	});
	const [errors, setErrors] = useState<Record<string, string>>({});
	const [showPasswords, setShowPasswords] = useState({
		oldPassword: false,
		newPassword: false,
		confirmPassword: false
	});

	const validateForm = () => {
		const newErrors: Record<string, string> = {};
		if (!passwords.oldPassword)
			newErrors.oldPassword = "Current password is required";
		if (!passwords.newPassword)
			newErrors.newPassword = "New password is required";
		if (!passwords.confirmPassword)
			newErrors.confirmPassword = "Confirm password is required";
		if (passwords.newPassword !== passwords.confirmPassword) {
			newErrors.confirmPassword = "Passwords do not match";
		}
		if (passwords.newPassword && passwords.newPassword.length < 6) {
			newErrors.newPassword = "Password must be at least 6 characters";
		}
		return newErrors;
	};

	const resetForm = () => {
		setPasswords({
			oldPassword: "",
			newPassword: "",
			confirmPassword: "",
		});
		setErrors({});
	};

	const handleSubmit = () => {
		const newErrors = validateForm();
		if (Object.keys(newErrors).length > 0) {
			setErrors(newErrors);
			return;
		}
		onSubmit(
			passwords.oldPassword,
			passwords.newPassword,
			passwords.confirmPassword
		);
		resetForm();
	};

	const handleClose = () => {
		resetForm();
		onClose();
	};

	return (
		<Dialog
			open={open}
			onClose={handleClose}
			PaperProps={{
				sx: {
					bgcolor: "var(--color-background)",
					color: "var(--color-text)",
					minWidth: "400px",
				},
			}}
		>
			<DialogTitle>Change Password</DialogTitle>
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
						type={showPasswords.oldPassword ? "text" : "password"}
						label="Current Password"
						autoComplete="old-password"
						name="old-password"
						value={passwords.oldPassword}
						onChange={(e) =>
							setPasswords({
								...passwords,
								oldPassword: e.target.value,
							})
						}
						error={!!errors.oldPassword}
						helperText={errors.oldPassword}
						InputProps={{
							endAdornment: (
								<InputAdornment position="end">
									<IconButton
										onClick={() => setShowPasswords({
											...showPasswords,
											oldPassword: !showPasswords.oldPassword
										})}
										sx={{ color: "var(--color-text)" }}
									>
										{showPasswords.oldPassword ? <VisibilityOff /> : <Visibility />}
									</IconButton>
								</InputAdornment>
							),
						}}
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
						type={showPasswords.newPassword ? "text" : "password"}
						label="New Password"
						value={passwords.newPassword}
						onChange={(e) =>
							setPasswords({
								...passwords,
								newPassword: e.target.value,
							})
						}
						error={!!errors.newPassword}
						helperText={errors.newPassword}
						autoComplete="new-password"
						InputProps={{
							endAdornment: (
								<InputAdornment position="end">
									<IconButton
										onClick={() => setShowPasswords({
											...showPasswords,
											newPassword: !showPasswords.newPassword
										})}
										sx={{ color: "var(--color-text)" }}
									>
										{showPasswords.newPassword ? <VisibilityOff /> : <Visibility />}
									</IconButton>
								</InputAdornment>
							),
						}}
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
						type={showPasswords.confirmPassword ? "text" : "password"}
						label="Confirm New Password"
						value={passwords.confirmPassword}
						onChange={(e) =>
							setPasswords({
								...passwords,
								confirmPassword: e.target.value,
							})
						}
						error={!!errors.confirmPassword}
						helperText={errors.confirmPassword}
						autoComplete="new-password"
						InputProps={{
							endAdornment: (
								<InputAdornment position="end">
									<IconButton
										onClick={() => setShowPasswords({
											...showPasswords,
											confirmPassword: !showPasswords.confirmPassword
										})}
										sx={{ color: "var(--color-text)" }}
									>
										{showPasswords.confirmPassword ? <VisibilityOff /> : <Visibility />}
									</IconButton>
								</InputAdornment>
							),
						}}
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
				</Box>
			</DialogContent>
			<DialogActions>
				<Button onClick={handleClose} sx={{ color: "var(--color-text)" }}>
					Cancel
				</Button>
				<Button
					onClick={handleSubmit}
					disabled={loading}
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-primary) r g b / 0.8)",
						},
					}}
				>
					Change Password
				</Button>
			</DialogActions>
		</Dialog>
	);
};

export default ChangePasswordModal;
