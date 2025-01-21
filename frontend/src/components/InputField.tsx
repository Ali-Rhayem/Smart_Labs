import React from "react";
import { TextField } from "@mui/material";

interface InputFieldProps {
	label: string;
	type: string;
	value: string;
	placeholder: string;
	id: string;
	onChange: React.ChangeEventHandler<HTMLInputElement>;
}

const InputField: React.FC<InputFieldProps> = ({
	label,
	type,
	value,
	placeholder,
	id,
	onChange,
}) => {
	return (
		<TextField
			id={id}
			placeholder={placeholder}
			label={label}
			type={type}
			value={value}
			onChange={onChange}
			fullWidth
			variant="outlined"
			margin="normal"
			InputLabelProps={{
				style: { color: "var(--color-text)" },
			}}
			InputProps={{
				style: {
					borderRadius: "10px",
					backgroundColor: "var(--color-background)",
					color: "var(--color-text)",
					borderColor: "var(--color-primary-light)",
				},
			}}
			FormHelperTextProps={{
				style: { color: "red" },
			}}
		/>
	);
};

export default InputField;
