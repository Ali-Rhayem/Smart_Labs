import React from "react";
import {
	Box,
	Grid,
	Paper,
	Skeleton,
	Typography,
} from "@mui/material";
import { useLabAnalytics } from "../../hooks/useLabsQuery";
import AnalyticsLab from "../AnalyticsLab";

interface AnalyticsTabProps {
	labId: number;
}

const AnalyticsTab: React.FC<AnalyticsTabProps> = ({ labId }) => {
	const { data, isLoading, error } = useLabAnalytics(labId);

	const renderLoadingSkeleton = () => (
		<Box sx={{ p: 3 }}>
			<Grid container spacing={3}>
				{/* Gauge Skeletons */}
				{[1, 2].map((gauge) => (
					<Grid item xs={12} md={6} key={`gauge-${gauge}`}>
						<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
							<Skeleton
								variant="text"
								width={200}
								height={32}
								sx={{
									mb: 2,
									bgcolor: "var(--color-card-hover)",
								}}
							/>
							<Box
								sx={{ width: 200, height: 200, margin: "auto" }}
							>
								<Skeleton
									variant="circular"
									width={200}
									height={200}
									sx={{ bgcolor: "var(--color-card-hover)" }}
								/>
							</Box>
						</Paper>
					</Grid>
				))}

				{/* Chart Skeletons */}
				{[1, 2].map((chart) => (
					<Grid item xs={12} md={6} key={`chart-${chart}`}>
						<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
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
							<Box sx={{ mt: 2, display: "flex", gap: 2 }}>
								{[1, 2, 3].map((legend) => (
									<Skeleton
										key={`legend-${legend}`}
										variant="rectangular"
										width={60}
										height={24}
										sx={{
											bgcolor: "var(--color-card-hover)",
											borderRadius: 1,
										}}
									/>
								))}
							</Box>
						</Paper>
					</Grid>
				))}

				{/* Full Width Chart Skeletons */}
				{[1, 2, 3, 4].map((fullChart) => (
					<Grid item xs={12} key={`full-chart-${fullChart}`}>
						<Paper sx={{ p: 3, bgcolor: "var(--color-card)" }}>
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
								height={400}
								sx={{
									bgcolor: "var(--color-card-hover)",
									borderRadius: 1,
								}}
							/>
							<Box
								sx={{
									mt: 2,
									display: "flex",
									gap: 2,
									flexWrap: "wrap",
								}}
							>
								{[1, 2, 3, 4, 5].map((legend) => (
									<Skeleton
										key={`legend-${legend}`}
										variant="rectangular"
										width={80}
										height={24}
										sx={{
											bgcolor: "var(--color-card-hover)",
											borderRadius: 1,
										}}
									/>
								))}
							</Box>
						</Paper>
					</Grid>
				))}
			</Grid>
		</Box>
	);

	if (isLoading) {
		return renderLoadingSkeleton();
	}

	if (error) {
		return (
			<Box p={3}>
				<Typography color="error">
					Failed to load analytics data
				</Typography>
			</Box>
		);
	}

	if (!data) {
		return (
			<Box p={3}>
				<Typography color="var(--color-text-secondary)">
					No analytics data available
				</Typography>
			</Box>
		);
	}

	return (
		<AnalyticsLab
			total_attendance={data.total_attendance}
			total_ppe_compliance={data.total_ppe_compliance}
			ppe_compliance={data.ppe_compliance}
			people={data.people}
			total_attendance_bytime={data.total_attendance_bytime}
			total_ppe_compliance_bytime={data.total_ppe_compliance_bytime}
			ppe_compliance_bytime={data.ppe_compliance_bytime}
			people_bytime={data.people_bytime}
		/>
	);
};

export default AnalyticsTab;
