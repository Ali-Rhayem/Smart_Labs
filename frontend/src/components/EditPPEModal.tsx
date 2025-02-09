import React, { useState, useEffect } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
	Grid,
	Paper,
	Typography,
} from "@mui/material";
import { PPE } from "../types/ppe";
import SafetyIcon from "@mui/icons-material/VerifiedUser";

interface EditPPEModalProps {
	open: boolean;
	onClose: () => void;
	onSave: (selectedPPEs: number[]) => void;
	currentPPEs: number[];
	allPPEs: PPE[];
	onExited?: () => void;
}

const EditPPEModal: React.FC<EditPPEModalProps> = ({
	open,
	onClose,
	onSave,
	currentPPEs,
	allPPEs,
	onExited,
}) => {
	const [selected, setSelected] = useState<number[]>([]);

	useEffect(() => {
		setSelected(currentPPEs);
	}, [currentPPEs, open]);

	const handleClose = () => {
		setSelected(currentPPEs);
		onClose();
	};

	const handleToggle = (ppe: PPE) => {
		const currentIndex = selected.indexOf(ppe.id);
		const newChecked = [...selected];

		if (currentIndex === -1) {
			newChecked.push(ppe.id);
		} else {
			newChecked.splice(currentIndex, 1);
		}

		setSelected(newChecked);
	};

	return (
		<Dialog
			open={open}
			onClose={handleClose}
			TransitionProps={{ onExited }}
			maxWidth="md"
			PaperProps={{
				sx: {
					bgcolor: "var(--color-background)",
					color: "var(--color-text)",
				},
			}}
		>
			<DialogTitle>Edit Required PPE</DialogTitle>
			<DialogContent>
				<Grid container spacing={1.5} sx={{ mt: 0.5 }}>
					{allPPEs.map((ppe) => {
						const isChecked = selected.includes(ppe.id);

						return (
							<Grid item xs="auto" key={ppe.id}>
								<Paper
									elevation={0}
									onClick={() => handleToggle(ppe)}
									sx={{
										p: 1.5,
										height: 40,
										display: "flex",
										alignItems: "center",
										justifyContent: "flex-start",
										gap: 1.5,
										cursor: "pointer",
										bgcolor: isChecked
											? "var(--color-primary-light)"
											: "var(--color-card)",
										borderRadius: 8,
										border: "1px solid",
										borderColor: isChecked
											? "var(--color-primary)"
											: "var(--color-border)",
										transition: "all 0.2s ease-in-out",
										whiteSpace: "nowrap",
										"&:hover": {
											bgcolor: isChecked
												? "var(--color-primary-light)"
												: "action.hover",
											transform: "translateY(-2px)",
										},
									}}
								>
									<SafetyIcon
										sx={{
											fontSize: "1.2rem",
											color: isChecked
												? "var(--color-primary)"
												: "var(--color-text-secondary)",
										}}
									/>
									<Typography
										variant="body2"
										sx={{
											color: isChecked
												? "var(--color-primary)"
												: "var(--color-text)",
											fontWeight: isChecked ? 500 : 400,
										}}
									>
										{ppe.name}
									</Typography>
								</Paper>
							</Grid>
						);
					})}
				</Grid>
			</DialogContent>
			<DialogActions
				sx={{ p: 2.5, borderTop: 1, borderColor: "divider" }}
			>
				<Button onClick={handleClose}>Cancel</Button>
				<Button variant="contained" onClick={() => onSave(selected)}>
					Save Changes
				</Button>
			</DialogActions>
		</Dialog>
	);
};

export default EditPPEModal;
