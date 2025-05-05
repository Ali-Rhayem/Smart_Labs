import React from "react";
import { Outlet } from "react-router-dom";

const PublicLayout: React.FC = () => {
	return (
		<div style={{backgroundColor: "var(--color-background-secondary)", minHeight: "100vh"}}>
			<Outlet />
		</div>
	);
};

export default PublicLayout;
