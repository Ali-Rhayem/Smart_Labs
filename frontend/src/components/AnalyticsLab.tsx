import React, { useState } from "react";
import { Box, Grid, Paper, Typography } from "@mui/material";
import {
	BarChart,
	Bar,
	LineChart,
	Line,
	PieChart,
	Pie,
	RadarChart,
	Radar,
	PolarGrid,
	PolarAngleAxis,
	PolarRadiusAxis,
	XAxis,
	YAxis,
	CartesianGrid,
	Tooltip,
	Legend,
	ResponsiveContainer,
	Cell,
} from "recharts";
import { CircularProgressbar, buildStyles } from "react-circular-progressbar";

interface LabAnalytics {
	total_attendance: number;
	total_attendance_bytime: number[];
	total_ppe_compliance: number;
	total_ppe_compliance_bytime: number[];
	ppe_compliance: Record<string, number>;
	ppe_compliance_bytime: Record<string, number[]>;
	people: Array<{
		name: string;
		attendance_percentage: number;
		ppE_compliance: Record<string, number>;
	}>;
	people_bytime: Array<{
		name: string;
		attendance_percentage: number[];
	}>;
}

interface AnalyticsLabProps extends LabAnalytics {}

const AnalyticsLab: React.FC<AnalyticsLabProps> = ({
	total_attendance,
	total_attendance_bytime,
	total_ppe_compliance,
	total_ppe_compliance_bytime,
	ppe_compliance,
	ppe_compliance_bytime,
	people,
	people_bytime,
}) => {
	const COLORS = ["#0088FE", "#00C49F", "#FFBB28", "#FF8042"];
	const ppeTypes = Object.keys(people[0]?.ppE_compliance || {});

	// Add state for visibility
	const [visibleRadars, setVisibleRadars] = useState<Record<string, boolean>>(
		() => {
			const initial: Record<string, boolean> = {
				attendance_percentage: true,
			};
			Object.keys(ppe_compliance).forEach((type) => {
				initial[`ppE_compliance.${type}`] = true;
			});
			return initial;
		}
	);

	// Add legend click handler
	const handleLegendClick = (e: any) => {
		setVisibleRadars((prev) => ({
			...prev,
			[e.dataKey]: !prev[e.dataKey],
		}));
	};

	// Add state
	const [visibleLines, setVisibleLines] = useState<Record<string, boolean>>(
		() => {
			const initial: Record<string, boolean> = {};
			people_bytime.forEach((person) => {
				initial[person.name] = true;
			});
			return initial;
		}
	);

	// Add handler
	const handleLineLegendClick = (e: any) => {
		setVisibleLines((prev) => ({
			...prev,
			[e.value]: !prev[e.value],
		}));
	};

	// Add state at top of component
	const [visiblePPETypes, setVisiblePPETypes] = useState<
		Record<string, boolean>
	>(() => {
		return Object.keys(ppe_compliance_bytime).reduce(
			(acc, key) => ({
				...acc,
				[key]: true,
			}),
			{}
		);
	});

	// Add handler before return
	const handlePPELegendClick = (e: any) => {
		if (!e.payload) return;
		const dataKey = e.payload.dataKey;
		setVisiblePPETypes((prev) => ({
			...prev,
			[dataKey]: !prev[dataKey],
		}));
	};

	// Prepare data for attendance distribution
	const attendanceGroups = {
		"High (>75%)": 0,
		"Medium (50-75%)": 0,
		"Low (<50%)": 0,
	};

	people.forEach((person) => {
		if (person.attendance_percentage > 75)
			attendanceGroups["High (>75%)"]++;
		else if (person.attendance_percentage > 50)
			attendanceGroups["Medium (50-75%)"]++;
		else attendanceGroups["Low (<50%)"]++;
	});

	const attendanceData = Object.entries(attendanceGroups).map(
		([name, value]) => ({
			name,
			value,
		})
	);

	// Prepare time series data
	const timeSeriesData = total_ppe_compliance_bytime.map((value, index) => ({
		time: `Time ${index + 1}`,
		attendance: total_attendance_bytime[index],
		ppe_compliance: value,
		...Object.keys(ppe_compliance_bytime).reduce(
			(acc, key) => ({
				...acc,
				[key]: ppe_compliance_bytime[key][index],
			}),
			{}
		),
	}));

	// First, prepare the time series data for each student
	const studentTimeData = people_bytime
		.map((person) => {
			return person.attendance_percentage.map((value, timeIndex) => ({
				name: person.name,
				time: `Time ${timeIndex + 1}`,
				value: value,
			}));
		})
		.flat();

	return (
		<Box sx={{ p: 3 }}>
			<Grid container spacing={3}>
				{/* Total Attendance Gauge */}
				<Grid item xs={12} md={6}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Total Attendance
						</Typography>
						<Box sx={{ width: 200, height: 200, margin: "auto" }}>
							<CircularProgressbar
								value={total_attendance}
								text={`${total_attendance}%`}
								styles={buildStyles({
									pathColor: `var(--color-primary)`,
									textColor: "var(--color-text)",
									trailColor: "var(--color-card)",
								})}
							/>
						</Box>
					</Paper>
				</Grid>

				{/* Total PPE Compliance Gauge */}
				<Grid item xs={12} md={6}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Total PPE Compliance
						</Typography>
						<Box sx={{ width: 200, height: 200, margin: "auto" }}>
							<CircularProgressbar
								value={total_ppe_compliance}
								text={`${total_ppe_compliance}%`}
								styles={buildStyles({
									pathColor: `var(--color-success)`,
									textColor: "var(--color-text)",
									trailColor: "var(--color-card)",
								})}
							/>
						</Box>
					</Paper>
				</Grid>

				{/* PPE Compliance Overview */}
				<Grid item xs={12} md={6}>
					<Paper
						sx={{
							p: 3,
							bgcolor: "var(--color-card)",
						}}
					>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							PPE Compliance
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<BarChart data={[ppe_compliance]}>
								<CartesianGrid strokeDasharray="3 3" />
								<XAxis dataKey="name" />
								<YAxis
									domain={[0, 100]}
									tickFormatter={(value) => `${value}%`}
									label={{
										value: "Percentage",
										angle: -90,
										position: "insideLeft",
										style: { fill: "var(--color-text)" },
									}}
								/>
								<Tooltip
									formatter={(
										value: number,
										name: string
									) => [`${value}%`, `${name}`]}
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-card)",
										color: "var(--color-text)",
										boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
									}}
									wrapperStyle={{ outline: "none" }}
									cursor={{ fill: "transparent" }}
								/>
								<Legend />
								{Object.keys(ppe_compliance).map(
									(ppeType, index) => (
										<Bar
											key={ppeType}
											dataKey={ppeType}
											name={
												ppeType
													.charAt(0)
													.toUpperCase() +
												ppeType.slice(1)
											}
											fill={COLORS[index % COLORS.length]}
											maxBarSize={60}
										/>
									)
								)}
							</BarChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>

				{/* Attendance Distribution */}
				<Grid item xs={12} md={6}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Attendance Distribution
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<PieChart>
								<Pie
									data={attendanceData}
									dataKey="value"
									nameKey="name"
									cx="50%"
									cy="50%"
									outerRadius={100}
									label
								>
									{attendanceData.map((_entry, index) => (
										<Cell
											key={`cell-${index}`}
											fill={COLORS[index % COLORS.length]}
										/>
									))}
								</Pie>
								<Tooltip
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-card)",
										color: "var(--color-text)",
										boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
									}}
									wrapperStyle={{ outline: "none" }}
									cursor={{ fill: "transparent" }}
								/>
								<Legend />
							</PieChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>

				{/* Student Performance Radar */}
				<Grid item xs={12}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Student Performance Overview
						</Typography>
						<ResponsiveContainer width="100%" height={400}>
							<RadarChart data={people}>
								<PolarGrid />
								<PolarAngleAxis dataKey="name" />
								<PolarRadiusAxis domain={[0, 100]} />
								<Radar
									name="Attendance"
									dataKey="attendance_percentage"
									stroke={COLORS[0]}
									fill={COLORS[0]}
									fillOpacity={0.6}
									hide={
										!visibleRadars["attendance_percentage"]
									}
								/>
								{ppeTypes.map((ppeType, index) => (
									<Radar
										key={ppeType}
										name={`${
											ppeType.charAt(0).toUpperCase() +
											ppeType.slice(1)
										}`}
										dataKey={`ppE_compliance.${ppeType}`}
										stroke={COLORS[index + 1]}
										fill={COLORS[index + 1]}
										fillOpacity={0.6}
										hide={
											!visibleRadars[
												`ppE_compliance.${ppeType}`
											]
										}
									/>
								))}
								<Legend
									onClick={handleLegendClick}
									wrapperStyle={{ cursor: "pointer" }}
								/>
								<Tooltip
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-card)",
										color: "var(--color-text)",
										boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
									}}
								/>
							</RadarChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>

				{/* Attendance & PPE Compliance Over Time */}
				<Grid item xs={12}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Trends Over Time
						</Typography>
						<ResponsiveContainer width="100%" height={400}>
							<LineChart data={timeSeriesData}>
								<CartesianGrid
									vertical={false}
									strokeDasharray="3 3"
								/>
								<XAxis dataKey="" />
								<YAxis domain={[0, 100]} />
								<Tooltip
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-card)",
										color: "var(--color-text)",
										boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
									}}
									wrapperStyle={{ outline: "none" }}
									cursor={{ fill: "transparent" }}
								/>
								<Legend />
								<Line
									type="monotone"
									dataKey="attendance"
									stroke="#8884d8"
									name="Attendance"
									strokeWidth={2}
								/>
								<Line
									type="monotone"
									dataKey="ppe_compliance"
									stroke="#82ca9d"
									name="PPE Compliance"
									strokeWidth={2}
								/>
							</LineChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>

				{/* Individual Student Progress */}
				<Grid item xs={12}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Individual Student Progress
						</Typography>
						<ResponsiveContainer width="100%" height={400}>
							<LineChart data={studentTimeData}>
								<CartesianGrid
									vertical={false}
									strokeDasharray="3 3"
								/>
								<XAxis
									dataKey="time"
									allowDuplicatedCategory={false}
								/>
								<YAxis
									domain={[0, 100]}
									tickFormatter={(value) => `${value}%`}
								/>
								<Tooltip
									formatter={(
										value: number,
										name: string
									) => [`${value}%`, `${name}`]}
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-card)",
										color: "var(--color-text)",
										boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
									}}
									wrapperStyle={{ outline: "none" }}
									cursor={{ fill: "transparent" }}
								/>
								<Legend
									onClick={handleLineLegendClick}
									wrapperStyle={{ cursor: "pointer" }}
								/>
								{people_bytime.map((person, index) => (
									<Line
										key={person.name}
										type="monotone"
										dataKey="value"
										data={studentTimeData.filter(
											(item) => item.name === person.name
										)}
										name={person.name}
										stroke={COLORS[index % COLORS.length]}
										strokeWidth={2}
										hide={!visibleLines[person.name]}
										dot={{
											fill: COLORS[index % COLORS.length],
											r: 4,
										}}
										activeDot={{
											r: 6,
											fill: COLORS[index % COLORS.length],
										}}
									/>
								))}
							</LineChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>

				{/* Detailed PPE Compliance Breakdown */}
				<Grid item xs={12}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							PPE Compliance by Type Over Time
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<LineChart data={timeSeriesData}>
								<CartesianGrid
									vertical={false}
									strokeDasharray="3 3"
								/>
								<XAxis dataKey="time" />
								<YAxis domain={[0, 100]} />
								<Tooltip
									contentStyle={{
										backgroundColor: "var(--color-card)",
										border: "1px solid var(--color-card)",
										color: "var(--color-text)",
										boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
									}}
									wrapperStyle={{ outline: "none" }}
									cursor={{ fill: "transparent" }}
								/>
								<Legend
									onClick={handlePPELegendClick}
									wrapperStyle={{ cursor: "pointer" }}
								/>
								{Object.keys(ppe_compliance_bytime).map(
									(key, index) => (
										<Line
											key={key}
											type="monotone"
											dataKey={key}
											name={
												key.charAt(0).toUpperCase() +
												key.slice(1)
											}
											stroke={
												COLORS[index % COLORS.length]
											}
											strokeWidth={2}
											hide={!visiblePPETypes[key]}
										/>
									)
								)}
							</LineChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>
			</Grid>
		</Box>
	);
};

export default AnalyticsLab;
