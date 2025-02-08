import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import LabsPage from "./pages/LabsPage";
import { Role } from "./types/user";
import PublicLayout from "./layouts/PublicLayout";
import ProtectedLayout from "./layouts/ProtectedLayout";
import NotFoundPage from "./pages/NotFoundPage";
import { useUser } from "./contexts/UserContext";
import UnauthorizedPage from "./pages/UnauthorizedPage";
import ProtectedRoute from "./contexts/ProtectedRoute";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import LabPage from "./pages/LabPage";

const queryClient = new QueryClient();

const App: React.FC = () => {
	const { user } = useUser();
	const currentUserRole: Role = user?.role as Role;

	return (
		<QueryClientProvider client={queryClient}>
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
						<Route
							path="/labs/:id"
							element={
								<ProtectedRoute
									requiredRoles={[
										"student",
										"instructor",
										"admin",
									]}
								>
									<LabPage />
								</ProtectedRoute>
							}
						/>
					</Route>
				</Routes>
			</Router>
			<ReactQueryDevtools
				buttonPosition="bottom-left"
				initialIsOpen={false}
			/>
		</QueryClientProvider>
	);
};

export default App;
