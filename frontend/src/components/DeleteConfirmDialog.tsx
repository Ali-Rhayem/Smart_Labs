import {
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	Button,
	Typography,
} from "@mui/material";

interface DeleteConfirmDialogProps {
	open: boolean;
	onClose: () => void;
	onConfirm: () => void;
	title?: string;
	message?: string;
}

const DeleteConfirmDialog: React.FC<DeleteConfirmDialogProps> = ({
	open,
	onClose,
	onConfirm,
	title = "Confirm Delete",
	message = "Are you sure you want to delete this item?",
}) => {
	return (
		<Dialog
			open={open}
			onClose={onClose}
			PaperProps={{
				sx: {
					bgcolor: "var(--color-card)",
					color: "var(--color-text)",
					borderRadius: "10px",
					minWidth: "300px",
				},
			}}
		>
			<DialogTitle
				sx={{
					borderBottom: 1,
					borderColor: "var(--color-text-secondary)",
					marginBottom: "1.5rem",
				}}
			>
				{title}
			</DialogTitle>
			<DialogContent sx={{ py: 2 }}>
				<Typography>{message}</Typography>
			</DialogContent>
			<DialogActions sx={{ p: 2, pt: 1 }}>
				<Button
					onClick={onClose}
					sx={{
						color: "var(--color-text)",
						"&:hover": {
							bgcolor: "var(--color-card-hover)",
						},
					}}
				>
					Cancel
				</Button>
				<Button
					onClick={onConfirm}
					sx={{
						bgcolor: "var(--color-danger)",
						color: "white",
						"&:hover": {
							bgcolor: "rgb(from var(--color-danger) r g b / 0.8)",
						},
					}}
				>
					Delete
				</Button>
			</DialogActions>
		</Dialog>
	);
};

export default DeleteConfirmDialog;
