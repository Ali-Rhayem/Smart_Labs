import React, { useState } from "react";
import { Button, Typography, Link } from "@mui/material";
import Logo from "../components/Logo";
import InputField from "../components/InputField";
import Card from "../components/Card";
import { useNavigate } from "react-router-dom";
import ErrorAlert from "../components/ErrorAlertProps";
import { useUser } from "../contexts/UserContext";
import { authService } from "../services/authService";
import type { LoginData } from "../types/auth";
import AddItemModal from "../components/AddItemModal";
import { userService } from "../services/userService";

interface error {
	email: string[];
	password: string[];
}

const LoginPage: React.FC = () => {
	const [openSnackbar, setOpenSnackbar] = useState(false);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("error");
	const [errors, setErrors] = useState<error>({ email: [], password: [] });
	const [formData, setFormData] = useState<LoginData>({
		email: "",
		password: "",
		fcm_token: null,
	});
	const navigate = useNavigate();
	const { login: userLogin } = useUser();
	const [isLoading, setIsLoading] = useState(false);
	const [forgotPasswordOpen, setForgotPasswordOpen] = useState(false);

	const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		const { name, value } = e.target;
		setFormData((prev) => ({
			...prev,
			[name]: value,
		}));
	};

	const handleLogin = async (data: LoginData) => {
		setIsLoading(true);
		try {
			const response = await authService.login(data);
			userLogin({
				id: response.userId,
				role: response.role,
				token: response.token,
			});
			navigate("/labs");
		} catch (err: any) {
			const messages = err.response?.data?.errors;
			if (messages) {
				setAlertMessage(messages);
			} else {
				setAlertMessage("An error occurred. Please try again.");
			}
			setSeverity("error");
			setOpenSnackbar(true);
		} finally {
			setIsLoading(false);
		}
	};

	const handleForgotPassword = async (email: string) => {
		try {
			await userService.resetPassword(email);
			setAlertMessage("Password reset instructions sent to your email");
			setSeverity("success");
			setOpenSnackbar(true);
		} catch (err: any) {
			let message = "Failed to reset password";
			if (err.response?.data?.message)
				message = err.response.data.message;
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		setErrors({ email: [], password: [] });

		let valid = true;
		const newErrors: error = { email: [], password: [] };

		if (!formData.email) {
			newErrors.email.push("Email is required");
		} else if (!/\S+@\S+\.\S+/.test(formData.email)) {
			newErrors.email.push("Please enter a valid email address");
		}

		if (!formData.password) {
			newErrors.password.push("Password is required");
		}

		if (newErrors.password.length || newErrors.email.length) {
			setErrors(newErrors);
			valid = false;
		}

		if (valid) {
			handleLogin(formData);
		}
	};

	return (
		<div
			className={`min-h-screen flex items-center justify-center px-4`}
			style={{
				backgroundColor: "var(--color-background)",
				color: "var(--color-text)",
			}}
		>
			<Card>
				<div className="flex justify-center mb-8">
					<Logo />
				</div>

				<Typography
					variant="h4"
					align="center"
					className="font-bold mb-4"
					style={{ color: "var(--color-text)" }}
				>
					Welcome Back!
				</Typography>
				<Typography
					variant="body2"
					align="center"
					className="mb-8"
					style={{ color: "var(--color-text)" }}
				>
					Please sign in to your account
				</Typography>

				{/* Form */}
				<form onSubmit={handleSubmit} className="space-y-6">
					<InputField
						id="email"
						name="email"
						label="Email Address"
						placeholder="Enter your email"
						type="email"
						value={formData.email}
						error={errors.email}
						disabled={isLoading}
						onChange={handleInputChange}
					/>
					<InputField
						id="password"
						name="password"
						label="Password"
						placeholder="Enter your password"
						type="password"
						value={formData.password}
						error={errors.password}
						disabled={isLoading}
						onChange={handleInputChange}
					/>

					<div className="flex justify-between items-center">
						<Link
							onClick={() => setForgotPasswordOpen(true)}
							sx={{
								color: "var(--color-primary)",
								textDecoration: "none",
								"&:hover": {
									textDecoration: "underline",
									cursor: "pointer",
								},
							}}
						>
							Forgot Password?
						</Link>
					</div>

					<Button
						type="submit"
						variant="contained"
						fullWidth
						disabled={isLoading}
						className="mt-4 py-3 rounded-lg text-lg font-medium shadow-lg transition-transform hover:scale-105"
						style={{
							backgroundColor: "var(--color-primary)",
							color: "var(--color-secondary)",
						}}
					>
						Sign In
					</Button>
				</form>
			</Card>
			<ErrorAlert
				open={openSnackbar}
				message={alertMessage}
				severity={severity}
				onClose={() => setOpenSnackbar(false)}
			/>
			<AddItemModal
				open={forgotPasswordOpen}
				onClose={() => setForgotPasswordOpen(false)}
				onSubmit={handleForgotPassword}
				title="Reset Password"
				itemLabel="Email"
				placeholder="Enter your email address"
				submitLabel="Reset Password"
			/>
		</div>
	);
};

export default LoginPage;
