import React, { useState, useEffect } from "react";
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

const LabsPage: React.FC = () => {
	const { data: labs = [], isLoading, error } = useLabsQuery();
	const [openSnackbar, setOpenSnackbar] = useState(false);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("error");
	const { user } = useUser();
	const navigate = useNavigate();
	const [createModalOpen, setCreateModalOpen] = useState(false);
	const queryClient = useQueryClient();

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
			setAlertMessage(
				error.response?.data?.errors || "Failed to create lab"
			);
			setSeverity("error");
			setOpenSnackbar(true);
		},
	});

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
		<div style={{ maxHeight: "100vh" }}>
			<Box sx={{ p: 3 }}>
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
							sx={{
								backgroundColor: "var(--color-primary)",
								color: "var(--color-text-button)",
							}}
							onClick={() => setCreateModalOpen(true)}
						>
							Create Lab
						</Button>
					)}
				</Box>

				<Grid container spacing={3}>
					{labs.map((lab) => (
						<Grid item xs={12} sm={6} md={4} key={lab.id}>
							<LabCard lab={lab} onView={handleViewLab} />
						</Grid>
					))}
					{labs.length === 0 && !isLoading && !error && (
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
