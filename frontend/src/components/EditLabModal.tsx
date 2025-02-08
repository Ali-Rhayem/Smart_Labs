import React from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
	TextField,
} from "@mui/material";
import { Lab } from "../types/lab";

interface EditLabModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (data: Partial<Lab>) => void;
	lab: Lab;
}

const EditLabModal: React.FC<EditLabModalProps> = ({
	open,
	onClose,
	onSubmit,
	lab,
}) => {
	const [formData, setFormData] = React.useState({
		labName: lab.labName,
		labCode: lab.labCode,
		description: lab.description,
		room: lab.room,
	});

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();
		onSubmit(formData);
	};

	return (
		<Dialog
			open={open}
			onClose={onClose}
			maxWidth="sm"
			fullWidth
			PaperProps={{
				sx: {
					bgcolor: "var(--color-background-secondary)",
					color: "var(--color-text)",
				},
			}}
		>
			<DialogTitle>Edit Lab</DialogTitle>
			<form onSubmit={handleSubmit}>
				<DialogContent>
					<TextField
						label="Lab Name"
						fullWidth
						margin="normal"
						value={formData.labName}
						onChange={(e) =>
							setFormData({
								...formData,
								labName: e.target.value,
							})
						}
						sx={{
							"& .MuiOutlinedInput-root": {
								"& fieldset": {
									borderColor: "var(--color-border)",
								},
								"&:hover fieldset": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused fieldset": {
									borderColor: "var(--color-primary)",
								},
								input: {
									color: "var(--color-text)",
								},
							},
							"& .MuiInputLabel-root": {
								color: "var(--color-text-secondary)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
							},
						}}
					/>
					<TextField
						label="Lab Code"
						fullWidth
						margin="normal"
						value={formData.labCode}
						onChange={(e) =>
							setFormData({
								...formData,
								labCode: e.target.value,
							})
						}
						sx={{
							"& .MuiOutlinedInput-root": {
								"& fieldset": {
									borderColor: "var(--color-border)",
								},
								"&:hover fieldset": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused fieldset": {
									borderColor: "var(--color-primary)",
								},
								input: {
									color: "var(--color-text)",
								},
							},
							"& .MuiInputLabel-root": {
								color: "var(--color-text-secondary)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
							},
						}}
					/>
					<TextField
						label="Description"
						fullWidth
						margin="normal"
						multiline
						rows={4}
						value={formData.description}
						onChange={(e) =>
							setFormData({
								...formData,
								description: e.target.value,
							})
						}
						sx={{
							"& .MuiOutlinedInput-root": {
								"& fieldset": {
									borderColor: "var(--color-border)",
								},
								"&:hover fieldset": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused fieldset": {
									borderColor: "var(--color-primary)",
								},
								textarea: {
									color: "var(--color-text)",
								},
							},
							"& .MuiInputLabel-root": {
								color: "var(--color-text-secondary)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
							},
						}}
					/>
					<TextField
						label="Room"
						fullWidth
						margin="normal"
						value={formData.room}
						onChange={(e) =>
							setFormData({ ...formData, room: e.target.value })
						}
						sx={{
							"& .MuiOutlinedInput-root": {
								"& fieldset": {
									borderColor: "var(--color-border)",
								},
								"&:hover fieldset": {
									borderColor: "var(--color-primary)",
								},
								"&.Mui-focused fieldset": {
									borderColor: "var(--color-primary)",
								},
								input: {
									color: "var(--color-text)",
								},
							},
							"& .MuiInputLabel-root": {
								color: "var(--color-text-secondary)",
								"&.Mui-focused": {
									color: "var(--color-primary)",
								},
							},
						}}
					/>
				</DialogContent>
				<DialogActions>
					<Button onClick={onClose} sx={{color: "var(--color-primary)"}}>Cancel</Button>
					<Button
						type="submit"
						variant="contained"
						sx={{
							backgroundColor: "var(--color-primary)",
							color: "var(--color-text-button)",
						}}
					>
						Save Changes
					</Button>
				</DialogActions>
			</form>
		</Dialog>
	);
};

export default EditLabModal;
