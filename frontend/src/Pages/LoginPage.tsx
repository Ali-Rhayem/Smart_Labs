import "../index.css";
import Input from "../components/Input";
import Button from "../components/Button";
import LoginHeader from "../components/LoginHeader";
import Card from "../components/Card";
import { useState } from "react";

const LoginPage = () => {
	const [email, setEmail] = useState("");
	const [password, setPassword] = useState("");
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
			// If valid, proceed with the form submission (e.g., API call)
			console.log("Form submitted with:", { email, password });
		}
	};

	return (
		<div className="flex items-center justify-center min-h-screen bg-gray-900">
			<Card>
				<LoginHeader />
				<form onSubmit={handleSubmit}>
					<Input
						id="email"
						type="text"
						placeholder="Enter your email"
						label="Email"
						value={email}
						onChange={(e) => setEmail(e.target.value)}
					/>
					{errors.email && (
						<p className="text-red-500 text-xs mt-1">
							{errors.email}
						</p>
					)}

					<Input
						id="password"
						type="password"
						placeholder="Enter your password"
						label="Password"
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

					<div className="flex items-center justify-between mb-6">
						<a
							href="/forgot-password"
							className="text-sm text-blue-400 hover:underline"
						>
							Forgot password?
						</a>
					</div>

					<Button text="Login" type="submit" />
				</form>
			</Card>
		</div>
	);
};

export default LoginPage;
