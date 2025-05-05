import React from "react";
import { Autocomplete, TextField, Chip } from "@mui/material";

interface MultiSelectProps<T> {
	value: T[];
	onChange: (value: T[]) => void;
	label: string;
	placeholder?: string;
	error?: string[] | null;
	options?: T[];
	validate?: (value: T) => boolean;
	getOptionLabel?: (option: string | T) => string;
	freeSolo?: boolean;
	limitTags?: number;
}

const MultiSelect = <T extends string | { [key: string]: any }>({
	value,
	onChange,
	label,
	placeholder,
	error,
	options = [],
	validate,
	getOptionLabel = (option: string | T) =>
		typeof option === "string" ? option : option.toString(),
	freeSolo = false,
	limitTags = 5,
}: MultiSelectProps<T>) => {
	const handleChange = (
		_: React.SyntheticEvent<Element, Event>,
		newValue: (string | T)[]
	) => {
		const filteredValues = newValue.filter(
			(option): option is T =>
				typeof option !== "string" ||
				(validate ? validate(option as T) : true)
		);
		onChange(filteredValues);
	};

	return (
		<Autocomplete
			multiple
			freeSolo={freeSolo}
			limitTags={limitTags}
			options={options}
			value={value}
			filterSelectedOptions
			onChange={handleChange}
			getOptionLabel={getOptionLabel}
			sx={{
				mt: 2,
				"& .MuiAutocomplete-tag": {
					color: "var(--color-text)",
				},
				"& .MuiAutocomplete-endAdornment": {
					"& .MuiSvgIcon-root": {
						color: "var(--color-text-secondary)",
						transition: "color 0.2s",
						"&:hover": {
							color: "var(--color-danger)",
						},
					},
					"& .MuiAutocomplete-clearIndicator:hover": {
						color: "var(--color-danger)",
					},
				},
			}}
			slotProps={{
				popper: {
					sx: {
						"& .MuiPaper-root": {
							bgcolor: "var(--color-background)",
							borderRadius: "10px",
							marginTop: "8px",
							boxShadow: "0 4px 20px 0 rgba(0,0,0,0.12)",
						},
						"& .MuiAutocomplete-listbox": {
							padding: "8px",
							bgcolor: "var(--color-background)",
							"& .MuiAutocomplete-option": {
								color: "var(--color-text)",
								borderRadius: "8px",
								margin: "4px 0",
								"&:hover": {
									bgcolor: "var(--color-card-hover)",
								},
								"&.Mui-selected": {
									bgcolor: "var(--color-card)",
									"&:hover": {
										bgcolor: "var(--color-card-hover)",
									},
								},
							},
						},
					},
				},
			}}
			renderTags={(value, getTagProps) =>
				value.map((option, index) => (
					<Chip
						{...getTagProps({ index })}
						key={typeof option === "string" ? option : index}
						label={getOptionLabel(option)}
						sx={{
							bgcolor: "var(--color-card)",
							color: "var(--color-text)",
							"& .MuiChip-deleteIcon": {
								color: "var(--color-text-secondary)",
								"&:hover": { color: "var(--color-danger)" },
							},
						}}
					/>
				))
			}
			renderInput={(params) => (
				<TextField
					{...params}
					label={label}
					placeholder={placeholder}
					error={Boolean(error?.length)}
					helperText={error?.join(", ")}
					sx={{
						"& .MuiOutlinedInput-root": {
							borderRadius: "10px",
							bgcolor: "var(--color-background)",
							"& fieldset": {
								borderColor: "var(--color-text)",
							},
							"&:hover fieldset": {
								borderColor: "var(--color-primary)",
							},
							"&.Mui-focused fieldset": {
								borderColor: "var(--color-primary)",
							},
						},
						"& .MuiInputLabel-root": {
							color: "var(--color-text)",
							"&.Mui-focused": {
								color: "var(--color-primary)",
							},
						},
						"& .MuiInputBase-input": {
							color: "var(--color-text)",
						},
					}}
				/>
			)}
		/>
	);
};

export default MultiSelect;
