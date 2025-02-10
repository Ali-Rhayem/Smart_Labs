import React from "react";
import {
	Box,
	Grid,
	Card,
	CardContent,
	Typography,
	Button,
	CircularProgress,
} from "@mui/material";
import VisibilityIcon from "@mui/icons-material/Visibility";
import { useLabSessions } from "../hooks/useSessions";

import { isWithinInterval, parseISO } from "date-fns";

import DateRangeFilter from "./DateRangeFilter";

const SessionsTab: React.FC<{ labId: number }> = ({ labId }) => {
	const { data: sessions, isLoading } = useLabSessions(labId);
	const [startDate, setStartDate] = React.useState<Date | null>(null);
	const [endDate, setEndDate] = React.useState<Date | null>(null);
	const [dateError, setDateError] = React.useState<string>("");

	const handleStartDateChange = (date: Date | null) => {
		setStartDate(date);
		if (endDate && date && date > endDate) {
			setEndDate(null);
			setDateError("End date must be after start date");
		} else {
			setDateError("");
		}
	};

	const handleEndDateChange = (date: Date | null) => {
		if (startDate && date && date < startDate) {
			setDateError("End date must be after start date");
			return;
		}
		setEndDate(date);
		setDateError("");
	};

	const handleClear = () => {
		setStartDate(null);
		setEndDate(null);
		setDateError("");
	};

	const filteredSessions = React.useMemo(() => {
		if (!sessions) return [];
		let filtered = [...sessions];

		if (startDate && endDate) {
			filtered = filtered.filter((session) => {
				const sessionDate = parseISO(session.date);
				return isWithinInterval(sessionDate, {
					start: startDate,
					end: endDate,
				});
			});
		}

		return filtered.sort(
			(a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()
		);
	}, [sessions, startDate, endDate]);

	const getComplianceColor = (percentage: number) => {
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

	return (
		<Box sx={{ flexGrow: 1 }}>
			<Box sx={{ mb: 2 }}>
				<DateRangeFilter
					startDate={startDate}
					endDate={endDate}
					onStartDateChange={handleStartDateChange}
					onEndDateChange={handleEndDateChange}
					onClear={handleClear}
					dateError={dateError}
				/>
			</Box>

			{isLoading ? (
				<Box sx={{ display: "flex", justifyContent: "center", p: 3 }}>
					<CircularProgress />
				</Box>
			) : (
				<Grid container spacing={3}>
					{filteredSessions.map((session) => (
						<Grid item xs={12} sm={6} md={4} key={session.id}>
							<Card
								sx={{
									height: "100%",
									background: "var(--color-card)",
									borderRadius: 2,
									boxShadow: "0 4px 20px rgba(0,0,0,0.1)",
									transition: "all 0.3s ease",
									"&:hover": {
										transform: "translateY(-8px)",
										backgroundColor:
											"var(--color-card-hover)",
										boxShadow:
											"0 8px 30px rgba(0,0,0,0.12)",
									},
								}}
							>
								<CardContent sx={{ p: 3 }}>
									<Typography
										variant="h6"
										sx={{
											mb: 3,
											color: "var(--color-text)",
											fontWeight: 600,
										}}
									>
										{new Date(
											session.date
										).toLocaleDateString("en-US", {
											weekday: "long",
											year: "numeric",
											month: "long",
											day: "numeric",
										})}
									</Typography>

									<Box
										sx={{
											display: "flex",
											justifyContent: "space-around",
											mb: 3,
											color: "var(--color-text)",
										}}
									>
										{/* Attendance Progress */}
										<Box
											sx={{
												position: "relative",
												display: "inline-flex",
												flexDirection: "column",
												alignItems: "center",
											}}
										>
											<Box sx={{ position: "relative" }}>
												<CircularProgress
													variant="determinate"
													value={
														session.totalAttendance
													}
													size={80}
													thickness={4}
													sx={{
														color: getComplianceColor(
															session.totalAttendance
														),
														"& .MuiCircularProgress-circle":
															{
																strokeLinecap:
																	"round",
															},
													}}
												/>
												<Box
													sx={{
														position: "absolute",
														top: "50%",
														left: "50%",
														transform:
															"translate(-50%, -50%)",
														textAlign: "center",
													}}
												>
													<Typography
														variant="h6"
														sx={{
															fontWeight: "bold",
														}}
													>
														{`${session.totalAttendance}%`}
													</Typography>
												</Box>
											</Box>
											<Typography
												variant="body2"
												sx={{
													mt: 1,
													color: "var(--color-text-secondary)",
												}}
											>
												Attendance
											</Typography>
										</Box>

										{/* PPE Compliance Progress */}
										<Box
											sx={{
												position: "relative",
												display: "inline-flex",
												flexDirection: "column",
												alignItems: "center",
											}}
										>
											<Box sx={{ position: "relative" }}>
												<CircularProgress
													variant="determinate"
													value={calculateAverageCompliance(
														session.totalPPECompliance
													)}
													size={80}
													thickness={4}
													sx={{
														color: getComplianceColor(
															calculateAverageCompliance(
																session.totalPPECompliance
															)
														),
														"& .MuiCircularProgress-circle":
															{
																strokeLinecap:
																	"round",
															},
													}}
												/>
												<Box
													sx={{
														position: "absolute",
														top: "50%",
														left: "50%",
														transform:
															"translate(-50%, -50%)",
														textAlign: "center",
													}}
												>
													<Typography
														variant="h6"
														sx={{
															fontWeight: "bold",
														}}
													>
														{`${Math.round(
															calculateAverageCompliance(
																session.totalPPECompliance
															)
														)}%`}
													</Typography>
												</Box>
											</Box>
											<Typography
												variant="body2"
												sx={{
													mt: 1,
													color: "var(--color-text-secondary)",
												}}
											>
												PPE Compliance
											</Typography>
										</Box>
									</Box>

									<Button
										variant="contained"
										startIcon={<VisibilityIcon />}
										fullWidth
										sx={{
											mt: 2,
											bgcolor: "var(--color-primary)",
											color: "var(--color-text-button)",
											borderRadius: 2,
											py: 1,
											textTransform: "none",
											"&:hover": {
												bgcolor: "var(--color-primary)",
												opacity: 0.9,
												transform: "scale(1.02)",
											},
										}}
									>
										View Details
									</Button>
								</CardContent>
							</Card>
						</Grid>
					))}
				</Grid>
			)}
		</Box>
	);
};

export default SessionsTab;
