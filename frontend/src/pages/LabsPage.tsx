import React, { useState, useEffect, useMemo } from "react";
import {
	Button,
	Typography,
	Box,
	Grid,
	CircularProgress,
	FormControl,
	InputLabel,
	MenuItem,
	Select,
	Card,
} from "@mui/material";
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
import { useSemesters } from "../hooks/useSemesters";

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
	const { data: semesters = [] } = useSemesters();
	const [semesterFilter, setSemesterFilter] = useState<string>("all");

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
		return labs
			.filter((lab) => {
				if (semesterFilter === "all") return true;
				return lab.semesterID.toString() === semesterFilter;
			})
			.filter(
				(lab) =>
					lab.labName
						.toLowerCase()
						.includes(searchQuery.toLowerCase()) ||
					lab.description
						.toLowerCase()
						.includes(searchQuery.toLowerCase())
			);
	}, [labs, searchQuery, semesterFilter]);

	// Group and sort labs by semester
	const groupedLabs = useMemo(() => {
		const groups = new Map<string, Lab[]>();

		filteredLabs.forEach((lab) => {
			const semester = semesters.find((s) => s.id === lab.semesterID);
			const semesterName = semester?.name || "Unknown";
			if (!groups.has(semesterName)) {
				groups.set(semesterName, []);
			}
			groups.get(semesterName)?.push(lab);
		});

		return Array.from(groups.entries()).sort((a, b) => {
			const semesterA = semesters.find((s) => s.name === a[0]);
			const semesterB = semesters.find((s) => s.name === b[0]);
			return (semesterB?.id || 0) - (semesterA?.id || 0);
		});
	}, [filteredLabs, semesters]);

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
				<Box
					sx={{
						display: "flex",
						justifyContent: "space-between",
						alignItems: "center",
						mb: 3,
						gap: 2,
					}}
				>
					<FormControl size="small" sx={{ minWidth: 120 }}>
						<InputLabel
							sx={{
								color: "var(--color-text)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
								transition: "color 0.2s ease-in-out",
							}}
						>
							Semester
						</InputLabel>
						<Select
							value={semesterFilter}
							onChange={(e) => setSemesterFilter(e.target.value)}
							label="Semester"
							sx={{
								color: "var(--color-text)",
								"& .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-border)",
								},
								"&:hover .MuiOutlinedInput-notchedOutline": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused .MuiOutlinedInput-notchedOutline":
									{
										borderColor: "var(--color-primary)",
									},
								"& .MuiSvgIcon-root": {
									color: "var(--color-text)",
								},
							}}
							MenuProps={{
								PaperProps: {
									sx: {
										bgcolor: "var(--color-card)",
										"& .MuiMenuItem-root": {
											color: "var(--color-text)",
											"&:hover": {
												bgcolor:
													"var(--color-card-hover)",
											},
											"&.Mui-selected": {
												bgcolor:
													"rgb(from var(--color-primary) r g b / 0.1)",
												"&:hover": {
													bgcolor:
														"rgb(from var(--color-primary) r g b / 0.2)",
												},
											},
										},
									},
								},
							}}
						>
							<MenuItem value="all">All Semesters</MenuItem>
							{semesters.map((semester) => (
								<MenuItem
									key={semester.id}
									value={semester.id.toString()}
								>
									{semester.name}
								</MenuItem>
							))}
						</Select>
					</FormControl>
					<SearchField
						value={searchQuery}
						onChange={(e) => setSearchQuery(e.target.value)}
						placeholder="Search labs..."
					/>
				</Box>

				<Box sx={{ p: 3, maxWidth: 1200, mx: "auto" }}>
					{groupedLabs.map(([semesterName, labs]) => (
						<Box key={semesterName} sx={{ mb: 4 }}>
							<Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
								<Typography
									variant="h6"
									sx={{
										color: "var(--color-text-secondary)",
										pl: 2,
										borderLeft: "4px solid var(--color-primary)",
										display: "flex",
										alignItems: "center",
										gap: 1
									}}
								>
									{semesterName}
									<Typography
										component="span"
										variant="body2"
										sx={{
											color: "var(--color-text-secondary)",
											ml: 1
										}}
									>
										({labs.length} {labs.length === 1 ? 'lab' : 'labs'})
									</Typography>
								</Typography>
							</Box>

							<Grid container spacing={3}>
								{labs.map((lab) => (
									<Grid item xs={12} sm={6} md={4} key={lab.id}>
										<LabCard lab={lab} onView={handleViewLab} />
									</Grid>
								))}
							</Grid>
						</Box>
					))}

					{filteredLabs.length === 0 && !isLoading && (
						<Card sx={{ p: 3, textAlign: "center", bgcolor: "var(--color-card)" }}>
							<Typography color="var(--color-text-secondary)">
								No labs found
							</Typography>
						</Card>
					)}
				</Box>
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
