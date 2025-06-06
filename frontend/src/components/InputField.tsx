import React, { useState } from "react";
import { TextField, IconButton, InputAdornment } from "@mui/material";
import { Visibility, VisibilityOff } from "@mui/icons-material";

interface InputFieldProps {
	label: string;
	name: string;
	type: string;
	value: string;
	placeholder: string;
	id: string;
	error?: string[] | null;
	disabled?: boolean;
	onChange: React.ChangeEventHandler<HTMLInputElement>;
	onBlur?: () => void; 
	multiline?: boolean;
	rows?: number;
}

const InputField: React.FC<InputFieldProps> = ({
	label,
	name,
	type,
	value,
	placeholder,
	id,
	error = null,
	disabled = false,
	onChange,
	onBlur, 
	multiline = false,
	rows = 1,
}) => {
	const [showPassword, setShowPassword] = useState(false);

	const handleClickShowPassword = () => setShowPassword(!showPassword);

	return (
		<>
			<TextField
				id={id}
				placeholder={placeholder}
				name={name}
				label={label}
				type={
					type === "password"
						? showPassword
							? "text"
							: "password"
						: type
				}
				value={value}
				onChange={onChange}
				onBlur={onBlur} 
				fullWidth
				variant="outlined"
				margin="normal"
				error={Boolean(error?.length)}
				helperText={error}
				disabled={disabled}
				multiline={multiline}
				rows={rows}
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
					endAdornment:
						type === "password" ? (
							<InputAdornment position="end">
								<IconButton
									aria-label="toggle password visibility"
									onClick={handleClickShowPassword}
									edge="end"
									sx={{ color: "var(--color-text)" }}
								>
									{showPassword ? (
										<VisibilityOff />
									) : (
										<Visibility />
									)}
								</IconButton>
							</InputAdornment>
						) : null,
				}}
				FormHelperTextProps={{
					style: { color: "red" },
				}}
				sx={{
					"& .MuiInputBase-input": {
						color: disabled
							? "var(--color-text-secondary)"
							: "var(--color-text)",
						WebkitTextFillColor: disabled
							? "var(--color-text-secondary)"
							: "var(--color-text)",
						transition: "color 0.2s",
						"&.Mui-disabled": {
							color: "var(--color-text-secondary)",
							WebkitTextFillColor: "var(--color-text-secondary)",
							opacity: 0.7,
							cursor: "not-allowed",
						},
						"&:-webkit-autofill": {
							WebkitBoxShadow:
								"0 0 0 100px var(--color-background) inset",
							WebkitTextFillColor: disabled
								? "var(--color-text-secondary)"
								: "var(--color-text)",
							caretColor: "var(--color-text)",
							borderColor: "var(--color-background)",
						},
					},
						"& input[type=number]": {
							MozAppearance: "textfield",
							"&::-webkit-outer-spin-button, &::-webkit-inner-spin-button": {
								WebkitAppearance: "none",
								margin: 0,
							},
						},
					"& .MuiInputLabel-root": {
						WebkitTextFillColor: disabled
							? "var(--color-text-secondary)"
							: "var(--color-text)",
						"&.Mui-focused": {
							color: "var(--color-primary)",
						},
					},
					"& .MuiOutlinedInput-root": {
						transition: "border-color 0.2s",
						"& fieldset": {
							borderColor: "var(--color-border)",
						},
						"&:hover fieldset": {
							borderColor: !disabled
								? "var(--color-primary)"
								: "var(--color-border)",
						},
						"&.Mui-focused fieldset": {
							borderColor: "var(--color-primary) !important",
						},
						"&.Mui-disabled": {
							"& fieldset": {
								borderColor: "var(--color-text-secondary)",
							},
						},
					},
				}}
			/>
		</>
	);
};

export default InputField;
