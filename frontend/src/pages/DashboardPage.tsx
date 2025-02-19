import React from "react";
import {
	Box,
	Typography,
	Grid,
	Card,
	CircularProgress,
	Accordion,
	AccordionSummary,
	AccordionDetails,
} from "@mui/material";
import { useUser } from "../contexts/UserContext";
import { useDashboard } from "../hooks/useDashboard";
import {
	LineChart,
	Line,
	XAxis,
	YAxis,
	CartesianGrid,
	Tooltip,
	Legend,
	ResponsiveContainer,
	PieChart,
	Pie,
	Cell,
	BarChart,
	Bar,
} from "recharts";
import SchoolIcon from "@mui/icons-material/School";
import GroupsIcon from "@mui/icons-material/Groups";
import AssignmentTurnedInIcon from "@mui/icons-material/AssignmentTurnedIn";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import { Lab, PPEComplianceData } from "../types/dashboard";
import LabOverview from "../components/LabOverview";

const DashboardPage: React.FC = () => {
	const { user: authUser } = useUser();
	const { data: dashboardData, isLoading } = useDashboard();
	const isStudent = authUser?.role === "student";
	console.log(dashboardData);
	// Move useMemo before any conditional returns
	const validLabs = React.useMemo(
		() =>
			(dashboardData?.labs || []).filter(
				(lab: Lab) => Object.keys(lab).length > 0
			),
		[dashboardData]
	);

	const ppeComplianceData = React.useMemo(() => {
		if (!validLabs.length) return [];

		const ppeTypes = validLabs.reduce((types: string[], lab: Lab) => {
			Object.keys(lab.ppe_compliance || {}).forEach((type) => {
				if (!types.includes(type)) types.push(type);
			});
			return types;
		}, []);

		return ppeTypes.map((type) => {
			const average =
				validLabs.reduce(
					(sum, lab) => sum + (lab.ppe_compliance?.[type] || 0),
					0
				) / validLabs.length;

			return {
				name: type.charAt(0).toUpperCase() + type.slice(1),
				value: Math.round(average),
			};
		});
	}, [validLabs]);

	const trendsData = React.useMemo(
		() =>
			validLabs
				.map((lab: Lab) => ({
					date: lab.xaxis?.[0] ?? "",
					attendance: lab.total_attendance,
					ppe_compliance: lab.total_ppe_compliance,
				}))
				.reverse(),
		[validLabs]
	);

	if (isLoading || !dashboardData) {
		return (
			<Box sx={{ display: "flex", justifyContent: "center", p: 3 }}>
				<CircularProgress />
			</Box>
		);
	}

	return (
		<Box sx={{ p: 3 }}>
			<Typography
				variant="h4"
				gutterBottom
				sx={{ color: "var(--color-text)" }}
			>
				Dashboard Overview
			</Typography>

			{/* Overview Cards */}
			<Grid container spacing={3} sx={{ mb: 3 }}>
				<Grid item xs={12} md={4}>
					<Card
						sx={{
							p: 3,
							bgcolor: "var(--color-card)",
							display: "flex",
							alignItems: "center",
							gap: 2,
						}}
					>
						<SchoolIcon
							sx={{ fontSize: 40, color: "var(--color-primary)" }}
						/>
						<Box>
							<Typography
								variant="h4"
								sx={{ color: "var(--color-text)" }}
							>
								{dashboardData.total_students}
							</Typography>
							<Typography
								sx={{ color: "var(--color-text-secondary)" }}
							>
								{isStudent
									? "Total Sessions"
									: "Total Students"}
							</Typography>
						</Box>
					</Card>
				</Grid>

				<Grid item xs={12} md={4}>
					<Card
						sx={{
							p: 3,
							bgcolor: "var(--color-card)",
							display: "flex",
							alignItems: "center",
							gap: 2,
						}}
					>
						<GroupsIcon
							sx={{ fontSize: 40, color: "var(--color-primary)" }}
						/>
						<Box>
							<Typography
								variant="h4"
								sx={{ color: "var(--color-text)" }}
							>
								{dashboardData.avg_attandance}%
							</Typography>
							<Typography
								sx={{ color: "var(--color-text-secondary)" }}
							>
								Average Attendance
							</Typography>
						</Box>
					</Card>
				</Grid>

				<Grid item xs={12} md={4}>
					<Card
						sx={{
							p: 3,
							bgcolor: "var(--color-card)",
							display: "flex",
							alignItems: "center",
							gap: 2,
						}}
					>
						<AssignmentTurnedInIcon
							sx={{ fontSize: 40, color: "var(--color-primary)" }}
						/>
						<Box>
							<Typography
								variant="h4"
								sx={{ color: "var(--color-text)" }}
							>
								{dashboardData.ppe_compliance}%
							</Typography>
							<Typography
								sx={{ color: "var(--color-text-secondary)" }}
							>
								PPE Compliance
							</Typography>
						</Box>
					</Card>
				</Grid>
			</Grid>

			{/* Trends Chart */}
			<Grid container spacing={3} sx={{ mb: 3 }}>
				<Grid item xs={12}>
					<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Performance Trends
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<LineChart data={trendsData}>
								<CartesianGrid strokeDasharray="3 3" />
								<XAxis dataKey="date" />
								<YAxis />
								<Tooltip
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-border)",
										color: "var(--color-text)",
									}}
								/>
								<Legend />
								<Line
									type="monotone"
									dataKey="attendance"
									stroke="#8884d8"
									name="Attendance %"
								/>
								<Line
									type="monotone"
									dataKey="ppe_compliance"
									stroke="#82ca9d"
									name="PPE Compliance %"
								/>
							</LineChart>
						</ResponsiveContainer>
					</Card>
				</Grid>
			</Grid>

			{/* PPE Compliance by Type */}
			<Grid container spacing={3} sx={{ mb: 3 }}>
				<Grid item xs={12} md={isStudent ? 12 : 6}>
					<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							PPE Compliance by Type
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<PieChart>
								<Pie
									data={ppeComplianceData}
									cx="50%"
									cy="50%"
									innerRadius={60}
									outerRadius={80}
									fill="#8884d8"
									dataKey="value"
									label={({ name, value }) =>
										`${name}: ${value}%`
									}
								>
									{ppeComplianceData.map((entry, index) => (
										<Cell
											key={index}
											fill={
												index === 0
													? "#8884d8"
													: "#82ca9d"
											}
										/>
									))}
								</Pie>
								<Tooltip
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-border)",
										color: "var(--color-text)",
									}}
								/>
								<Legend />
							</PieChart>
						</ResponsiveContainer>
					</Card>
				</Grid>

				{!isStudent && (
					<Grid item xs={12} md={6}>
						<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
							<Typography
								variant="h6"
								sx={{ mb: 2, color: "var(--color-text)" }}
							>
								Top Performers
							</Typography>
							{(validLabs[0]?.people ?? [])
								.sort(
									(a, b) =>
										b.attendance_percentage -
										a.attendance_percentage
								)
								.slice(0, 3)
								.map((student, index) => (
									<Box
										key={student.id}
										sx={{
											display: "flex",
											alignItems: "center",
											mb: 2,
											p: 2,
											bgcolor: "var(--color-card-hover)",
											borderRadius: 1,
										}}
									>
										<Typography
											sx={{
												color: "var(--color-primary)",
												mr: 2,
												fontWeight: "bold",
											}}
										>
											#{index + 1}
										</Typography>
										<Box sx={{ flexGrow: 1 }}>
											<Typography
												sx={{
													color: "var(--color-text)",
												}}
											>
												{student.name}
											</Typography>
											<Typography
												sx={{
													color: "var(--color-text-secondary)",
												}}
											>
												Attendance:{" "}
												{student.attendance_percentage}%
											</Typography>
										</Box>
									</Box>
								))}
						</Card>
					</Grid>
				)}
			</Grid>

			{/* Attendance by Day */}
			<Grid container spacing={3} sx={{ mb: 3 }}>
				<Grid item xs={12}>
					<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Attendance by Day
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<BarChart data={trendsData}>
								<CartesianGrid strokeDasharray="3 3" />
								<XAxis dataKey="date" />
								<YAxis />
								<Tooltip
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-border)",
										color: "var(--color-text)",
									}}
								/>
								<Legend />
								<Bar
									dataKey="attendance"
									fill="#8884d8"
									name="Attendance %"
								/>
							</BarChart>
						</ResponsiveContainer>
					</Card>
				</Grid>
			</Grid>

			{/* Lab Sessions Overview */}
			<Box sx={{ mt: 3 }}>
				<Typography
					variant="h6"
					sx={{ mb: 2, color: "var(--color-text)" }}
				>
					Labs Overview
				</Typography>
				{Object.entries(
					validLabs.reduce(
						(acc, lab) => {
							const labId = lab.lab_id ?? "unknown";
							if (!acc[labId]) {
								acc[labId] = {
									id: labId,
									name: lab.lab_name || "",
									sessions: [],
									sessionCount: lab.xaxis?.length ?? 0,
									totalAttendance: 0,
									totalPPE: 0,
								};
							}
							acc[labId].sessions.push(lab);
							acc[labId].totalAttendance +=
								lab.total_attendance ?? 0;
							acc[labId].totalPPE +=
								lab.total_ppe_compliance ?? 0;
							return acc;
						},
						{} as Record<
							string,
							{
								id: string | number;
								name: string;
								sessions: (typeof validLabs)[0][];
								sessionCount: number;
								totalAttendance: number;
								totalPPE: number;
							}
						>
					)
				).map(([labId, labData]) => (
					<Accordion
						key={labId}
						sx={{
							bgcolor: "var(--color-card)",
							mb: 2,
							"&:before": { display: "none" },
						}}
					>
						<AccordionSummary
							expandIcon={
								<ExpandMoreIcon
									sx={{ color: "var(--color-text)" }}
								/>
							}
						>
							<Box
								sx={{
									display: "flex",
									alignItems: "center",
									gap: 2,
									width: "100%",
								}}
							>
								<Typography
									variant="h6"
									sx={{
										color: "var(--color-text)",
										flexGrow: 1,
									}}
								>
									{labData.name}
								</Typography>
								<Box sx={{ display: "flex", gap: 3 }}>
									<Box sx={{ textAlign: "center" }}>
										<Typography
											variant="body2"
											sx={{
												color: "var(--color-text-secondary)",
											}}
										>
											Sessions
										</Typography>
										<Typography
											sx={{ color: "var(--color-text)" }}
										>
											{labData.sessionCount}
										</Typography>
									</Box>
									<Box sx={{ textAlign: "center" }}>
										<Typography
											variant="body2"
											sx={{
												color: "var(--color-text-secondary)",
											}}
										>
											Avg. Attendance
										</Typography>
										<Typography
											sx={{
												color:
													labData.totalAttendance /
														labData.sessions
															.length >=
													70
														? "success.main"
														: labData.totalAttendance /
																labData.sessions
																	.length >=
														  50
														? "warning.main"
														: "error.main",
											}}
										>
											{Math.round(
												labData.totalAttendance /
													labData.sessions.length
											)}
											%
										</Typography>
									</Box>
									<Box sx={{ textAlign: "center" }}>
										<Typography
											variant="body2"
											sx={{
												color: "var(--color-text-secondary)",
											}}
										>
											Avg. PPE
										</Typography>
										<Typography
											sx={{
												color:
													labData.totalPPE /
														labData.sessions
															.length >=
													70
														? "success.main"
														: labData.totalPPE /
																labData.sessions
																	.length >=
														  50
														? "warning.main"
														: "error.main",
											}}
										>
											{Math.round(
												labData.totalPPE /
													labData.sessions.length
											)}
											%
										</Typography>
									</Box>
								</Box>
							</Box>
						</AccordionSummary>
						<AccordionDetails>
							{labData.sessions.map((session, index) => (
								<LabOverview
									key={index}
									lab={session}
									index={index}
								/>
							))}
						</AccordionDetails>
					</Accordion>
				))}
			</Box>
		</Box>
	);
};

export default DashboardPage;
