import React, { useState } from "react";
import {
	Box,
	Typography,
	Tabs,
	Tab,
	Chip,
	Paper,
	CircularProgress,
	Tooltip,
} from "@mui/material";
import { useLocation } from "react-router-dom";
import PeopleIcon from "@mui/icons-material/People";
import AnalyticsIcon from "@mui/icons-material/Analytics";
import { format } from "date-fns";
import { Session } from "../types/sessions";

interface TabPanelProps {
	children?: React.ReactNode;
	index: number;
	value: number;
}

const TabPanel: React.FC<TabPanelProps> = ({ children, value, index }) => (
	<Box hidden={value !== index} sx={{ p: 3 }}>
		{value === index && children}
	</Box>
);

const ProgressDisplay = ({
	value,
	label,
	color,
}: {
	value: number;
	label: string;
	color: string;
}) => (
	<Tooltip title={`${label}: ${value}%`}>
		<Box
			sx={{
				position: "relative",
				display: "inline-flex",
				flexDirection: "column",
				alignItems: "center",
				p: 2,
			}}
		>
			<Box sx={{ position: "relative" }}>
				<CircularProgress
					variant="determinate"
					value={value}
					size={100}
					thickness={4}
					sx={{
						color,
						"& .MuiCircularProgress-circle": {
							strokeLinecap: "round",
							transition: "all 0.8s ease-in-out",
						},
					}}
				/>
				<Box
					sx={{
						position: "absolute",
						top: "50%",
						left: "50%",
						transform: "translate(-50%, -50%)",
						textAlign: "center",
					}}
				>
					<Typography variant="h4" sx={{ fontWeight: "bold", color }}>
						{Math.round(value)}%
					</Typography>
				</Box>
			</Box>
			<Typography
				variant="subtitle1"
				sx={{
					mt: 1,
					color: "var(--color-text-secondary)",
				}}
			>
				{label}
			</Typography>
		</Box>
	</Tooltip>
);

const SessionPage: React.FC = () => {
	const location = useLocation();
	const session = location.state?.session as Session;
	const [tabValue, setTabValue] = useState(0);

	const getStatusColor = (percentage: number) => {
		if (percentage >= 80) return "#4caf50";
		if (percentage >= 60) return "#ff9800";
		return "#f44336";
	};

	const calculateAverageCompliance = (compliance: {
		[key: string]: number;
	}) => {
		if (!compliance) return 0;
		const values = Object.values(compliance);
		if (values.length === 0) return 0;
		return values.reduce((a, b) => a + b, 0) / values.length;
	};

	if (!session) return null;

	return (
		<Box
			sx={{
				minHeight: "100%",
				bgcolor: "var(--color-background-secondary)",
				color: "var(--color-text)",
			}}
		>
			{/* Header */}
			<Box sx={{ p: 3, borderBottom: 1, borderColor: "divider" }}>
				<Typography variant="h4" gutterBottom>
					Lab Session
				</Typography>
				<Typography variant="h6" color="var(--color-text-secondary)">
					{format(new Date(session.date), "EEEE, MMMM d, yyyy")}
				</Typography>

				<Box sx={{ mt: 3, display: "flex", gap: 2 }}>
					<ProgressDisplay
						value={session.totalAttendance}
						label="Attendance"
						color={getStatusColor(session.totalAttendance)}
					/>
					<ProgressDisplay
						value={Math.round(
							calculateAverageCompliance(
								session.totalPPECompliance
							)
						)}
						label="PPE Compliance"
						color={getStatusColor(
							calculateAverageCompliance(
								session.totalPPECompliance
							)
						)}
					/>
				</Box>
			</Box>

			{/* Tabs */}
			<Tabs
				value={tabValue}
				onChange={(_, newValue) => setTabValue(newValue)}
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
				<Tab icon={<PeopleIcon />} label="PEOPLE" />
				<Tab icon={<AnalyticsIcon />} label="ANALYTICS" />
			</Tabs>

			<TabPanel value={tabValue} index={0}>
				{/* People Tab Content - Will create separately */}
			</TabPanel>

			<TabPanel value={tabValue} index={1}>
				{/* Analytics Tab Content - Will create separately */}
			</TabPanel>
		</Box>
	);
};

export default SessionPage;
