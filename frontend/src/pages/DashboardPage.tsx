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
	Skeleton,
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
import { Lab } from "../types/dashboard";
import LabOverview from "../components/LabOverview";

const renderLoadingSkeleton = () => (
	<Box sx={{ p: 3 }}>
		{/* Header */}
		<Skeleton
			variant="text"
			width={300}
			height={40}
			sx={{ mb: 3, bgcolor: "var(--color-card-hover)" }}
		/>

		{/* Overview Cards */}
		<Grid container spacing={3} sx={{ mb: 3 }}>
			{[1, 2, 3].map((card) => (
				<Grid item xs={12} md={4} key={`card-${card}`}>
					<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
							<Skeleton
								variant="circular"
								width={40}
								height={40}
								sx={{ bgcolor: "var(--color-card-hover)" }}
							/>
							<Box sx={{ flex: 1 }}>
								<Skeleton
									variant="text"
									width="60%"
									height={32}
									sx={{ bgcolor: "var(--color-card-hover)" }}
								/>
								<Skeleton
									variant="text"
									width="40%"
									height={24}
									sx={{ bgcolor: "var(--color-card-hover)" }}
								/>
							</Box>
						</Box>
					</Card>
				</Grid>
			))}
		</Grid>

		{/* Charts */}
		<Grid container spacing={3} sx={{ mb: 3 }}>
			<Grid item xs={12}>
				<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
					<Skeleton
						variant="text"
						width={200}
						height={32}
						sx={{ mb: 2, bgcolor: "var(--color-card-hover)" }}
					/>
					<Skeleton
						variant="rectangular"
						height={300}
						sx={{ bgcolor: "var(--color-card-hover)", borderRadius: 1 }}
					/>
				</Card>
			</Grid>
		</Grid>

		{/* PPE and Performance Grid */}
		<Grid container spacing={3}>
			<Grid item xs={12} md={6}>
				<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
					<Skeleton
						variant="text"
						width={200}
						height={32}
						sx={{ mb: 2, bgcolor: "var(--color-card-hover)" }}
					/>
					<Box
						sx={{
							height: 300,
							display: "flex",
							alignItems: "center",
							justifyContent: "center",
						}}
					>
						<Skeleton
							variant="circular"
							width={250}
							height={250}
							sx={{ bgcolor: "var(--color-card-hover)" }}
						/>
					</Box>
				</Card>
			</Grid>
			<Grid item xs={12} md={6}>
				<Card sx={{ p: 3, bgcolor: "var(--color-card)" }}>
					<Skeleton
						variant="text"
						width={200}
						height={32}
						sx={{ mb: 2, bgcolor: "var(--color-card-hover)" }}
					/>
					<Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
						{[1, 2, 3, 4].map((item) => (
							<Box
								key={item}
								sx={{ display: "flex", alignItems: "center", gap: 2 }}
							>
								<Skeleton
									variant="circular"
									width={32}
									height={32}
									sx={{ bgcolor: "var(--color-card-hover)" }}
								/>
								<Box sx={{ flex: 1 }}>
									<Skeleton
										variant="text"
										width="60%"
										height={24}
										sx={{ bgcolor: "var(--color-card-hover)" }}
									/>
									<Skeleton
										variant="text"
										width="40%"
										height={20}
										sx={{ bgcolor: "var(--color-card-hover)" }}
									/>
								</Box>
							</Box>
						))}
					</Box>
				</Card>
			</Grid>
		</Grid>
	</Box>
);

const DashboardPage: React.FC = () => {
	const { user: authUser } = useUser();
	const { data: dashboardData, isLoading } = useDashboard();
	const isStudent = authUser?.role === "student";

	const chart_colors = [
		"#8884d8",
		"#82ca9d",
		"#ffc658",
		"#ff7f50",
		"#ff6b81",
		"#a05195",
		"#d45087",
		"#f95d6a",
		"#ff7c43",
		"#ffa600",
		"#003f5c",
		"#2f4b7c",
	];
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

	const trendsData = React.useMemo(() => {
		// Group by month and calculate averages
		const monthlyData = validLabs.reduce((acc, lab) => {
			// Loop through all dates in xaxis
			lab.xaxis?.forEach((date, index) => {
				const monthDate = new Date(date);
				const monthKey = `${monthDate.getFullYear()}-${
					monthDate.getMonth() + 1
				}`;

				if (!acc[monthKey]) {
					acc[monthKey] = {
						count: 0,
						totalAttendance: 0,
						totalPPE: 0,
					};
				}

				acc[monthKey].count += 1;
				acc[monthKey].totalAttendance +=
					lab.total_attendance_bytime?.[index] ?? 0;
				acc[monthKey].totalPPE +=
					lab.total_ppe_compliance_bytime?.[index] ?? 0;
			});

			return acc;
		}, {} as Record<string, { count: number; totalAttendance: number; totalPPE: number }>);

		// Convert to array and calculate averages
		return Object.entries(monthlyData)
			.map(([monthKey, data]) => {
				const [year, month] = monthKey.split("-");
				return {
					date: new Date(
						parseInt(year),
						parseInt(month) - 1
					).toLocaleDateString("en-US", {
						year: "numeric",
						month: "short",
					}),
					attendance: Math.round(data.totalAttendance / data.count),
					ppe_compliance: Math.round(data.totalPPE / data.count),
				};
			})
			.sort(
				(a, b) =>
					new Date(a.date).getTime() - new Date(b.date).getTime()
			);
	}, [validLabs]);

	if (isLoading || !dashboardData) {
		return renderLoadingSkeleton();
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
									{ppeComplianceData.map((_entry, index) => (
										<Cell
											key={index}
											fill={
												chart_colors[
													index % chart_colors.length
												]
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
						<Card
							sx={{
								p: 3,
								bgcolor: "var(--color-card)",
								height: "100%",
							}}
						>
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
								<Bar
									dataKey="ppe_compliance"
									fill="#82ca9d"
									name="PPE %"
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
								<LabOverview key={index} lab={session} />
							))}
						</AccordionDetails>
					</Accordion>
				))}
			</Box>
		</Box>
	);
};

export default DashboardPage;
