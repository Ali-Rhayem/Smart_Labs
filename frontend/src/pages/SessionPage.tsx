import React, { useState } from "react";
import {
	Box,
	Typography,
	Tabs,
	Tab,
	CircularProgress,
	Tooltip,
	Grid,
	Card,
	Skeleton,
} from "@mui/material";
import { useLocation } from "react-router-dom";
import PeopleIcon from "@mui/icons-material/People";
import AnalyticsIcon from "@mui/icons-material/Analytics";
import { format } from "date-fns";
import { Session } from "../types/sessions";
import PeopleSection from "../components/PeopleSection";
import AnalyticsSession from "../components/analytics/AnalyticsSession";

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

const renderLoadingSkeleton = () => (
	<Box sx={{ p: 3 }}>
		{/* Tab Navigation */}
		<Box sx={{ borderBottom: 1, borderColor: "var(--color-border)" }}>
			<Skeleton
				variant="rectangular"
				width={300}
				height={48}
				sx={{ bgcolor: "var(--color-card-hover)", borderRadius: 1 }}
			/>
		</Box>

		{/* Content Area */}
		<Box sx={{ mt: 3 }}>
			{/* People Tab Skeleton */}
			<Grid container spacing={2}>
				{[1, 2, 3, 4, 5, 6].map((person) => (
					<Grid item xs={12} sm={6} md={4} key={person}>
						<Card sx={{ p: 2, bgcolor: "var(--color-card)" }}>
							<Box sx={{ display: "flex", gap: 2, mb: 2 }}>
								<Skeleton
									variant="circular"
									width={40}
									height={40}
									sx={{ bgcolor: "var(--color-card-hover)" }}
								/>
								<Box sx={{ flex: 1 }}>
									<Skeleton
										variant="text"
										width="70%"
										height={24}
										sx={{
											mb: 0.5,
											bgcolor: "var(--color-card-hover)",
										}}
									/>
									<Skeleton
										variant="text"
										width="40%"
										height={20}
										sx={{ bgcolor: "var(--color-card-hover)" }}
									/>
								</Box>
							</Box>
							<Box
								sx={{
									display: "flex",
									justifyContent: "space-between",
									mb: 2,
								}}
							>
								<Skeleton
									variant="rectangular"
									width={100}
									height={24}
									sx={{
										bgcolor: "var(--color-card-hover)",
										borderRadius: 1,
									}}
								/>
								<Skeleton
									variant="rectangular"
									width={100}
									height={24}
									sx={{
										bgcolor: "var(--color-card-hover)",
										borderRadius: 1,
									}}
								/>
							</Box>
						</Card>
					</Grid>
				))}
			</Grid>

			{/* Analytics Tab Skeleton */}
			<Grid container spacing={3} sx={{ mt: 2 }}>
				{/* Charts */}
				{[1, 2].map((chart) => (
					<Grid item xs={12} md={6} key={chart}>
						<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
							<Skeleton
								variant="text"
								width={200}
								height={32}
								sx={{
									mb: 2,
									bgcolor: "var(--color-card-hover)",
								}}
							/>
							<Skeleton
								variant="rectangular"
								height={300}
								sx={{
									bgcolor: "var(--color-card-hover)",
									borderRadius: 1,
								}}
							/>
						</Card>
					</Grid>
				))}

				{/* Full Width Stats */}
				<Grid item xs={12}>
					<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Box
							sx={{
								display: "flex",
								justifyContent: "space-between",
								mb: 3,
							}}
						>
							{[1, 2, 3].map((stat) => (
								<Box key={stat}>
									<Skeleton
										variant="text"
										width={120}
										height={24}
										sx={{
											mb: 1,
											bgcolor: "var(--color-card-hover)",
										}}
									/>
									<Skeleton
										variant="rectangular"
										width={100}
										height={40}
										sx={{
											bgcolor: "var(--color-card-hover)",
											borderRadius: 1,
										}}
									/>
								</Box>
							))}
						</Box>
					</Card>
				</Grid>
			</Grid>
		</Box>
	</Box>
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

	if (!session) return renderLoadingSkeleton();

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

				<Box sx={{ mt: 3, display: "flex", gap: 2, flexWrap: "wrap" }}>
					<ProgressDisplay
						value={session.totalAttendance ?? 0}
						label="Attendance"
						color={getStatusColor(session.totalAttendance ?? 0)}
					/>
					<ProgressDisplay
						value={Math.round(
							calculateAverageCompliance(
								session.totalPPECompliance ?? {}
							)
						)}
						label="Overall PPE"
						color={getStatusColor(
							calculateAverageCompliance(
								session.totalPPECompliance ?? {}
							)
						)}
					/>
					{session.totalPPECompliance &&
						Object.entries(session.totalPPECompliance).map(
							([item, value]) => (
								<ProgressDisplay
									key={item}
									value={Math.round(value)}
									label={
										item.charAt(0).toUpperCase() +
										item.slice(1)
									}
									color={getStatusColor(value)}
								/>
							)
						)}
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
				<PeopleSection results={session.result} />
			</TabPanel>

			<TabPanel value={tabValue} index={1}>
				<AnalyticsSession
					results={session.result}
					totalPPECompliance={session.totalPPECompliance ?? {}}
					ppE_compliance_bytime={session.ppE_compliance_bytime ?? {}}
					total_ppe_compliance_bytime={
						session.total_ppe_compliance_bytime ?? []
					}
				/>
			</TabPanel>
		</Box>
	);
};

export default SessionPage;
