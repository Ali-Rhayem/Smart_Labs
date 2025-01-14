import "../index.css";
import Input from "../components/Input";
import Button from "../components/Button";
import LoginHeader from "../components/LoginHeader";
import Card from "../components/Card";

const LoginPage = () => {
	return (
		<div className="flex items-center justify-center min-h-screen bg-gray-900">
			<Card>
				<LoginHeader />
				<form>
					<Input
						id="email"
						type="text"
						placeholder="Enter your email"
						label="Email"
					/>
					<Input
						id="password"
						type="password"
						placeholder="Enter your password"
						label="Password"
					/>
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
