import React from "react";
import { Outlet } from "react-router-dom";
import SideBar from "../components/SideBar";
import { Role } from "../types/user";

interface ProtectedLayoutProps {
	userRole: Role;
}

const ProtectedLayout: React.FC<ProtectedLayoutProps> = ({ userRole }) => {
	return (
		<div
			style={{
				display: "flex",
				backgroundColor: "var(--color-background-secondary)",
				minHeight: "100vh",
				position: "fixed",
				width: "100%",
			}}
		>
			<SideBar userRole={userRole} />
			<main
				style={{
					flexGrow: 1,
					padding: "1rem",
					backgroundColor: "var(--color-background-secondary)",
					height: "100vh",
					overflowY: "auto",
					overflowX: "hidden",
				}}
			>
				<Outlet />
			</main>
		</div>
	);
};

export default ProtectedLayout;
