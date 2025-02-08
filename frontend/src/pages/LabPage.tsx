import React, { useState } from "react";
import { Box, Typography, Tabs, Tab, Chip } from "@mui/material";
import { useLocation, useNavigate } from "react-router-dom";
import { useUser } from "../contexts/UserContext";
import ErrorAlert from "../components/ErrorAlertProps";
import ScheduleView from "../components/ScheduleView";
import PeopleTab from "../components/PeopleTab";
import { useLabUsers } from "../hooks/useLabsQuery";

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
	const lab = location.state?.lab;
	const { user } = useUser();
	const [tabValue, setTabValue] = useState(0);
	const [openSnackbar, setOpenSnackbar] = useState(false);
	const [alertMessage, setAlertMessage] = useState("");
	const [severity, setSeverity] = useState<"error" | "success">("error");
	const {
		instructors,
		students,
		isLoading: usersLoading,
	} = useLabUsers(lab.id);

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
			setAlertMessage("Instructor removed successfully");
			setSeverity("success");
			setOpenSnackbar(true);
		} catch (err) {
			setAlertMessage("Failed to remove instructor");
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

	const handleRemoveStudent = async (user: User) => {
		try {
			await labService.removeStudent(lab.id, user.id);
			setAlertMessage("Student removed successfully");
			setSeverity("success");
			setOpenSnackbar(true);
		} catch (err) {
			setAlertMessage("Failed to remove student");
			setSeverity("error");
			setOpenSnackbar(true);
		}
	};

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
					</Box>
					<Box sx={{ display: "flex", gap: 1, alignItems: "start" }}>
						<Chip
							size="small"
							color={lab.started ? "success" : "default"}
							label={lab.started ? "In Progress" : "Not Started"}
						/>
						{lab.endLab && (
							<Chip size="small" color="error" label="Ended" />
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
				Sessions
			</TabPanel>
			<TabPanel value={tabValue} index={1}>
				<PeopleTab
					instructors={instructors}
					students={students}
					isLoading={usersLoading}
					canManage={canManageLab}
					onRemoveInstructor={handleRemoveInstructor}
					onRemoveStudent={handleRemoveStudent}
				/>
			</TabPanel>
			<TabPanel value={tabValue} index={2}>
				Analytics
			</TabPanel>
			<TabPanel value={tabValue} index={3}>
				Announcements
			</TabPanel>

			<ErrorAlert
				open={openSnackbar}
				message={alertMessage}
				severity={severity}
				onClose={() => setOpenSnackbar(false)}
			/>
		</Box>
	);
};

export default LabPage;
