import React, { useState, useEffect } from "react";
import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
} from "@mui/material";
import InputField from "./InputField";

interface AddItemModalProps {
	open: boolean;
	onClose: () => void;
	onSubmit: (name: string) => void;
	title: string;
	itemLabel: string;
	placeholder?: string;
	initialValue?: string;
	submitLabel?: string;
}

export const AddItemModal: React.FC<AddItemModalProps> = ({
	open,
	onClose,
	onSubmit,
	title,
	itemLabel,
	placeholder = `Enter ${itemLabel.toLowerCase()} name`,
	initialValue = "",
	submitLabel = "Add",
}) => {
	const [itemName, setItemName] = useState(initialValue);
	const [error, setError] = useState<string[]>([]);

	useEffect(() => {
		setItemName(initialValue);
	}, [initialValue]);

	const handleSubmit = () => {
		if (!itemName.trim()) {
			setError([`${itemLabel} name is required`]);
			return;
		}
		onSubmit(itemName);
		setItemName("");
		onClose();
	};

	return (
		<Dialog
			open={open}
			onClose={() => {
				onClose();
				setItemName(initialValue);
			}}
			PaperProps={{
				sx: {
					bgcolor: "var(--color-background-secondary)",
					color: "var(--color-text)",
					borderRadius: "10px",
					minWidth: "50%",
				},
			}}
		>
			<DialogTitle>{title}</DialogTitle>
			<DialogContent>
				<InputField
					label={itemLabel}
					name={itemLabel.toLowerCase()}
					type="text"
					placeholder={placeholder}
					id={itemLabel.toLowerCase()}
					value={itemName}
					onChange={(e) => setItemName(e.target.value)}
					error={error}
				/>
			</DialogContent>
			<DialogActions sx={{ p: 2, pt: 0 }}>
				<Button
					onClick={() => {
						onClose();
						setItemName(initialValue);
					}}
					sx={{ color: "var(--color-text)" }}
				>
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
					{submitLabel}
				</Button>
			</DialogActions>
		</Dialog>
	);
};

export default AddItemModal;
