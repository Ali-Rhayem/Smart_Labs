import React, { useState } from "react";
import {
	Box,
	Typography,
	Tabs,
	Tab,
	Chip,
	Button,
	IconButton,
	Menu,
	MenuItem,
} from "@mui/material";
import { useLocation, useNavigate } from "react-router-dom";
import { useUser } from "../contexts/UserContext";
import ErrorAlert from "../components/ErrorAlertProps";
import ScheduleView from "../components/ScheduleView";
import PeopleTab from "../components/PeopleTab";
import { useLabUsers } from "../hooks/useLabsQuery";
import EditLabModal from "../components/EditLabModal";
import EditIcon from "@mui/icons-material/Edit";
import { usePPE } from "../hooks/usePPE";
import SafetyIcon from "@mui/icons-material/VerifiedUser";
import { useAllPPEs } from "../hooks/usePPE";
import EditPPEModal from "../components/EditPPEModal";
import { labService } from "../services/labService";
import { useQueryClient, useMutation } from "@tanstack/react-query";
import SessionsTab from "../components/SessionsTab";
import AnnouncementsTab from "../components/AnnouncementsTab";
import { User } from "../types/user";
import { UpdateLabDto } from "../types/lab";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import ArchiveIcon from "@mui/icons-material/Archive";
import DeleteIcon from "@mui/icons-material/Delete";
import DeleteConfirmDialog from "../components/DeleteConfirmDialog";

interface TabPanelProps {
	children?: React.ReactNode;
	index: number;
	value: number;
}

const TabPanel: React.FC<TabPanelProps> = ({ children, value, index }) => (
	<Box
		hidden={value !== index}
		sx={{
			p: 3,
			minHeight: "100%",
		}}
	>
		{value === index && children}
	</Box>
);

