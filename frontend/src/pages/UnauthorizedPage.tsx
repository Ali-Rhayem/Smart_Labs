import React from "react";
import { Button, Typography } from "@mui/material";
import { useNavigate } from "react-router-dom";

const UnauthorizedPage: React.FC = () => {
	const navigate = useNavigate();

	return (
		<div
			style={{
				minHeight: "100vh",
				display: "flex",
				flexDirection: "column",
				alignItems: "center",
				justifyContent: "center",
				textAlign: "center",
				padding: "2rem",
			}}
		>
			<Typography variant="h3" gutterBottom style={{ color: "var(--color-text)" }}>
				Unauthorized
			</Typography>
			<Typography variant="body1" gutterBottom style={{ color: "var(--color-text)" }}>
				You do not have permission to view this page.
			</Typography>
			<Button
				variant="contained"
				color="primary"
				onClick={() => navigate("/")}
			>
				Go Home
			</Button>
		</div>
	);
};

export default UnauthorizedPage;
