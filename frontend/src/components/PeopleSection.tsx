import React, { useMemo, useState } from "react";
import {
	Box,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
	Typography,
	Tooltip,
	Chip,
	Collapse,
	IconButton,
	LinearProgress,
	Avatar,
} from "@mui/material";
import KeyboardArrowDownIcon from "@mui/icons-material/KeyboardArrowDown";
import KeyboardArrowUpIcon from "@mui/icons-material/KeyboardArrowUp";
import { imageUrl } from "../config/config";
import { ObjectResult } from "../types/sessions";

interface PeopleSectionProps {
	results: ObjectResult[];
}

const PeopleSection: React.FC<PeopleSectionProps> = ({ results }) => {
	const sortedResults = useMemo(() => {
		return [...results].sort(
			(a, b) => b.attendance_percentage - a.attendance_percentage
		);
	}, [results]);

	const getComplianceColor = (value: number) => {
		if (value >= 80) return "var(--color-success)";
		if (value >= 60) return "var(--color-warning)";
		return "var(--color-danger)";
	};

	const calculateAverageCompliance = (ppe_compliance: {
		[key: string]: number;
	}) => {
		if (!ppe_compliance) return 0;
		const values = Object.values(ppe_compliance);
		if (values.length === 0) return 0;
		return values.reduce((a, b) => a + b, 0) / values.length;
	};

	const [expandedRows, setExpandedRows] = useState<{
		[key: number]: boolean;
	}>({});

	const toggleRow = (userId: number) => {
		setExpandedRows((prev) => ({
			...prev,
			[userId]: !prev[userId],
		}));
	};

	return (
		<TableContainer
			component={Paper}
			sx={{
				bgcolor: "var(--color-card)",
				color: "var(--color-text)",
			}}
		>
			<Table>
				<TableHead>
					<TableRow>
						<TableCell sx={{ width: "50px" }} />{" "}
						{/* For expand button */}
						<TableCell sx={{ color: "var(--color-text)" }}>
							Student
						</TableCell>
						<TableCell sx={{ color: "var(--color-text)" }}>
							Attendance
						</TableCell>
						<TableCell sx={{ color: "var(--color-text)" }}>
							PPE Items
						</TableCell>
						<TableCell sx={{ color: "var(--color-text)" }}>
							Overall Compliance
						</TableCell>
					</TableRow>
				</TableHead>
				<TableBody>
					{sortedResults.map((result) => {
						const averageCompliance = calculateAverageCompliance(
							result.ppE_compliance
						);

						return (
							<React.Fragment key={result.id}>
								<TableRow
									sx={{
										cursor: "pointer",
										"&:hover": {
											bgcolor: "var(--color-card-hover)",
										},
										"& > *": { borderBottom: "unset" },
									}}
									onClick={() => toggleRow(result.id)}
								>
									<TableCell>
										<IconButton
											size="small"
											sx={{ color: "var(--color-text)" }}
										>
											{expandedRows[result.id] ? (
												<KeyboardArrowUpIcon />
											) : (
												<KeyboardArrowDownIcon />
											)}
										</IconButton>
									</TableCell>
									<TableCell
										sx={{ color: "var(--color-text)" }}
									>
										<Box
											sx={{
												display: "flex",
												alignItems: "center",
												gap: 2,
											}}
										>
											<Avatar
												src={`${imageUrl}/${result.user.image}`}
												alt={result.user.name}
												sx={{
													width: 40,
													height: 40,
													"&:hover": {
														transform: "scale(1.1)",
														transition:
															"transform 0.2s",
													},
												}}
											/>

											<Typography>
												{result.user?.name || "Unknown"}
											</Typography>
										</Box>
									</TableCell>
									<TableCell>
										<Chip
											label={`${
												result.attendance_percentage ||
												0
											}%`}
											size="small"
											sx={{
												backgroundColor:
													getComplianceColor(
														result.attendance_percentage ||
															0
													),
												color: "var(--color-text-dark)",
											}}
										/>
									</TableCell>
									<TableCell>
										<Box
											sx={{
												display: "flex",
												gap: 1,
												flexWrap: "wrap",
											}}
										>
											{result.ppE_compliance &&
												Object.entries(
													result.ppE_compliance
												).map(([item, value]) => (
													<Tooltip
														key={item}
														title={`${item}: ${value}%`}
													>
														<Chip
															label={`${item
																.charAt(0)
																.toUpperCase()}`}
															size="small"
															// color={getComplianceColor(
															// 	value
															// )}
															sx={{
																bgcolor:
																	getComplianceColor(
																		value
																	),
																color: "var(--color-text-dark)",
															}}
														/>
													</Tooltip>
												))}
										</Box>
									</TableCell>
									<TableCell>
										<Chip
											label={`${Math.round(
												averageCompliance
											)}%`}
											size="small"
											sx={{
												backgroundColor:
													getComplianceColor(
														averageCompliance
													),
												color: "var(--color-text-dark)",
											}}
										/>
									</TableCell>
								</TableRow>
								<TableRow>
									<TableCell
										style={{
											paddingBottom: 0,
											paddingTop: 0,
										}}
										colSpan={6}
									>
										<Collapse
											in={expandedRows[result.id]}
											timeout="auto"
											unmountOnExit
										>
											<Box sx={{ margin: 2 }}>
												<Typography
													variant="h6"
													gutterBottom
													sx={{
														color: "var(--color-text)",
													}}
												>
													PPE Compliance Details
												</Typography>
												<Box sx={{ mt: 2 }}>
													{result.ppE_compliance &&
														Object.entries(
															result.ppE_compliance
														).map(
															([item, value]) => (
																<Box
																	key={item}
																	sx={{
																		mb: 2,
																		color: "var(--color-text)",
																	}}
																>
																	<Box
																		sx={{
																			display:
																				"flex",
																			justifyContent:
																				"space-between",
																			mb: 1,
																		}}
																	>
																		<Typography>
																			{item
																				.charAt(
																					0
																				)
																				.toUpperCase() +
																				item.slice(
																					1
																				)}
																		</Typography>
																		<Typography>
																			{
																				value
																			}
																			%
																		</Typography>
																	</Box>
																	<LinearProgress
																		variant="determinate"
																		value={
																			value
																		}
																		sx={{
																			height: 8,
																			borderRadius: 5,
																			bgcolor:
																				"var(--color-card-hover)",
																			"& .MuiLinearProgress-bar":
																				{
																					bgcolor:
																						getComplianceColor(
																							value
																						),

																					borderRadius: 5,
																				},
																		}}
																	/>
																</Box>
															)
														)}
												</Box>
											</Box>
										</Collapse>
									</TableCell>
								</TableRow>
							</React.Fragment>
						);
					})}
				</TableBody>
			</Table>
		</TableContainer>
	);
};

export default PeopleSection;
