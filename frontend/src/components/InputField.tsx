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
			InputProps={{
				style: {
					borderRadius: "10px",
				},
			}}
		/>
	);
};

export default InputField;
