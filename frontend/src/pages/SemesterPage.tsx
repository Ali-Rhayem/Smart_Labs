import React, { useState } from "react";
import {
	Box,
	Button,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
	IconButton,
	Typography,
	Skeleton,
	Chip,
} from "@mui/material";
import { useSemesters } from "../hooks/useSemesters";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { semesterService } from "../services/semesterService";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import ErrorIcon from "@mui/icons-material/Error";
import AddItemModal from "../components/AddItemModal";
import DeleteConfirmDialog from "../components/DeleteConfirmDialog";
import ErrorAlert from "../components/ErrorAlertProps";
import { Semester } from "../types/semester";

const SemesterPage: React.FC = () => {
	const { data: semesters = [], isLoading, error } = useSemesters();
	const [openAddDialog, setOpenAddDialog] = useState(false);
	const [editingSemester, setEditingSemester] = useState<Semester | null>(
		null
	);
	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [selectedSemester, setSelectedSemester] = useState<Semester | null>(
		null
	);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("success");
	const [showAlert, setShowAlert] = useState(false);
	const [toggleDialogOpen, setToggleDialogOpen] = useState(false);
	const [selectedForToggle, setSelectedForToggle] = useState<Semester | null>(
		null
	);

	const queryClient = useQueryClient();

	const addSemesterMutation = useMutation({
		mutationFn: (name: string) =>
			semesterService.createSemester({ name } as Semester),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Semesters"] });
			setOpenAddDialog(false);
			setAlertMessage("Semester added successfully");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const editSemesterMutation = useMutation({
		mutationFn: (data: Semester) =>
			semesterService.updateSemester(data.id, {
				id: data.id,
				name: data.name,
				currentSemester: data.currentSemester,
			} as Semester),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Semesters"] });
			setEditingSemester(null);
			setAlertMessage("Semester updated successfully");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const deleteSemesterMutation = useMutation({
		mutationFn: (id: string) => semesterService.deleteSemester(id),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Semesters"] });
			setDeleteDialogOpen(false);
			setSelectedSemester(null);
			setAlertMessage("Semester deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const toggleCurrentSemesterMutation = useMutation({
		mutationFn: (id: number) => semesterService.toggleCurrentSemester(id),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Semesters"] });
			setToggleDialogOpen(false);
			setSelectedForToggle(null);
			setAlertMessage("Semester updated successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to update Semester";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setToggleDialogOpen(false);
			setSelectedForToggle(null);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const sortedSemesters = React.useMemo(() => {
		return [...semesters].sort((a, b) => b.id - a.id);
	}, [semesters]);

	const renderLoadingSkeleton = () => (
		<Box sx={{ p: 2 }}>
			{[1, 2, 3].map((n) => (
				<Paper
					key={n}
					sx={{
						mb: 2,
						p: 2,
						backgroundColor: "var(--color-card)",
						color: "var(--color-text)",
					}}
				>
					<Box sx={{ display: "flex", alignItems: "center" }}>
						<Box sx={{ flex: 1 }}>
							<Skeleton
								variant="text"
								width="30%"
								sx={{ bgcolor: "var(--color-card-hover)" }}
							/>
						</Box>
						<Box sx={{ display: "flex", gap: 1 }}>
							<Skeleton
								variant="circular"
								width={32}
								height={32}
								sx={{ bgcolor: "var(--color-card-hover)" }}
							/>
							<Skeleton
								variant="circular"
								width={32}
								height={32}
								sx={{ bgcolor: "var(--color-card-hover)" }}
							/>
						</Box>
					</Box>
				</Paper>
			))}
		</Box>
	);

	const renderError = () => {
		return (
			<Box
				sx={{
					p: 3,
					display: "flex",
					flexDirection: "column",
					alignItems: "center",
					gap: 2,
				}}
			>
				<ErrorIcon
					sx={{ fontSize: 60, color: "var(--color-danger)" }}
				/>
				<Typography variant="h6" sx={{ color: "var(--color-text)" }}>
					Failed to load PPEs
				</Typography>
				<Button
					onClick={() =>
						queryClient.invalidateQueries({ queryKey: ["allPPEs"] })
					}
					sx={{
						color: "var(--color-primary)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-primary) r g b / 0.08)",
						},
					}}
				>
					Retry
				</Button>
			</Box>
		);
	};

	const renderEmpty = () => (
		<Box
			sx={{
				p: 3,
				display: "flex",
				flexDirection: "column",
				alignItems: "center",
				gap: 2,
			}}
		>
			<Box sx={{ textAlign: "center", mb: 3 }}>
				<Typography variant="h6" sx={{ color: "var(--color-text)" }}>
					No Semesters found
				</Typography>
				<Typography
					variant="body2"
					sx={{ color: "var(--color-text-secondary)" }}
				>
					Start by adding a new Semester
				</Typography>
			</Box>
			<Button
				variant="contained"
				startIcon={<AddIcon />}
				onClick={() => setOpenAddDialog(true)}
				sx={{
					bgcolor: "var(--color-primary)",
					color: "var(--color-text-button)",
				}}
			>
				Add Semester
			</Button>
		</Box>
	);

	const currentSemester = semesters.find((s) => s.currentSemester);

	const handleToggleCurrent = (semester: Semester) => {
		if (semester.currentSemester) {
			setAlertMessage(
				"Cannot deactivate current semester. Select another semester as current first."
			);
			setSeverity("error");
			setShowAlert(true);
			return;
		}
		setSelectedForToggle(semester);
		setToggleDialogOpen(true);
	};

	if (isLoading) {
		return renderLoadingSkeleton();
	}

	if (error) {
		return renderError();
	}

	if (!semesters.length) {
		return renderEmpty();
	}

	return (
		<Box sx={{ p: 3 }}>
			{/* Current Semester Section */}
			<Paper
				sx={{
					p: 2,
					mb: 3,
					bgcolor: "var(--color-card)",
					borderRadius: "10px",
				}}
			>
				<Typography
					variant="h6"
					sx={{ color: "var(--color-text)", mb: 2 }}
				>
					Current Semester
				</Typography>
				{currentSemester ? (
					<Box
						sx={{
							display: "flex",
							justifyContent: "space-between",
							alignItems: "center",
						}}
					>
						<Typography sx={{ color: "var(--color-text)" }}>
							{currentSemester.name}
						</Typography>
					</Box>
				) : (
					<Typography sx={{ color: "var(--color-text-secondary)" }}>
						No current semester selected
					</Typography>
				)}
			</Paper>

			<Box
				sx={{ display: "flex", justifyContent: "space-between", mb: 3 }}
			>
				<Typography variant="h4" color="var(--color-text)">
					Semesters
				</Typography>
				<Button
					variant="contained"
					startIcon={<AddIcon />}
					onClick={() => setOpenAddDialog(true)}
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
					}}
				>
					Add Semester
				</Button>
			</Box>

			<TableContainer
				component={Paper}
				sx={{
					bgcolor: "var(--color-card)",
					borderRadius: "10px",
				}}
			>
				<Table>
					<TableHead>
						<TableRow>
							<TableCell
								sx={{
									color: "var(--color-text)",
									fontWeight: "bold",
								}}
							>
								Semester Name
							</TableCell>
							<TableCell
								align="right"
								sx={{
									color: "var(--color-text)",
									fontWeight: "bold",
								}}
							>
								Actions
							</TableCell>
						</TableRow>
					</TableHead>
					<TableBody>
						{sortedSemesters.map((semester) => (
							<TableRow
								key={semester.id}
								sx={{
									bgcolor: semester.currentSemester
										? "rgb(from var(--color-primary) r g b / 0.1)"
										: "inherit",
									"&:hover": {
										backgroundColor:
											!semester.currentSemester
												? "var(--color-card-hover)"
												: "rgb(from var(--color-primary) r g b / 0.1)",
									},
								}}
							>
								<TableCell sx={{ color: "var(--color-text)" }}>
									{semester.name}
									{semester.currentSemester && (
										<Chip
											label="Current"
											size="small"
											sx={{
												ml: 1,
												bgcolor: "var(--color-primary)",
												color: "var(--color-text-button)",
											}}
										/>
									)}
								</TableCell>
								<TableCell align="right">
									{!semester.currentSemester && (
										<Button
											size="small"
											onClick={() =>
												handleToggleCurrent(semester)
											}
											sx={{
												mr: 1,
												color: "var(--color-primary)",
												"&:hover": {
													bgcolor:
														"rgb(from var(--color-primary) r g b / 0.08)",
												},
											}}
										>
											Set as Current
										</Button>
									)}
									<IconButton
										onClick={() =>
											setEditingSemester(semester)
										}
										sx={{
											color: "var(--color-primary)",
											"&:hover": {
												backgroundColor:
													"rgb(from var(--color-primary) r g b / 0.1)",
											},
										}}
									>
										<EditIcon />
									</IconButton>
									<IconButton
										onClick={() => {
											setSelectedSemester(semester);
											setDeleteDialogOpen(true);
										}}
										disabled={semester.currentSemester}
										sx={{
											color: "var(--color-danger)",
											"&:hover": {
												bgcolor:
													"rgb(from var(--color-danger) r g b / 0.1)",
											},
										}}
									>
										<DeleteIcon />
									</IconButton>
								</TableCell>
							</TableRow>
						))}
					</TableBody>
				</Table>
			</TableContainer>

			<AddItemModal
				title="Add Semester"
				itemLabel="Semester"
				open={openAddDialog}
				onClose={() => setOpenAddDialog(false)}
				onSubmit={(name) => addSemesterMutation.mutate(name)}
			/>

			<AddItemModal
				title="Edit Semester"
				itemLabel="Semester"
				open={Boolean(editingSemester)}
				onClose={() => setEditingSemester(null)}
				onSubmit={(name) => {
					if (editingSemester) {
						editSemesterMutation.mutate({
							id: editingSemester.id,
							name,
							currentSemester: editingSemester.currentSemester,
						});
					}
				}}
				initialValue={editingSemester?.name}
				submitLabel="Update"
			/>

			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={() => {
					if (selectedSemester) {
						deleteSemesterMutation.mutate(
							selectedSemester.id.toString()
						);
					}
				}}
				title="Delete Semester"
				message={`Are you sure you want to delete "${selectedSemester?.name}"?`}
			/>

			<DeleteConfirmDialog
				open={toggleDialogOpen}
				onClose={() => {
					setToggleDialogOpen(false);
					setSelectedForToggle(null);
				}}
				onConfirm={() => {
					if (selectedForToggle) {
						toggleCurrentSemesterMutation.mutate(
							selectedForToggle.id
						);
					}
				}}
				title="Change Current Semester"
				message={`Are you sure you want to set "${selectedForToggle?.name}" as the current semester?`}
				submitColor="var(--color-primary)"
				submitLabel="Set as Current"
			/>

			<ErrorAlert
				open={showAlert}
				message={alertMessage}
				severity={severity}
				onClose={() => setShowAlert(false)}
			/>
		</Box>
	);
};

export default SemesterPage;
