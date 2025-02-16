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
} from "@mui/material";
import { useAllPPEs } from "../hooks/usePPE";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { ppeService } from "../services/ppeService";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import AddItemModal from "../components/AddItemModal";
import DeleteConfirmDialog from "../components/DeleteConfirmDialog";
import ErrorAlert from "../components/ErrorAlertProps";
import { PPE } from "../types/ppe";

const PPEPage: React.FC = () => {
	const { data: ppes = [], isLoading } = useAllPPEs();
	const [openAddDialog, setOpenAddDialog] = useState(false);
	const [editingPPE, setEditingPPE] = useState<PPE | null>(null);
	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [selectedPPE, setSelectedPPE] = useState<PPE | null>(null);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("success");
	const [showAlert, setShowAlert] = useState(false);

	const queryClient = useQueryClient();

	const addPPEMutation = useMutation({
		mutationFn: (name: string) => ppeService.addPPE({ name }),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["allPPEs"] });
			setOpenAddDialog(false);
			setAlertMessage("PPE added successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to add PPE";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const editPPEMutation = useMutation({
		mutationFn: (data: { id: number; name: string }) =>
			ppeService.editPPE(data.id, { name: data.name }),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["allPPEs"] });
			setEditingPPE(null);
			setAlertMessage("PPE updated successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to update PPE";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const deletePPEMutation = useMutation({
		mutationFn: (id: number) => ppeService.removePPE(id),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["allPPEs"] });
			setDeleteDialogOpen(false);
			setSelectedPPE(null);
			setAlertMessage("PPE deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			let message = "Failed to delete PPE";
			if (error.response?.data?.message) {
				message = error.response.data.message;
			}
			setAlertMessage(message);
			setSeverity("error");
			setShowAlert(true);
		},
	});

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

	if (isLoading) {
		return renderLoadingSkeleton();
	}

	return (
		<Box sx={{ p: 3 }}>
			<Box
				sx={{ display: "flex", justifyContent: "space-between", mb: 3 }}
			>
				<Typography variant="h4" color="var(--color-text)">
					PPEs
				</Typography>
				<Button
					variant="contained"
					startIcon={<AddIcon />}
					onClick={() => setOpenAddDialog(true)}
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-primary) r g b / 0.8)",
						},
					}}
				>
					Add PPE
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
								PPE Name
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
						{ppes.map((ppe) => (
							<TableRow key={ppe.id}>
								<TableCell sx={{ color: "var(--color-text)" }}>
									{ppe.name}
								</TableCell>
								<TableCell align="right">
									<IconButton
										onClick={() => setEditingPPE(ppe)}
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
											setSelectedPPE(ppe);
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
						))}
					</TableBody>
				</Table>
			</TableContainer>

			<AddItemModal
				title="Add PPE"
				itemLabel="PPE"
				open={openAddDialog}
				onClose={() => setOpenAddDialog(false)}
				onSubmit={(name) => addPPEMutation.mutate(name)}
			/>

			<AddItemModal
				title="Edit PPE"
				itemLabel="PPE"
				open={Boolean(editingPPE)}
				onClose={() => setEditingPPE(null)}
				onSubmit={(name) => {
					if (editingPPE) {
						editPPEMutation.mutate({ id: editingPPE.id, name });
					}
				}}
				initialValue={editingPPE?.name}
				submitLabel="Update"
			/>

			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={() => {
					if (selectedPPE) {
						deletePPEMutation.mutate(selectedPPE.id);
					}
				}}
				title="Delete PPE"
				message={`Are you sure you want to delete "${selectedPPE?.name}"?`}
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

export default PPEPage;
