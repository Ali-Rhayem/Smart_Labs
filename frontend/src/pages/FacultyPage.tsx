import React, { useState } from "react";
import {
	Box,
	Button,
	Paper,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	IconButton,
	Chip,
	Typography,
	Skeleton,
	Card,
} from "@mui/material";
import { useFaculties } from "../hooks/useFaculty";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { facultyService } from "../services/facultyService";
import AddIcon from "@mui/icons-material/Add";
import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import ErrorAlert from "../components/ErrorAlertProps";
import DeleteConfirmDialog from "../components/DeleteConfirmDialog";
import { faculty } from "../types/faculty";
import AddItemModal from "../components/AddItemModal";
import ErrorIcon from "@mui/icons-material/Error";

const FacultyPage: React.FC = () => {
	const { data: faculties = [], isLoading, error } = useFaculties();
	const [openDialog, setOpenDialog] = useState(false);
	const [, setFacultyName] = useState("");
	const [, setMajorName] = useState("");
	const [selectedFaculty, setSelectedFaculty] = useState<faculty | null>(
		null
	);
	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("success");
	const [showAlert, setShowAlert] = useState(false);
	const [openMajorDialog, setOpenMajorDialog] = useState(false);
	const [selectedFacultyForMajor, setSelectedFacultyForMajor] =
		useState<faculty | null>(null);
	const [deleteMajorDialogOpen, setDeleteMajorDialogOpen] = useState(false);
	const [selectedMajor, setSelectedMajor] = useState<{
		facultyId: number;
		majorName: string;
	} | null>(null);
	const [editDialogOpen, setEditDialogOpen] = useState(false);
	const [selectedFacultyForEdit, setSelectedFacultyForEdit] =
		useState<faculty | null>(null);
	const [expandedRows, setExpandedRows] = useState<number[]>([]);

	const queryClient = useQueryClient();

	const addFacultyMutation = useMutation({
		mutationFn: facultyService.addFaculty,
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Faculties"] });
			setOpenDialog(false);
			setFacultyName("");
			setAlertMessage("Faculty added successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to add faculty";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const deleteFacultyMutation = useMutation({
		mutationFn: facultyService.deleteFaculty,
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Faculties"] });
			setDeleteDialogOpen(false);
			setSelectedFaculty(null);
			setAlertMessage("Faculty deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to delete faculty";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const addMajorMutation = useMutation({
		mutationFn: (data: { facultyId: number; majorName: string }) =>
			facultyService.addMajor(data.facultyId, data.majorName),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Faculties"] });
			setOpenMajorDialog(false);
			setAlertMessage("Major added successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to add major";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const deleteMajorMutation = useMutation({
		mutationFn: (data: { facultyId: number; majorName: string }) =>
			facultyService.deleteMajor(data.facultyId, data.majorName),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Faculties"] });
			setAlertMessage("Major deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to delete major";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const editFacultyMutation = useMutation({
		mutationFn: (data: { id: number; name: string }) =>
			facultyService.updateFaculty(data.id, {
				id: data.id,
				faculty: data.name,
				major: [],
			}),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Faculties"] });
			setEditDialogOpen(false);
			setSelectedFacultyForEdit(null);
			setAlertMessage("Faculty updated successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to update faculty";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const handleAddFaculty = (facultyName: string) => {
		addFacultyMutation.mutate({
			id: 0,
			faculty: facultyName,
			major: [],
		});
	};

	const handleAddMajor = (majorName: string) => {
		if (selectedFacultyForMajor) {
			addMajorMutation.mutate({
				facultyId: selectedFacultyForMajor.id,
				majorName,
			});
		}
	};

	const handleDeleteMajorClick = (facultyId: number, majorName: string) => {
		setSelectedMajor({ facultyId, majorName });
		setDeleteMajorDialogOpen(true);
	};

	const handleConfirmDeleteMajor = () => {
		if (selectedMajor) {
			deleteMajorMutation.mutate({
				facultyId: selectedMajor.facultyId,
				majorName: selectedMajor.majorName,
			});
		}
		setDeleteMajorDialogOpen(false);
		setSelectedMajor(null);
	};

	const handleEditClick = (faculty: faculty) => {
		setSelectedFacultyForEdit(faculty);
		setEditDialogOpen(true);
	};

	const handleEditFaculty = (newName: string) => {
		if (selectedFacultyForEdit) {
			editFacultyMutation.mutate({
				id: selectedFacultyForEdit.id,
				name: newName,
			});
		}
	};

	const handleRowClick = (facultyId: number) => {
		setExpandedRows((prev) =>
			prev.includes(facultyId)
				? prev.filter((id) => id !== facultyId)
				: [...prev, facultyId]
		);
	};

	const renderLoadingSkeleton = () => (
		<Box sx={{ p: 2 }}>
			{[1, 2, 3].map((n) => (
				<Card
					key={n}
					sx={{
						mb: 2,
						p: 2,
						backgroundColor: "var(--color-card)",
						color: "var(--color-text)",
					}}
				>
					<Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
						<Box sx={{ flex: 1 }}>
							<Skeleton
								variant="text"
								width="40%"
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
					<Box sx={{ display: "flex", gap: 1 }}>
						<Skeleton
							variant="rounded"
							width={80}
							height={32}
							sx={{ bgcolor: "var(--color-card-hover)" }}
						/>
						<Skeleton
							variant="rounded"
							width={80}
							height={32}
							sx={{ bgcolor: "var(--color-card-hover)" }}
						/>
						<Skeleton
							variant="rounded"
							width={80}
							height={32}
							sx={{ bgcolor: "var(--color-card-hover)" }}
						/>
					</Box>
				</Card>
			))}
		</Box>
	);

	if (error) {
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
					sx={{
						fontSize: 60,
						color: "var(--color-danger)",
					}}
				/>
				<Typography variant="h6" sx={{ color: "var(--color-text)" }}>
					Failed to load faculties
				</Typography>
				<Button
					onClick={() =>
						queryClient.invalidateQueries({ queryKey: ["Faculties"] })
					}
					sx={{
						color: "var(--color-primary)",
						"&:hover": {
							bgcolor: "rgb(from var(--color-primary) r g b / 0.08)",
						},
					}}
				>
					Retry
				</Button>
			</Box>
		);
	}

	if (!isLoading && (!faculties || faculties.length === 0)) {
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
				<Box sx={{ textAlign: "center", mb: 3 }}>
					<Typography variant="h6" sx={{ color: "var(--color-text)" }}>
						No Faculties Found
					</Typography>
					<Typography
						variant="body2"
						sx={{ color: "var(--color-text-secondary)" }}
					>
						Start by adding a new faculty
					</Typography>
				</Box>
				<Button
					variant="contained"
					startIcon={<AddIcon />}
					onClick={() => setOpenDialog(true)}
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
						"&:hover": {
							bgcolor: "rgb(from var(--color-primary) r g b / 0.8)",
						},
					}}
				>
					Add Faculty
				</Button>
			</Box>
		);
	}

	if (isLoading) {
		return renderLoadingSkeleton();
	}

	return (
		<Box sx={{ p: 3 }}>
			<Box
				sx={{ display: "flex", justifyContent: "space-between", mb: 3 }}
			>
				<Typography variant="h4" color="var(--color-text)">
					Faculties
				</Typography>
				<Button
					variant="contained"
					startIcon={<AddIcon />}
					onClick={() => setOpenDialog(true)}
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-primary) r g b / 0.8)",
						},
					}}
				>
					Add Faculty
				</Button>
			</Box>

			<TableContainer
				component={Paper}
				sx={{
					backgroundColor: "var(--color-background)",
					borderRadius: "10px",
					overflow: "hidden",
				}}
			>
				<Table>
					<TableHead>
						<TableRow>
							<TableCell
								sx={{
									color: "var(--color-text)",
									backgroundColor: "var(--color-background)",
									fontWeight: "bold",
									borderBottom:
										"1px solid var(--color-text-secondary)",
								}}
							>
								Faculty Name
							</TableCell>
							<TableCell
								sx={{
									color: "var(--color-text)",
									backgroundColor: "var(--color-background)",
									fontWeight: "bold",
									borderBottom:
										"1px solid var(--color-text-secondary)",
								}}
							>
								Majors
							</TableCell>
							<TableCell
								align="right"
								sx={{
									color: "var(--color-text)",
									backgroundColor: "var(--color-background)",
									fontWeight: "bold",
									borderBottom:
										"1px solid var(--color-text-secondary)",
								}}
							>
								Actions
							</TableCell>
						</TableRow>
					</TableHead>
					<TableBody>
						{faculties.map((faculty) => (
							<React.Fragment key={faculty.id}>
								<TableRow
									onClick={() => handleRowClick(faculty.id)}
									sx={{
										cursor: "pointer",
										"&:hover": {
											backgroundColor:
												"var(--color-card-hover)",
										},
									}}
								>
									<TableCell
										sx={{
											color: "var(--color-text)",
											borderBottom:
												"1px solid var(--color-text-secondary)",
										}}
									>
										{faculty.faculty}
									</TableCell>
									<TableCell
										sx={{
											color: "var(--color-text)",
											borderBottom:
												"1px solid var(--color-text-secondary)",
										}}
									>
										{faculty.major.length} Majors
									</TableCell>
									<TableCell
										align="right"
										sx={{
											borderBottom:
												"1px solid var(--color-text-secondary)",
										}}
									>
										<IconButton
											onClick={(e) => {
												e.stopPropagation();
												handleEditClick(faculty);
											}}
											sx={{
												color: "var(--color-primary)",
												"&:hover": {
													bgcolor:
														"rgb(from var(--color-primary) r g b / 0.1)",
												},
											}}
										>
											<EditIcon />
										</IconButton>
										<IconButton
											onClick={(e) => {
												e.stopPropagation();
												setSelectedFaculty(faculty);
												setDeleteDialogOpen(true);
											}}
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
								<TableRow>
									<TableCell
										colSpan={3}
										sx={{
											p: 0,
											borderBottom: "none",
											transition: "all 0.3s ease",
											height: expandedRows.includes(
												faculty.id
											)
												? "auto"
												: 0,
											overflow: "hidden",
										}}
									>
										<Box
											sx={{
												p: 2,
												bgcolor:
													"var(--color-background-secondary)",
												display: expandedRows.includes(
													faculty.id
												)
													? "block"
													: "none",
											}}
										>
											<Box
												sx={{
													display: "flex",
													flexWrap: "wrap",
													gap: 1,
												}}
											>
												{faculty.major.map((major) => (
													<Chip
														key={major}
														label={major}
														onDelete={(e) => {
															e.stopPropagation();
															handleDeleteMajorClick(
																faculty.id,
																major
															);
														}}
														sx={{
															color: "var(--color-text)",
															background:
																"var(--color-card)",
														}}
													/>
												))}
												<Button
													size="small"
													onClick={(e) => {
														e.stopPropagation();
														setSelectedFacultyForMajor(
															faculty
														);
														setOpenMajorDialog(
															true
														);
													}}
													sx={{
														color: "var(--color-primary)",
														borderRadius: "25px",
														"&:hover": {
															bgcolor:
																"rgb(from var(--color-primary) r g b / 0.08)",
														},
													}}
												>
													Add Major
												</Button>
											</Box>
										</Box>
									</TableCell>
								</TableRow>
							</React.Fragment>
						))}
					</TableBody>
				</Table>
			</TableContainer>

			<AddItemModal
				title="Add Faculty"
				itemLabel="Faculty"
				placeholder="Enter faculty name"
				open={openDialog}
				onClose={() => {
					setOpenDialog(false);
					setFacultyName("");
				}}
				onSubmit={handleAddFaculty}
			/>

			<AddItemModal
				title="Add Major"
				itemLabel="Major"
				placeholder="Enter major name"
				open={openMajorDialog}
				onClose={() => {
					setOpenMajorDialog(false);
					setMajorName("");
				}}
				onSubmit={handleAddMajor}
			/>

			<AddItemModal
				title="Edit Faculty"
				itemLabel="Faculty"
				placeholder="Enter new faculty name"
				open={editDialogOpen}
				onClose={() => {
					setEditDialogOpen(false);
					setSelectedFacultyForEdit(null);
				}}
				onSubmit={handleEditFaculty}
				submitLabel="Update"
				initialValue={selectedFacultyForEdit?.faculty}
			/>

			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={() => {
					if (selectedFaculty) {
						deleteFacultyMutation.mutate(selectedFaculty.id);
					}
				}}
				title="Delete Faculty"
				message="Are you sure you want to delete this faculty?"
			/>

			<DeleteConfirmDialog
				open={deleteMajorDialogOpen}
				onClose={() => setDeleteMajorDialogOpen(false)}
				onConfirm={handleConfirmDeleteMajor}
				title="Delete Major"
				message={`Are you sure you want to delete major "${selectedMajor?.majorName}"?`}
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

export default FacultyPage;
