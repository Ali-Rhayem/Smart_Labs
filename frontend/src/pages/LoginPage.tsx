import React, { useState } from "react";
import { Button, Typography, Link } from "@mui/material";
import Logo from "../components/Logo";
import InputField from "../components/InputField";
import Card from "../components/Card";
import { useTheme } from "../themes/ThemeContext";

const LoginPage: React.FC = () => {
	const [email, setEmail] = useState("");
	const [password, setPassword] = useState("");
	const { themeMode } = useTheme();

	return (
		<div
			className={`min-h-screen flex items-center justify-center ${
				themeMode === "dark" ? "bg-gray-900" : "bg-gray-100"
			}`}
		>
			<Card>
				{/* Logo */}
				<div className="flex justify-center mb-8">
					<Logo />
				</div>

				{/* Welcome Message */}
				<Typography
					variant="h4"
					align="center"
					className="font-bold mb-4"
				>
					Welcome Back!
				</Typography>
				<Typography
					variant="body2"
					align="center"
					className={`mb-8 ${
						themeMode === "dark" ? "text-gray-400" : "text-gray-600"
					}`}
				>
					Please sign in to your account
				</Typography>

				{/* Form */}
				<form className="space-y-6">
					<InputField
						id="email"
						label="Email Address"
						placeholder="Enter your email"
						type="email"
						value={email}
						onChange={(e) => setEmail(e.target.value)}
					/>
					<InputField
						id="password"
						label="Password"
						placeholder="Enter your password"
						type="password"
						value={password}
						onChange={(e) => setPassword(e.target.value)}
					/>

					{/* Forgot Password Link */}
					<div className="flex justify-between items-center">
						<Link
							href="#"
							className={`text-sm ${
								themeMode === "dark"
									? "text-blue-400"
									: "text-blue-600"
							}`}
						>
							Forgot Password?
						</Link>
					</div>

					{/* Sign In Button */}
					<Button
						type="submit"
						variant="contained"
						color="primary"
						fullWidth
						className="mt-4 py-3 rounded-lg text-lg font-medium shadow-lg transition-transform hover:scale-105"
					>
						Sign In
					</Button>
				</form>
			</Card>
		</div>
	);
};

export default LoginPage;
