import React, { useState } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
} from "@mui/material";
import MultiSelect from "./MultiSelect";

interface AddPeopleModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (emails: string[]) => void;
	type: "student" | "instructor";
}

export const AddPeopleModal: React.FC<AddPeopleModalProps> = ({
	open,
	onClose,
	onSubmit,
	type,
}) => {
	const [emails, setEmails] = useState<string[]>([]);
	const [errors, setErrors] = useState<string[]>([]);

	const validateEmail = (email: string) => {
		return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
	};

	const handleSubmit = () => {
		onSubmit(emails);
		setEmails([]);
		onClose();
	};

	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{
				sx: {
					bgcolor: "var(--color-background-secondary)",
					color: "var(--color-text)",
					borderRadius: "10px",
					minWidth: "50%",
				},
			}}
		>
			<DialogTitle>
				Add {type === "student" ? "Students" : "Instructors"}
			</DialogTitle>
			<DialogContent>
				<MultiSelect<string>
					label="Email Addresses"
					value={emails}
					onChange={setEmails}
					placeholder={`Enter ${type} email addresses`}
					validate={validateEmail}
					error={errors}
					freeSolo
				/>
			</DialogContent>
			<DialogActions sx={{ p: 2, pt: 0 }}>
				<Button onClick={onClose} sx={{ color: "var(--color-text)" }}>
					Cancel
				</Button>
				<Button
					onClick={handleSubmit}
					sx={{
						bgcolor: "var(--color-primary)",
						color: "var(--color-text-button)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-primary) r g b / 0.8)",
						},
					}}
				>
					Add
				</Button>
			</DialogActions>
		</Dialog>
	);
};
