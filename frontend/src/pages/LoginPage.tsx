import React, { useState } from "react";
import { Button, Typography, Link } from "@mui/material";
import Logo from "../components/Logo";
import InputField from "../components/InputField";
import Card from "../components/Card";
import { useNavigate } from "react-router-dom";

const LoginPage: React.FC = () => {
	const [email, setEmail] = useState("");
	const [password, setPassword] = useState("");
	const navigate = useNavigate();

	const [errors, setErrors] = useState<{
		email?: string;
		password?: string[];
	}>({
		password: [],
	});

	// Handle form submission
	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		// Reset errors
		setErrors({ email: undefined, password: [] });

		// Validation
		let valid = true;
		const newErrors: { email?: string; password?: string[] } = {
			password: [],
		};

		// Email validation
		if (!email) {
			newErrors.email = "Email is required";
			valid = false;
		} else if (!/\S+@\S+\.\S+/.test(email)) {
			newErrors.email = "Please enter a valid email address";
			valid = false;
		}

		// Password validation
		if (!password) {
			newErrors.password?.push("Password is required");
			valid = false;
		} else {
			// Check password strength requirements
			if (password.length < 8) {
				newErrors.password?.push(
					"Password must be at least 8 characters long"
				);
			}
			if (!/[A-Z]/.test(password)) {
				newErrors.password?.push(
					"Password must contain at least one uppercase letter"
				);
			}
			if (!/[a-z]/.test(password)) {
				newErrors.password?.push(
					"Password must contain at least one lowercase letter"
				);
			}
			if (!/\d/.test(password)) {
				newErrors.password?.push(
					"Password must contain at least one number"
				);
			}
			if (!/[!@#$%^&*()_+={}|:;'<>,.?/-]/.test(password)) {
				newErrors.password?.push(
					"Password must contain at least one special character"
				);
			}
		}

		if (newErrors.password?.length || newErrors.email) {
			setErrors(newErrors);
			valid = false;
		}

		if (valid) {
			navigate("/labs");
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
						label="Email Address"
						placeholder="Enter your email"
						type="email"
						value={email}
						onChange={(e) => setEmail(e.target.value)}
					/>
					{errors.email && (
						<p className="text-red-500 text-xs mt-1">
							{errors.email}
						</p>
					)}
					<InputField
						id="password"
						label="Password"
						placeholder="Enter your password"
						type="password"
						value={password}
						onChange={(e) => setPassword(e.target.value)}
					/>
					{errors.password && errors.password.length > 0 && (
						<ul className="text-red-500 text-xs mt-1">
							{errors.password.map((error, index) => (
								<li key={index}>{error}</li>
							))}
						</ul>
					)}

					<div className="flex justify-between items-center">
						<Link href="#" className="text-sm text-primary">
							Forgot Password?
						</Link>
					</div>

					<Button
						type="submit"
						variant="contained"
						fullWidth
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
		</div>
	);
};

export default LoginPage;
