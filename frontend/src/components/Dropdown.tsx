import {
	FormControl,
	InputLabel,
	MenuItem,
	Select,
	FormHelperText,
} from "@mui/material";

interface DropdownProps {
	label: string;
	value: string;
	options: { value: string; label: string }[];
	onChange: (value: string) => void;
	error?: string[] | null;
	disabled?: boolean;
}

const Dropdown: React.FC<DropdownProps> = ({
	label,
	value,
	options,
	onChange,
	error = null,
	disabled = false,
}) => {
	return (
		<FormControl fullWidth margin="normal" error={Boolean(error?.length)}>
			<InputLabel
				sx={{
					color: disabled
						? "var(--color-text-secondary)"
						: "var(--color-text)",
					"&.Mui-disabled": {
						color: "var(--color-text-secondary)",
					},
					"&.Mui-focused": {
						color: "var(--color-primary)",
					},
				}}
			>
				{label}
			</InputLabel>
			<Select
				value={value}
				label={label}
				onChange={(e) => onChange(e.target.value)}
				disabled={disabled}
				MenuProps={{
					sx: {
						"& .MuiPaper-root": {
							bgcolor: "var(--color-background)",
							borderRadius: "10px",
							marginTop: "8px",
							boxShadow: "0 4px 20px 0 rgba(0,0,0,0.12)",
						},
						"& .MuiMenu-list": {
							padding: "8px",
							bgcolor: "var(--color-background)",
						},
						"& .MuiMenuItem-root": {
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
				}}
				sx={{
					borderRadius: "10px",
					backgroundColor: "var(--color-background)",
					color: "var(--color-text)",
					transition: "border-color 0.2s",
					"& .MuiOutlinedInput-notchedOutline": {
						borderColor: "var(--color-text-secondary)",
					},
					"& .MuiSelect-select": {
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
					},
					"&:hover .MuiOutlinedInput-notchedOutline": {
						borderColor: !disabled
							? "var(--color-primary)"
							: "var(--color-text-secondary)",
					},
					"&.Mui-focused .MuiOutlinedInput-notchedOutline": {
						borderColor: "var(--color-primary) !important",
					},
					"&.Mui-disabled": {
						backgroundColor: "var(--color-background)",
						color: "var(--color-text-secondary)",
						"& .MuiOutlinedInput-notchedOutline": {
							borderColor: "var(--color-text-secondary)",
						},
					},
					"& .MuiSelect-icon": {
						color: disabled
							? "var(--color-text-secondary)"
							: "var(--color-text)",
						"& .MuiSelect-select": {
							color: disabled
								? "var(--color-text-secondary)"
								: "var(--color-text)",
							WebkitTextFillColor: disabled
								? "var(--color-text-secondary)"
								: "var(--color-text)",
							"&.Mui-disabled": {
								WebkitTextFillColor:
									"var(--color-text-secondary)",
								color: "var(--color-text-secondary)",
								opacity: 0.7,
								cursor: "not-allowed",
							},
						},
					},
				}}
			>
				{options.map((option) => (
					<MenuItem
						key={option.value}
						value={option.value}
						sx={{
							color: "var(--color-text)",
							backgroundColor: "var(--color-card)",
							"&:hover": {
								backgroundColor: "var(--color-card-hover)",
							},
							"&.MuiList-root-MuiMenu-list": {
								backgroundColor: "var(--color-card)",
							},
							"&.Mui-selected": {
								backgroundColor: "var(--color-card)",
								"&:hover": {
									backgroundColor: "var(--color-card-hover)",
								},
							},
						}}
					>
						{option.label}
					</MenuItem>
				))}
			</Select>
			{error && error.length > 0 && (
				<FormHelperText sx={{ color: "var(--color-danger)" }}>
					{error.join(", ")}
				</FormHelperText>
			)}
		</FormControl>
	);
};

export default Dropdown;
