import { Card, CardContent, Typography, Grid } from "@mui/material";
import { styled } from "@mui/system";

// Styled components for better control over styles
const StyledCard = styled(Card)(() => ({
	backgroundColor: "#424242",
	color: "white",
	borderRadius: "8px",
	boxShadow: "0 4px 12px rgba(0, 0, 0, 0.2)",
	"&:hover": {
		transform: "translateY(-10px)",
		boxShadow: "0 10px 20px rgba(0, 0, 0, 0.3)",
		transition: "transform 0.3s, box-shadow 0.3s",
	},
}));

const StyledTypography = styled(Typography)(({ theme }) => ({
	marginBottom: theme.spacing(1),
	fontWeight: 600,
	color: "#f5f5f5",
}));

const LabsPage = () => {
	const labs = [
		{
			id: 1,
			name: "Physics Lab",
			description: "Experiment with physics concepts.",
		},
		{
			id: 2,
			name: "Chemistry Lab",
			description: "Conduct chemical experiments.",
		},
		{
			id: 3,
			name: "Biology Lab",
			description: "Explore biological sciences.",
		},
	];

	return (
		<div
			style={{
				padding: "30px",
				backgroundColor: "#303030",
				minHeight: "100vh",
			}}
		>
			<Typography variant="h3" gutterBottom color="primary">
				Labs
			</Typography>
			<Grid container spacing={4}>
				{labs.map((lab) => (
					<Grid item xs={12} sm={6} md={4} key={lab.id}>
						<StyledCard>
							<CardContent>
								<StyledTypography variant="h5">
									{lab.name}
								</StyledTypography>
								<Typography
									variant="body1"
									color="text.secondary"
								>
									{lab.description}
								</Typography>
							</CardContent>
						</StyledCard>
					</Grid>
				))}
			</Grid>
		</div>
	);
};

export default LabsPage;
