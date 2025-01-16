import { Card, CardContent, Typography, Grid } from "@mui/material";
import { styled } from "@mui/system";

// Styled components for consistent and attractive styles
const StyledCard = styled(Card)(() => ({
	backgroundColor: "#1C1C1C",
	color: "#FFFF00",
	borderRadius: "12px",
	boxShadow: "0 6px 15px rgba(0, 0, 0, 0.3)",
	transition: "transform 0.3s, box-shadow 0.3s",
	display: "flex",
	flexDirection: "column", // Ensures children stack vertically
	justifyContent: "space-between", // Balances content and aligns footer
	height: "100%", // Ensures consistent height for all cards
	"&:hover": {
		transform: "translateY(-8px)",
		boxShadow: "0 12px 24px rgba(0, 0, 0, 0.5)",
	},
}));

const StyledTypography = styled(Typography)(() => ({
	marginBottom: "8px",
	fontWeight: 600,
	color: "#FFEB00",
}));

const LabsPage = () => {
	const labs = [
		{
			id: 1,
			name: "Physics Lab",
			description: "Experiment with physics concepts.",
			labcode: "PHY101",
			date_time: [
				{ dayOfWeek: "Monday", startTime: "10:00", endTime: "12:00" },
				{
					dayOfWeek: "Wednesday",
					startTime: "14:00",
					endTime: "16:00",
				},
			],
		},
		{
			id: 2,
			name: "Chemistry Lab",
			description: "Conduct chemical experiments.",
			labcode: "CHEM201",
			date_time: [
				{ dayOfWeek: "Tuesday", startTime: "09:00", endTime: "11:00" },
				{ dayOfWeek: "Thursday", startTime: "13:00", endTime: "15:00" },
			],
		},
		{
			id: 3,
			name: "Biology Lab",
			description: "Explore biological sciences.",
			labcode: "BIO301",
			date_time: [
				{ dayOfWeek: "Friday", startTime: "11:00", endTime: "13:00" },
			],
		},
		{
			id: 4,
			name: "Advanced Biology Lab",
			description: "Explore advanced biological concepts.",
			labcode: "BIO401",
			date_time: [
				{ dayOfWeek: "Monday", startTime: "09:00", endTime: "11:00" },
			],
		},
	];

	return (
		<div
			style={{
				padding: "30px",
				backgroundColor: "#121212",
				minHeight: "100vh",
			}}
		>
			<Typography
				variant="h3"
				gutterBottom
				style={{
					color: "#FFFF00",
					textAlign: "center",
					fontWeight: "bold",
				}}
			>
				Labs
			</Typography>
			<Grid container spacing={4} style={{ display: "flex", flexWrap: "wrap", alignItems: "stretch" }}>
				{labs.map((lab) => (
					<Grid item xs={12} sm={6} md={4} key={lab.id}>
						<StyledCard>
							<CardContent style={{ flexGrow: 1 }}>
								<StyledTypography variant="h5">
									{lab.name}
								</StyledTypography>
								<Typography
									variant="body1"
									style={{
										color: "#E0E0E0",
										marginBottom: "8px",
									}}
								>
									{lab.description}
								</Typography>
								<Typography
									variant="body2"
									style={{
										color: "#FFFF00",
										marginTop: "12px",
										marginBottom: "8px",
									}}
								>
									<strong>Code:</strong> {lab.labcode}
								</Typography>
								<Typography
									variant="body2"
									style={{
										color: "#FFEB00",
										marginTop: "8px",
										marginBottom: "8px",
									}}
								>
									<strong>Schedule:</strong>
								</Typography>
								<ul
									style={{
										paddingLeft: "20px",
										color: "#E0E0E0",
									}}
								>
									{lab.date_time.map((dt, index) => (
										<li key={index}>
											{dt.dayOfWeek}: {dt.startTime} -{" "}
											{dt.endTime}
										</li>
									))}
								</ul>
							</CardContent>
						</StyledCard>
					</Grid>
				))}
			</Grid>
		</div>
	);
};

export default LabsPage;
