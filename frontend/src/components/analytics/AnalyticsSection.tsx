import React from "react";
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

interface AnalyticsSectionProps {
	results: any[];
	totalPPECompliance: Record<string, number>;
	ppE_compliance_bytime: Record<string, number[]>;
	total_ppe_compliance_bytime: number[];
}

const AnalyticsSection: React.FC<AnalyticsSectionProps> = ({
	results,
	totalPPECompliance,
	ppE_compliance_bytime,
	total_ppe_compliance_bytime,
}) => {
	// Get PPE types dynamically
	const ppeTypes = Object.keys(totalPPECompliance);

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
								<CartesianGrid strokeDasharray="3 3" />
								<XAxis dataKey="" />
								<YAxis />
								<Tooltip />
								<Legend />
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
									/>
								))}
								<Line
									type="monotone"
									dataKey="total"
									stroke="#ffc658"
									name="Total"
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
								<PolarRadiusAxis />
								<Radar
									name="Attendance"
									dataKey="attendance_percentage"
									fill="#8884d8"
									fillOpacity={0.6}
								/>
								<Radar
									name="Goggles"
									dataKey="ppE_compliance.goggles"
									fill="#82ca9d"
									fillOpacity={0.6}
								/>
								<Radar
									name="Helmet"
									dataKey="ppE_compliance.helmet"
									fill="#ffc658"
									fillOpacity={0.6}
								/>
								<Legend />
							</RadarChart>
						</ResponsiveContainer>
					</Paper>
				</Grid>
			</Grid>
		</Box>
	);
};

export default AnalyticsSection;
