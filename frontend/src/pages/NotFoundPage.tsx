import React from "react";
import { Button, Typography } from "@mui/material";
import { useNavigate } from "react-router-dom";

const NotFoundPage: React.FC = () => {
	const navigate = useNavigate();

	return (
		<div
			style={{
				minHeight: "100vh",
				display: "flex",
				alignItems: "center",
				justifyContent: "center",
				backgroundColor: "var(--color-background-secondary)",
				padding: "2rem",
			}}
		>
			<div style={{ textAlign: "center" }}>
				<Typography
					variant="h3"
					gutterBottom
					style={{ color: "var(--color-text)" }}
				>
					404 - Page Not Found
				</Typography>
				<Typography
					variant="body1"
					gutterBottom
					style={{ color: "var(--color-text)" }}
				>
					Oops! The page you’re looking for doesn’t exist.
				</Typography>
				<Button
					variant="contained"
					color="primary"
					onClick={() => navigate("/")}
				>
					Go Home
				</Button>
			</div>
		</div>
	);
};

export default NotFoundPage;
