import { useState } from "react";
import {
	BrowserRouter as Router,
	Route,
	Routes,
	Navigate,
} from "react-router-dom";
import LoginPage from "./Pages/LoginPage";
import LabsPage from "./Pages/LabsPage";
import DashboardPage from "./Pages/DashboardPage";
import MessagesPage from "./Pages/MessagesPage";
import ProfilePage from "./Pages/ProfilePage";
import Sidebar from "./components/Sidebar";

function App() {
	const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);

	// Simulate login success
	const handleLoginSuccess = () => {
		setIsAuthenticated(true);
	};

	// Define a protected route component
	const ProtectedRoute = ({ children }: { children: JSX.Element }) => {
		return isAuthenticated ? children : <Navigate to="/" />;
	};

	return (
		<Router>
			<div style={{ display: "flex" }}>
				{/* Sidebar */}
				{isAuthenticated && <Sidebar />}

				{/* Main content area */}
				<div style={{ flex: 1 }}>
					<Routes>
						{/* Public Route: Login Page */}
						<Route
							path="/"
							element={
								<LoginPage
									onLoginSuccess={handleLoginSuccess}
								/>
							}
						/>

						{/* Protected Routes */}
						<Route
							path="/labs"
							element={
								<ProtectedRoute>
									<LabsPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/dashboard"
							element={
								<ProtectedRoute>
									<DashboardPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/messages"
							element={
								<ProtectedRoute>
									<MessagesPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/profile"
							element={
								<ProtectedRoute>
									<ProfilePage />
								</ProtectedRoute>
							}
						/>
					</Routes>
				</div>
			</div>
		</Router>
	);
}

export default App;
