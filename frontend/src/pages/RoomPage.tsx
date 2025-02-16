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
import { useRooms } from "../hooks/useRooms";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { roomService } from "../services/roomService";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import ErrorIcon from "@mui/icons-material/Error";
import AddItemModal from "../components/AddItemModal";
import DeleteConfirmDialog from "../components/DeleteConfirmDialog";
import ErrorAlert from "../components/ErrorAlertProps";
import { Room } from "../types/room";
import TableSortLabel from "@mui/material/TableSortLabel";

type Order = "asc" | "desc";

const RoomPage: React.FC = () => {
	const { data: rooms = [], isLoading, error } = useRooms();
	const [openAddDialog, setOpenAddDialog] = useState(false);
	const [editingRoom, setEditingRoom] = useState<Room | null>(null);
	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [selectedRoom, setSelectedRoom] = useState<Room | null>(null);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("success");
	const [showAlert, setShowAlert] = useState(false);
	const [order, setOrder] = useState<Order>("asc");

	const queryClient = useQueryClient();

	const addRoomMutation = useMutation({
		mutationFn: (name: string) => roomService.createRoom({ name } as Room),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Rooms"] });
			setOpenAddDialog(false);
			setAlertMessage("Room added successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			setAlertMessage(
				error.response?.data?.message || "Failed to add room"
			);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const editRoomMutation = useMutation({
		mutationFn: ({
			oldRoom,
			newName,
		}: {
			oldRoom: Room;
			newName: string;
		}) =>
			roomService.updateRoom(oldRoom.name, {
				name: newName,
				id: oldRoom.id,
			}),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Rooms"] });
			setEditingRoom(null);
			setAlertMessage("Room updated successfully");
			setSeverity("success");
			setShowAlert(true);
		},
		onError: (error: any) => {
			setAlertMessage(
				error.response?.data?.message || "Failed to update room"
			);
			setSeverity("error");
			setShowAlert(true);
		},
	});

	const deleteRoomMutation = useMutation({
		mutationFn: (name: string) => roomService.deleteRoom(name),
		onSuccess: () => {
			queryClient.invalidateQueries({ queryKey: ["Rooms"] });
			setDeleteDialogOpen(false);
			setSelectedRoom(null);
			setAlertMessage("Room deleted successfully");
			setSeverity("success");
			setShowAlert(true);
		},
	});

	const handleRequestSort = () => {
		setOrder(order === "asc" ? "desc" : "asc");
	};

	const sortedRooms = React.useMemo(() => {
		return [...rooms].sort((a, b) => {
			return order === "asc"
				? a.name.localeCompare(b.name)
				: b.name.localeCompare(a.name);
		});
	}, [rooms, order]);

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
					sx={{ fontSize: 60, color: "var(--color-danger)" }}
				/>
				<Typography variant="h6" sx={{ color: "var(--color-text)" }}>
					Failed to load rooms
				</Typography>
				<Button
					onClick={() =>
						queryClient.invalidateQueries({ queryKey: ["Rooms"] })
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
	}

	if (!isLoading && rooms.length === 0) {
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
					<Typography
						variant="h6"
						sx={{ color: "var(--color-text)" }}
					>
						No Rooms Found
					</Typography>
					<Typography
						variant="body2"
						sx={{ color: "var(--color-text-secondary)" }}
					>
						Start by adding a new room
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
					Add Room
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
					Rooms
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
					Add Room
				</Button>
			</Box>

			<TableContainer
				component={Paper}
				sx={{ bgcolor: "var(--color-card)", borderRadius: "10px" }}
			>
				<Table>
					<TableHead>
						<TableRow>
							<TableCell>
								<TableSortLabel
									active={true}
									direction={order}
									onClick={handleRequestSort}
									sx={{
										color: "var(--color-text) !important",
										"& .MuiTableSortLabel-icon": {
											color: "var(--color-text-secondary) !important",
										},
										"&.Mui-active": {
											color: "var(--color-text) !important",
										},
									}}
								>
									Room Name
								</TableSortLabel>
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
						{sortedRooms.map((room) => (
							<TableRow
								key={room.id}
								sx={{
									"&:hover": {
										backgroundColor:
											"var(--color-card-hover)",
									},
								}}
							>
								<TableCell sx={{ color: "var(--color-text)" }}>
									{room.name}
								</TableCell>
								<TableCell align="right">
									<IconButton
										onClick={() => setEditingRoom(room)}
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
										onClick={() => {
											setSelectedRoom(room);
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
				title="Add Room"
				itemLabel="Room"
				open={openAddDialog}
				onClose={() => setOpenAddDialog(false)}
				onSubmit={(name) => addRoomMutation.mutate(name)}
			/>

			<AddItemModal
				title="Edit Room"
				itemLabel="Room"
				open={Boolean(editingRoom)}
				onClose={() => setEditingRoom(null)}
				onSubmit={(newName) => {
					if (editingRoom) {
						editRoomMutation.mutate({
							oldRoom: editingRoom,
							newName: newName,
						});
					}
				}}
				initialValue={editingRoom?.name}
				submitLabel="Update"
			/>

			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={() => {
					if (selectedRoom) {
						deleteRoomMutation.mutate(selectedRoom.name);
					}
				}}
				title="Delete Room"
				message={`Are you sure you want to delete "${selectedRoom?.name}"?`}
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

export default RoomPage;
