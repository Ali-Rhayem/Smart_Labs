import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import LabsPage from "./pages/LabsPage";
import { Role } from "./config/routes";
import PublicLayout from "./layouts/PublicLayout";
import ProtectedLayout from "./layouts/ProtectedLayout";
import NotFoundPage from "./pages/NotFoundPage";
import { UserProvider } from "./contexts/UserContext";
import UnauthorizedPage from "./pages/UnauthorizedPage";
import ProtectedRoute from "./contexts/ProtectedRoute";

const currentUserRole: Role = "instructor";

const App: React.FC = () => {
	return (
		<UserProvider>
			<Router>
				<Routes>
					<Route element={<PublicLayout />}>
						<Route path="/" element={<LoginPage />} />
						<Route path="*" element={<NotFoundPage />} />
						<Route
							path="/unauthorized"
							element={<UnauthorizedPage />}
						/>
					</Route>

					<Route
						element={<ProtectedLayout userRole={currentUserRole} />}
					>
						{/* <Route path="/" element={<DashboardPage />} /> */}
						{/* <Route path="/dashboard" element={<DashboardPage />} /> */}
						<Route
							path="/labs"
							element={
								<ProtectedRoute
									requiredRoles={[
										"student",
										"instructor",
										"admin",
									]}
								>
									<LabsPage />
								</ProtectedRoute>
							}
						/>
					</Route>
				</Routes>
			</Router>
		</UserProvider>
	);
};

export default App;
