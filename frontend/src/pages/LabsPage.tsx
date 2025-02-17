import React, { useState, useEffect, useMemo } from "react";
import { Button, Typography, Box, Grid, CircularProgress } from "@mui/material";
import { useUser } from "../contexts/UserContext";
import LabCard from "../components/LabCard";
import { Lab } from "../types/lab";
import AddIcon from "@mui/icons-material/Add";
import { useNavigate } from "react-router-dom";
import { useLabsQuery } from "../hooks/useLabsQuery";
import ErrorAlert from "../components/ErrorAlertProps";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { labService } from "../services/labService";
import CreateLabModal from "../components/CreateLabModal";
import SearchField from "../components/SearchField";

const LabsPage: React.FC = () => {
	const { data: labs = [], isLoading, error } = useLabsQuery();
	const [openSnackbar, setOpenSnackbar] = useState(false);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("error");
	const { user } = useUser();
	const navigate = useNavigate();
	const [createModalOpen, setCreateModalOpen] = useState(false);
	const queryClient = useQueryClient();
	const [searchQuery, setSearchQuery] = useState("");

	const canCreateLab =
		user && (user.role === "instructor" || user.role === "admin");

	useEffect(() => {
		if (error) {
			setAlertMessage(
				(error as any).response?.data?.errors || "Failed to fetch labs"
			);
			setSeverity("error");
			setOpenSnackbar(true);
		}
	}, [error]);

	const handleViewLab = (lab: Lab) => {
		navigate(`/labs/${lab.id}`, { state: { lab } });
	};

	const createLabMutation = useMutation({
		mutationFn: labService.createLab,
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["labs"] });
			setCreateModalOpen(false);
			setAlertMessage("Lab created successfully");
			setSeverity("success");
			setOpenSnackbar(true);
		},
		onError: (error: any) => {
			console.log(error);
			let message = "Failed to create lab";
			if (typeof error.response?.data?.errors === "string")
				message = error.response?.data?.errors;
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		},
	});

	const filteredLabs = useMemo(() => {
		return labs.filter(
			(lab) =>
				lab.labName.toLowerCase().includes(searchQuery.toLowerCase()) ||
				lab.description.toLowerCase().includes(searchQuery.toLowerCase())
		);
	}, [labs, searchQuery]);

	if (isLoading) {
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
			<>
				<Box
					display="flex"
					justifyContent="center"
					alignItems="center"
					minHeight="80vh"
				>
					<Typography color="error">
						{(error as any).response?.data?.errors ||
							"An error occurred"}
					</Typography>
				</Box>
				<ErrorAlert
					open={openSnackbar}
					message={alertMessage}
					severity={severity}
					onClose={() => setOpenSnackbar(false)}
				/>
			</>
		);
	}

	return (
		<div style={{ minHeight: "100vh" }}>
			<Box sx={{ p: 3 }}>
				<Box
					sx={{
						display: "flex",
						justifyContent: "space-between",
						alignItems: "center",
						mb: 3,
						gap: 2,
					}}
				>
					<Typography variant="h4" color="var(--color-text)">
						Labs
					</Typography>

					<Box
						sx={{
							display: "flex",
							gap: 2,
							flex: 1,
							justifyContent: "flex-end",
							maxWidth: "600px",
						}}
					>
						<SearchField
							value={searchQuery}
							onChange={(e) => setSearchQuery(e.target.value)}
							placeholder="Search labs..."
						/>
						{canCreateLab && (
							<Button
								variant="contained"
								startIcon={<AddIcon />}
								sx={{
									bgcolor: "var(--color-primary)",
									color: "var(--color-text-button)",
								}}
								onClick={() => setCreateModalOpen(true)}
							>
								Create Lab
							</Button>
						)}
					</Box>
				</Box>

				<Grid container spacing={3}>
					{filteredLabs.map((lab) => (
						<Grid item xs={12} sm={6} md={4} key={lab.id}>
							<LabCard lab={lab} onView={handleViewLab} />
						</Grid>
					))}
					{filteredLabs.length === 0 && !isLoading && !error && (
						<Box sx={{ p: 3, textAlign: "center", width: "100%" }}>
							<Typography color="var(--color-text)">
								No labs found
							</Typography>
						</Box>
					)}
				</Grid>
			</Box>

			<CreateLabModal
				open={createModalOpen}
				onClose={() => setCreateModalOpen(false)}
				onSubmit={(data) => createLabMutation.mutate(data)}
			/>

			<ErrorAlert
				open={openSnackbar}
				message={alertMessage}
				severity={severity}
				onClose={() => setOpenSnackbar(false)}
			/>
		</div>
	);
};

export default LabsPage;
