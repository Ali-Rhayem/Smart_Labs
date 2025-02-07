import React from "react";
import { Alert, Snackbar } from "@mui/material";

interface ErrorAlertProps {
	open: boolean;
	message: string;
	severity: "error" | "success" | "info" | "warning";
	onClose: () => void;
}

const ErrorAlert: React.FC<ErrorAlertProps> = ({
	open,
	message,
	severity,
	onClose,
}) => {
	return (
		<Snackbar
			open={open}
			autoHideDuration={5000}
			onClose={onClose}
			anchorOrigin={{ vertical: "top", horizontal: "right" }}
		>
			<Alert
				onClose={onClose}
				severity={severity}
				variant="filled"
				sx={{ width: "100%" }}
			>
				{message}
			</Alert>
		</Snackbar>
	);
};

export default ErrorAlert;
