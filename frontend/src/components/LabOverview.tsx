import React from "react";
import {
	Box,
	Card,
	Grid,
	Typography,
	Accordion,
	AccordionSummary,
	AccordionDetails,
	LinearProgress,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
} from "@mui/material";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import { Lab } from "../types/dashboard";

interface LabOverviewProps {
	lab: Lab;
	index: number;
}

const LabOverview: React.FC<LabOverviewProps> = ({ lab, index }) => {
	return (
		<Box>
			<Typography variant="h6" sx={{ mb: 2, color: "var(--color-text)" }}>
				{lab.lab_name}
			</Typography>

			{lab.xaxis?.map((sessionDate, sessionIndex) => (
				<Accordion
					key={sessionIndex}
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
						<Box sx={{ width: "100%" }}>
							<Typography sx={{ color: "var(--color-text)" }}>
								Session {sessionIndex + 1} - {sessionDate}
							</Typography>
							<Box sx={{ display: "flex", gap: 4, mt: 1 }}>
								<Typography
									sx={{
										color: "var(--color-text-secondary)",
									}}
								>
									Attendance:{" "}
									{
										lab.total_attendance_bytime?.[
											sessionIndex
										]
									}
									%
								</Typography>
								<Typography
									sx={{
										color: "var(--color-text-secondary)",
									}}
								>
									PPE:{" "}
									{
										lab.total_ppe_compliance_bytime?.[
											sessionIndex
										]
									}
									%
								</Typography>
								<Typography
									sx={{
										color: "var(--color-text-secondary)",
									}}
								>
									Students: {lab.people_bytime?.length || 0}
								</Typography>
							</Box>
						</Box>
					</AccordionSummary>

					<AccordionDetails>
						<Grid container spacing={3}>
							{/* PPE Compliance for this session */}
							<Grid item xs={12} md={6}>
								<Card
									sx={{
										p: 2,
										bgcolor: "var(--color-background)",
									}}
								>
									<Typography
										variant="h6"
										sx={{
											mb: 2,
											color: "var(--color-text)",
										}}
									>
										PPE Compliance
									</Typography>
									{Object.entries(
										lab.ppe_compliance_bytime || {}
									).map(([type, values]) => (
										<Box key={type} sx={{ mb: 2 }}>
											<Box
												sx={{
													display: "flex",
													justifyContent:
														"space-between",
													mb: 0.5,
												}}
											>
												<Typography
													sx={{
														color: "var(--color-text)",
													}}
												>
													{type}
												</Typography>
												<Typography
													sx={{
														color: "var(--color-text)",
													}}
												>
													{values[sessionIndex]}%
												</Typography>
											</Box>
											<LinearProgress
												variant="determinate"
												value={values[sessionIndex]}
												sx={{
													height: 8,
													borderRadius: 4,
													bgcolor:
														"var(--color-card)",
													"& .MuiLinearProgress-bar":
														{
															bgcolor:
																values[
																	sessionIndex
																] >= 70
																	? "success.main"
																	: values[
																			sessionIndex
																	  ] >= 50
																	? "warning.main"
																	: "error.main",
														},
												}}
											/>
										</Box>
									))}
								</Card>
							</Grid>

							{/* Students Performance for this session */}
							<Grid item xs={12} md={6}>
								<Card
									sx={{
										p: 2,
										bgcolor: "var(--color-background)",
									}}
								>
									<Typography
										variant="h6"
										sx={{
											mb: 2,
											color: "var(--color-text)",
										}}
									>
										Student Performance
									</Typography>
									<TableContainer>
										<Table size="small">
											<TableHead>
												<TableRow>
													<TableCell
														sx={{
															color: "var(--color-text)",
														}}
													>
														Student
													</TableCell>
													<TableCell
														sx={{
															color: "var(--color-text)",
														}}
													>
														Attendance
													</TableCell>
													{Object.keys(
														lab.ppe_compliance_bytime ||
															{}
													).map((type) => (
														<TableCell
															key={type}
															sx={{
																color: "var(--color-text)",
															}}
														>
															{type}
														</TableCell>
													))}
												</TableRow>
											</TableHead>
											<TableBody>
												{lab.people_bytime?.map(
													(student) => (
														<TableRow
															key={student.id}
														>
															<TableCell
																sx={{
																	color: "var(--color-text)",
																}}
															>
																{student.name}
															</TableCell>
															<TableCell
																sx={{
																	color: "var(--color-text)",
																}}
															>
																{
																	student
																		.attendance_percentage[
																		sessionIndex
																	]
																}
																%
															</TableCell>
															{Object.entries(
																	student.ppe_compliance ||
																		{}
																).map(
																	([
																		type,
																		values,
																	]) => (
																		<TableCell
																			key={
																				type
																			}
																			sx={{
																				color: "var(--color-text)",
																			}}
																		>
																			{Array.isArray(
																				values
																			)
																				? values[
																						sessionIndex
																				  ]
																				: 0}
																			%
																		</TableCell>
																	)
																)}
														</TableRow>
													)
												)}
											</TableBody>
										</Table>
									</TableContainer>
								</Card>
							</Grid>
						</Grid>
					</AccordionDetails>
				</Accordion>
			))}
		</Box>
	);
};

export default LabOverview;
