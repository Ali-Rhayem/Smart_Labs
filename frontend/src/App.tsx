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
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import LabPage from "./pages/LabPage";
import SessionPage from "./pages/SessionPage";
import ProfilePage from "./pages/ProfilePage";
import NotificationsPage from "./pages/NotificationsPage";
import DashboardPage from "./pages/DashboardPage";
import FacultyPage from "./pages/FacultyPage";
import PPEPage from "./pages/PPEPage";
import SemesterPage from "./pages/SemesterPage";
import RoomPage from "./pages/RoomPage";
import UsersPage from "./pages/UsersPage";

const App: React.FC = () => {
	const { user } = useUser();
	const currentUserRole: Role = user?.role as Role;

	return (
		<>
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
						<Route
							path="/labs/sessions/:sessionId"
							element={
								<ProtectedRoute
									requiredRoles={[
										"student",
										"instructor",
										"admin",
									]}
								>
									<SessionPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/notifications"
							element={
								<ProtectedRoute
									requiredRoles={[
										"student",
										"instructor",
										"admin",
									]}
								>
									<NotificationsPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/dashboard"
							element={
								<ProtectedRoute
									requiredRoles={[
										"student",
										"instructor",
										"admin",
									]}
								>
									<DashboardPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/profile"
							element={
								<ProtectedRoute
									requiredRoles={[
										"student",
										"instructor",
										"admin",
									]}
								>
									<ProfilePage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/faculties"
							element={
								<ProtectedRoute requiredRoles={["admin"]}>
									<FacultyPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/ppes"
							element={
								<ProtectedRoute requiredRoles={["admin"]}>
									<PPEPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/semesters"
							element={
								<ProtectedRoute requiredRoles={["admin"]}>
									<SemesterPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/rooms"
							element={
								<ProtectedRoute requiredRoles={["admin"]}>
									<RoomPage />
								</ProtectedRoute>
							}
						/>
						<Route
							path="/users"
							element={
								<ProtectedRoute requiredRoles={["admin"]}>
									<UsersPage />
								</ProtectedRoute>
							}
						/>
					</Route>
				</Routes>
			</Router>
			<ReactQueryDevtools
				buttonPosition="bottom-right"
				initialIsOpen={false}
			/>
		</>
	);
};

export default App;
