import React, { useState } from "react";
import { Box, Grid, Paper, Typography } from "@mui/material";
import {
	LineChart,
	Line,
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
} from "recharts";
import "react-circular-progressbar/dist/styles.css";

// Add colors array at top of file
const COLORS = ["#8884d8", "#82ca9d", "#ffc658", "#ff8042"];

interface AnalyticsSessionProps {
	results: any[];
	totalPPECompliance: Record<string, number>;
	ppE_compliance_bytime: Record<string, number[]>;
	total_ppe_compliance_bytime: number[];
}

const AnalyticsSession: React.FC<AnalyticsSessionProps> = ({
	results,
	totalPPECompliance,
	ppE_compliance_bytime,
	total_ppe_compliance_bytime,
}) => {
	// Get PPE types dynamically
	const ppeTypes = Object.keys(totalPPECompliance);

	// Add state at the top of component
	const [visibleLines, setVisibleLines] = useState<Record<string, boolean>>(
		() => {
			const initial: Record<string, boolean> = {};
			ppeTypes.forEach((type) => (initial[type] = true));
			initial["total"] = true;
			return initial;
		}
	);

	// Add state at top of component
	const [visibleRadars, setVisibleRadars] = useState<Record<string, boolean>>(
		() => {
			const initial: Record<string, boolean> = { 
				attendance_percentage: true 
			};
			ppeTypes.forEach(type => initial[`ppE_compliance.${type}`] = true);
			return initial;
		}
	);

	// Add toggle handler
	const handleLegendClick = (dataKey: string) => {
		setVisibleLines((prev) => ({
			...prev,
			[dataKey]: !prev[dataKey],
		}));
	};

	// Add handler function
	const handleRadarLegendClick = (e: any) => {
		const dataKey = e.dataKey;
		setVisibleRadars(prev => ({
			...prev,
			[dataKey]: !prev[dataKey]
		}));
	};

	// Get PPE types from first result's PPE compliance
	const ppeTypesFromResults = Object.keys(results[0]?.ppE_compliance || {});

	// Prepare time series data
	const timeSeriesData = total_ppe_compliance_bytime.map((total, index) => {
		const dataPoint: Record<string, any> = {
			time: `Time ${index + 1}`,
			total,
		};

		// Add each PPE type's data
		ppeTypes.forEach((ppeType) => {
			dataPoint[ppeType] = ppE_compliance_bytime[ppeType][index];
		});

		return dataPoint;
	});

	return (
		<Box sx={{ p: 3 }}>
			<Grid container spacing={3}>
				{/* PPE Compliance Over Time */}
				<Grid item xs={12}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							PPE Compliance Trend
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<LineChart data={timeSeriesData}>
								<CartesianGrid
									vertical={false}
									strokeDasharray="3 3"
								/>
								<XAxis dataKey="" />
								<YAxis domain={[0, 100]} />
								<Tooltip />
								<Legend
									onClick={(e) =>
										handleLegendClick(e.dataKey as string)
									}
									wrapperStyle={{ cursor: "pointer" }}
								/>
								{ppeTypes.map((ppeType, index) => (
									<Line
										key={ppeType}
										type="monotone"
										dataKey={ppeType}
										stroke={`hsl(${
											index * (360 / ppeTypes.length)
										}, 70%, 50%)`}
										name={
											ppeType.charAt(0).toUpperCase() +
											ppeType.slice(1)
										}
										hide={!visibleLines[ppeType]}
									/>
								))}
								<Line
									type="monotone"
									dataKey="total"
									stroke="#ffc658"
									name="Total"
									hide={!visibleLines["total"]}
								/>
							</LineChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>

				{/* Student Performance Comparison */}
				<Grid item xs={12}>
					<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
						<Typography
							variant="h6"
							sx={{ mb: 2, color: "var(--color-text)" }}
						>
							Student Performance
						</Typography>
						<ResponsiveContainer width="100%" height={300}>
							<RadarChart data={results}>
								<PolarGrid />
								<PolarAngleAxis dataKey="name" />
								<PolarRadiusAxis domain={[0, 100]} />
								<Radar
									name="Attendance"
									dataKey="attendance_percentage"
									stroke={COLORS[0]}
									fill={COLORS[0]}
									fillOpacity={0.6}
									hide={!visibleRadars['attendance_percentage']}
								/>
								{ppeTypes.map((ppeType, index) => (
									<Radar
										key={ppeType}
										name={`${
											ppeType.charAt(0).toUpperCase() +
											ppeType.slice(1)
										} Compliance`}
										dataKey={`ppE_compliance.${ppeType}`}
										stroke={COLORS[index + 1]}
										fill={COLORS[index + 1]}
										fillOpacity={0.6}
										hide={!visibleRadars[`ppE_compliance.${ppeType}`]}
									/>
								))}
								<Legend 
									onClick={handleRadarLegendClick}
									wrapperStyle={{ cursor: 'pointer' }}
								/>
							</RadarChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>
			</Grid>
		</Box>
	);
};

export default AnalyticsSession;