const LabPage: React.FC = () => {
	const location = useLocation();
	const navigate = useNavigate();
	const { user } = useUser();
	const [lab, setLab] = useState(location.state?.lab);
	const [tabValue, setTabValue] = useState(0);
	const [openSnackbar, setOpenSnackbar] = useState(false);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("error");
	const [editModalOpen, setEditModalOpen] = useState(false);
	const [editPPEOpen, setEditPPEOpen] = useState(false);
	const [selectedPPEs, setSelectedPPEs] = useState<number[]>(lab.ppe || []);
	const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
	const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
	const [archiveDialogOpen, setArchiveDialogOpen] = useState(false);
	const {
		instructors,
		students,
		isLoading: usersLoading,
	} = useLabUsers(lab.id);
	const { data: allPPEs = [] } = useAllPPEs();
	const queryClient = useQueryClient();
	const { data: ppes = [], isLoading: ppesLoading } = usePPE(lab.ppe);

	const canManageLab =
		user! && (user.role === "instructor" || user.role === "admin");

	if (!lab) {
		navigate("/labs");
		return null;
	}

	const handleTabChange = (_: React.SyntheticEvent, newValue: number) => {
		setTabValue(newValue);
	};

	const handleRemoveInstructor = async (user: User) => {
		try {
			await labService.removeInstructor(lab.id, user.id);
			queryClient.invalidateQueries({
				queryKey: ["labs", `${user?.role}`, user?.id],
			});
			setLab((prev: any) => ({
				...prev,
				instructors: prev.instructors.filter(
					(id: number) => id !== user.id
				),
			}));
			queryClient.invalidateQueries({
				queryKey: ["labInstructors", lab.id],
			});
			setAlertMessage("Instructor removed successfully");
			setSeverity("success");
			setOpenSnackbar(true);
		} catch (err: any) {
			let message = "Failed to remove instructor";
			if (err?.response?.data?.errors) {
				message = err.response.data.errors;
			}
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

	const handleRemoveStudent = async (user: User) => {
		try {
			await labService.removeStudent(lab.id, user.id);
			queryClient.invalidateQueries({
				queryKey: ["labs", `${user?.role}`, user?.id],
			});
			setLab((prev: any) => ({
				...prev,
				students: prev.students.filter((id: number) => id !== user.id),
			}));
			queryClient.invalidateQueries({
				queryKey: ["labStudents", lab.id],
			});
			setAlertMessage("Student removed successfully");
			setSeverity("success");
			setOpenSnackbar(true);
		} catch (err: any) {
			let message = "Failed to remove student";
			if (err?.response?.data?.errors) {
				message = err.response.data.errors;
			}
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

	const handleAddStudent = async (emails: string[]) => {
		try {
			const students_ids = await labService.addStudents(lab.id, emails);
			setLab((prev: any) => ({
				...prev,
				students: [...prev.students, ...students_ids],
			}));
			queryClient.invalidateQueries({
				queryKey: ["labs", `${user?.role}`, user?.id],
			});
			queryClient.invalidateQueries({
				queryKey: ["labStudents", lab.id],
			});
			setAlertMessage("Students added successfully");
			setSeverity("success");
			setOpenSnackbar(true);
		} catch (err: any) {
			let message = "Failed to add students";
			if (err?.response?.data?.errors) {
				message = err.response.data.errors;
			}
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

	const handleAddInstructor = async (emails: string[]) => {
		try {
			const instructors_ids = await labService.addInstructors(
				lab.id,
				emails
			);
			setLab((prev: any) => ({
				...prev,
				instructors: [...prev.instructors, ...instructors_ids],
			}));
			queryClient.invalidateQueries({
				queryKey: ["labs", `${user?.role}`, user?.id],
			});
			queryClient.invalidateQueries({
				queryKey: ["labInstructors", lab.id],
			});
			setAlertMessage("Instructors added successfully");
			setSeverity("success");
			setOpenSnackbar(true);
		} catch (err: any) {
			let message = "Failed to add instructors";
			if (err?.response?.data?.errors) {
				message = err.response.data.errors;
			}
			console.log(err);
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

	const handleEditLab = async (data: UpdateLabDto) => {
		try {
			await labService.updateLab(lab.id, data);
			queryClient.invalidateQueries({
				queryKey: ["labs", `${user?.role}`, user?.id],
			});
			setLab((prev: any) => ({ ...prev, ...data }));
			setAlertMessage("Lab updated successfully");
			setSeverity("success");
			setOpenSnackbar(true);
			setEditModalOpen(false);
		} catch (err: any) {
			let message = "Failed to update lab";
			if (err?.response?.data?.errors) {
				message = err.response.data.errors;
			}
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
			setEditModalOpen(false);
		}
	};

	const handleEditPPEOpen = () => {
		setSelectedPPEs(lab.ppe || []);
		setEditPPEOpen(true);
	};

	const handleEditPPEClose = () => {
		setSelectedPPEs(lab.ppe || []);
		setEditPPEOpen(false);
	};

	const handleSavePPE = async (selected: number[]) => {
		try {
			await labService.editLabPPES(lab.id, selected);
			queryClient.invalidateQueries({
				queryKey: ["labs", `${user?.role}`, user?.id],
			});
			setLab((prev: any) => ({ ...prev, ppe: selected }));
			setSelectedPPEs(selected);
			setAlertMessage("PPE requirements updated successfully");
			setSeverity("success");
			setOpenSnackbar(true);
			setEditPPEOpen(false);
		} catch (err) {
			setAlertMessage("Failed to update PPE requirements");
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

	const deleteMutation = useMutation({
		mutationFn: () => labService.deleteLab(lab.id),
		onSuccess: () => {
			navigate("/labs");
			queryClient.invalidateQueries({ queryKey: ["labs"] });
		},
		onError: (err: any) => {
			let message = "Failed to delete lab";
			if (err?.response?.data?.errors) message = err.response.data.errors;
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		},
	});

	const archiveMutation = useMutation({
		mutationFn: () => labService.archiveLab(lab.id),
		onSuccess: () => {
			setLab((prev: any) => ({ ...prev, endLab: true }));
			queryClient.invalidateQueries({ queryKey: ["labs"] });
			setAlertMessage("Lab archived successfully");
			setSeverity("success");
			setArchiveDialogOpen(false);
			setOpenSnackbar(true);
		},
		onError: (err: any) => {
			let message = "Failed to archive lab";
			if (err?.response?.data?.errors) message = err.response.data.errors;
			setAlertMessage(message);
			setSeverity("error");
			setOpenSnackbar(true);
		},
	});

	return (
		<Box
			sx={{
				minHeight: "100%",
				bgcolor: "var(--color-background-secondary)",
				color: "var(--color-text)",
				position: "relative",
			}}
		>
			<Box sx={{ p: 3, borderBottom: 1, borderColor: "divider" }}>
				<Box
					sx={{
						display: "flex",
						justifyContent: "space-between",
					}}
				>
					<Box>
						<Typography variant="h4" gutterBottom>
							{lab.labName}
						</Typography>
						<Typography
							variant="subtitle1"
							color="var(--color-text)"
							gutterBottom
						>
							{lab.labCode}
						</Typography>
						<Typography
							variant="body1"
							sx={{
								my: 2,
								color: "var(--color-text)",
								whiteSpace: "pre-line",
							}}
						>
							{lab.description || "No description available"}
						</Typography>
						<Typography variant="body2" color="var(--color-text)">
							Room: {lab.room || "Not assigned"}
						</Typography>
						<Box sx={{ mt: 2 }}>
							<ScheduleView schedules={lab.schedule} />
						</Box>
						<Box sx={{ mt: 3 }}>
							<Box
								sx={{
									display: "flex",
									justifyContent: "space-between",
									alignItems: "center",
									mb: 2,
								}}
							>
								<Typography
									variant="h6"
									sx={{
										display: "flex",
										alignItems: "center",
										gap: 1,
									}}
								>
									<SafetyIcon />
									Required PPE
									{canManageLab && (
										<IconButton
											size="small"
											onClick={handleEditPPEOpen}
											sx={{
												ml: 1,
												p: 0.5,
												color: "var(--color-text-secondary)",
												"&:hover": {
													color: "var(--color-primary)",
												},
											}}
										>
											<EditIcon fontSize="small" />
										</IconButton>
									)}
								</Typography>
							</Box>
							<Box
								sx={{
									display: "flex",
									gap: 2,
									flexWrap: "wrap",
								}}
							>
								{ppes.length > 0
									? ppes.map((ppe) => (
											<Chip
												key={ppe.id}
												label={ppe.name}
												variant={"outlined"}
												sx={{
													bgcolor: "transparent",
													borderColor:
														"var(--color-primary)",
													color: "var(--color-primary)",
												}}
											/>
									  ))
									: !ppesLoading && (
											<Typography
												variant="body2"
												color="var(--color-text-secondary)"
											>
												No PPE requirements specified
											</Typography>
									  )}
							</Box>
						</Box>
					</Box>
					<Box sx={{ display: "flex", gap: 1, alignItems: "start" }}>
						{lab.started && (
							<Chip color="success" label="In Progress" />
						)}
						{lab.endLab && <Chip color="error" label="archived" />}
						{canManageLab && (
							<>
								<Button
									variant="contained"
									startIcon={<EditIcon />}
									onClick={() => setEditModalOpen(true)}
									size="small"
									sx={{
										bgcolor: "var(--color-primary)",
										color: "var(--color-text-button)",
										whiteSpace: "nowrap",
									}}
								>
									Edit Lab
								</Button>
								<IconButton
									onClick={(e) =>
										setAnchorEl(e.currentTarget)
									}
									sx={{
										color: "var(--color-text)",
										"&:hover": {
											color: "var(--color-primary)",
										},
									}}
								>
									<MoreVertIcon />
								</IconButton>
								<Menu
									anchorEl={anchorEl}
									open={Boolean(anchorEl)}
									onClose={() => setAnchorEl(null)}
									PaperProps={{
										sx: {
											bgcolor: "var(--color-card)",
											color: "var(--color-text)",
										},
									}}
								>
									<MenuItem
										onClick={() => {
											setAnchorEl(null);
											setArchiveDialogOpen(true);
										}}
										sx={{
											"&:hover": {
												bgcolor:
													"var(--color-card-hover)",
											},
											gap: 1,
										}}
									>
										<ArchiveIcon
											sx={{
												color: "var(--color-warning)",
											}}
										/>
										Archive Lab
									</MenuItem>
									<MenuItem
										onClick={() => {
											setAnchorEl(null);
											setDeleteDialogOpen(true);
										}}
										sx={{
											"&:hover": {
												bgcolor:
													"var(--color-card-hover)",
											},
											gap: 1,
										}}
									>
										<DeleteIcon
											sx={{
												color: "var(--color-danger)",
											}}
										/>
										Delete Lab
									</MenuItem>
								</Menu>
							</>
						)}
					</Box>
				</Box>
			</Box>

			<Tabs
				value={tabValue}
				onChange={handleTabChange}
				sx={{
					borderBottom: 1,
					borderColor: "divider",
					"& .MuiTab-root": {
						color: "var(--color-text)",
						"&.Mui-selected": {
							color: "var(--color-primary)",
						},
					},
					"& .MuiTabs-indicator": {
						backgroundColor: "var(--color-primary)",
					},
				}}
			>
				<Tab label="Sessions" />
				<Tab label="people" />
				<Tab label="Analytics" />
				<Tab label="Announcements" />
			</Tabs>

			{/* Tab Panels */}
			<TabPanel value={tabValue} index={0}>
				<SessionsTab labId={lab.id} />
			</TabPanel>
			<TabPanel value={tabValue} index={1}>
				<PeopleTab
					instructors={instructors}
					students={students}
					isLoading={usersLoading}
					canManage={canManageLab}
					onAddInstructor={handleAddInstructor}
					onAddStudent={handleAddStudent}
					onRemoveInstructor={handleRemoveInstructor}
					onRemoveStudent={handleRemoveStudent}
				/>
			</TabPanel>
			<TabPanel value={tabValue} index={2}>
				Analytics
			</TabPanel>
			<TabPanel value={tabValue} index={3}>
				<AnnouncementsTab labId={lab.id} />
			</TabPanel>

			<ErrorAlert
				open={openSnackbar}
				message={alertMessage}
				severity={severity}
				onClose={() => setOpenSnackbar(false)}
			/>

			<EditLabModal
				open={editModalOpen}
				onClose={() => setEditModalOpen(false)}
				onSubmit={handleEditLab}
				lab={lab}
			/>

			<EditPPEModal
				open={editPPEOpen}
				onClose={handleEditPPEClose}
				onSave={handleSavePPE}
				currentPPEs={selectedPPEs}
				allPPEs={allPPEs}
			/>

			<DeleteConfirmDialog
				open={deleteDialogOpen}
				onClose={() => setDeleteDialogOpen(false)}
				onConfirm={() => deleteMutation.mutate()}
				title="Delete Lab"
				message={`Are you sure you want to delete ${lab.labName}? This action cannot be undone.`}
			/>

			<DeleteConfirmDialog
				open={archiveDialogOpen}
				onClose={() => setArchiveDialogOpen(false)}
				onConfirm={() => archiveMutation.mutate()}
				title="Archive Lab"
				message={`Are you sure you want to archive ${lab.labName}? This will end all current sessions.`}
				submitLabel="Archive"
				submitColor="var(--color-warning)"
			/>
		</Box>
	);
};

export default LabPage;
