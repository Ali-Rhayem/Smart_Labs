import React from "react";
import { Box, CircularProgress, Typography } from "@mui/material";
import { useLabAnalytics } from "../../hooks/useLabsQuery";
import AnalyticsLab from "../AnalyticsLab";

interface AnalyticsTabProps {
	labId: number;
}

const AnalyticsTab: React.FC<AnalyticsTabProps> = ({ labId }) => {
	const { data, isLoading, error } = useLabAnalytics(labId);

	if (isLoading) {
		return (
			<Box
				display="flex"
				justifyContent="center"
				alignItems="center"
				minHeight="400px"
			>
				<CircularProgress />
			</Box>
		);
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
