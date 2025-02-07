import React, { useState, useEffect } from "react";
import { Button, Typography, Box, Grid, CircularProgress } from "@mui/material";
import { useUser } from "../contexts/UserContext";
import LabCard from "../components/LabCard";
import { labService } from "../services/labService";
import { Lab } from "../types/lab";
import AddIcon from "@mui/icons-material/Add";
import { useNavigate } from "react-router-dom";

const LabsPage: React.FC = () => {
	const [labs, setLabs] = useState<Lab[]>([]);
	const [loading, setLoading] = useState(true);
	const [error, setError] = useState<string | null>(null);
	const { user } = useUser();
	const navigate = useNavigate();

	const canCreateLab =
		user && (user.role === "instructor" || user.role === "admin");

	useEffect(() => {
		fetchLabs();
	}, [user?.id, user?.role]);

	const fetchLabs = async () => {
		if (!user?.id) return;

		setLoading(true);
		try {
			let data: Lab[];

			switch (user.role) {
				case "instructor":
					data = await labService.getInstructerLabs(user.id);
					break;
				case "student":
					data = await labService.getStudentLabs(user.id);
					break;
				case "admin":
					data = await labService.getLabs();
					break;
				default:
					throw new Error("Invalid user role");
			}

			setLabs(data);
		} catch (err: any) {
			setError(err.message || "Failed to fetch labs");
		} finally {
			setLoading(false);
		}
	};

	const handleViewLab = (lab: Lab) => {
		navigate(`/labs/${lab.id}`);
	};

	if (loading) {
		return (
			<Box
				display="flex"
				justifyContent="center"
				alignItems="center"
				minHeight="80vh"
			>
				<CircularProgress />
			</Box>
		);
	}

	if (error) {
		return (
			<Box
				display="flex"
				justifyContent="center"
				alignItems="center"
				minHeight="80vh"
			>
				<Typography color="error">{error}</Typography>
			</Box>
		);
	}

	return (
		<Box sx={{ p: 3, minHeight: "100vh" }}>
			<Box
				display="flex"
				justifyContent="space-between"
				alignItems="center"
				mb={3}
			>
				<Typography variant="h4" color="var(--color-text)">
					Labs
				</Typography>
				{canCreateLab && (
					<Button
						variant="contained"
						startIcon={<AddIcon />}
						onClick={() => console.log("Create new lab")}
					>
						Create Lab
					</Button>
				)}
			</Box>

			<Grid container spacing={3}>
				{labs.map((lab) => (
					<Grid item xs={12} sm={6} md={4} key={lab.id}>
						<LabCard
							lab={lab}
							onView={handleViewLab}
						/>
					</Grid>
				))}
				{labs.length === 0 && !loading && !error && (
					<Box sx={{ p: 3, textAlign: "center", width: "100%" }}>
						<Typography color="var(--color-text)">
							No labs found
						</Typography>
					</Box>
				)}
			</Grid>
		</Box>
	);
};

export default LabsPage;
