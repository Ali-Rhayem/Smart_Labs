import React from "react";
import { Box, Button, Typography } from "@mui/material";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { LocalizationProvider } from "@mui/x-date-pickers";
import { AdapterDateFns } from "@mui/x-date-pickers/AdapterDateFnsV3";

interface DateRangeFilterProps {
	startDate: Date | null;
	endDate: Date | null;
	onStartDateChange: (date: Date | null) => void;
	onEndDateChange: (date: Date | null) => void;
	onClear: () => void;
	dateError: string;
}

const pickerStyles = {
	"& .MuiOutlinedInput-root": {
		color: "var(--color-text)",
		backgroundColor: "var(--color-card)",
		"& fieldset": {
			borderColor: "var(--color-background)",
		},
		"&:hover fieldset": {
			borderColor: "var(--color-primary)",
		},
	},
	"& .MuiIconButton-root": {
		color: "var(--color-text)",
	},
	"& .MuiInputLabel-root": {
		color: "var(--color-text)",
	},
	// Calendar popup styles
	"& .MuiCalendarPicker-root, & .MuiPickersPopper-root .MuiPaper-root": {
		backgroundColor: "var(--color-card) !important",
		color: "var(--color-text) !important",
	},
	// Calendar header
	"& .MuiPickersCalendarHeader-root": {
		color: "var(--color-text)",
		"& .MuiPickersCalendarHeader-label": {
			color: "var(--color-text)",
		},
		"& .MuiIconButton-root": {
			color: "var(--color-text)",
		},
	},
	// Calendar days
	"& .MuiPickersDay-root": {
		color: "var(--color-text)",
		backgroundColor: "var(--color-card)",
		"&:hover": {
			backgroundColor: "var(--color-card)",
		},
		"&.Mui-selected": {
			backgroundColor: "var(--color-primary) !important",
			color: "var(--color-text-button) !important",
		},
	},
	// Today's date
	"& .MuiPickersDay-today": {
		border: "1px solid var(--color-primary) !important",
		color: "var(--color-primary) !important",
	},
	// Week days header
	"& .MuiDayPicker-header, & .MuiDayPicker-weekDayLabel": {
		color: "var(--color-text) !important",
	},
	// Month/year selection
	"& .MuiMonthPicker-root, & .MuiYearPicker-root": {
		backgroundColor: "var(--color-card)",
		"& .MuiPickersYear-yearButton, & .MuiPickersMonth-monthButton": {
			color: "var(--color-text)",
			"&.Mui-selected": {
				backgroundColor: "var(--color-primary)",
				color: "var(--color-text-button)",
			},
		},
	},
};

const DateRangeFilter: React.FC<DateRangeFilterProps> = ({
	startDate,
	endDate,
	onStartDateChange,
	onEndDateChange,
	onClear,
	dateError,
}) => {
	const maxDate = new Date();

	return (
		<LocalizationProvider dateAdapter={AdapterDateFns}>
			<Box
				sx={{
					display: "flex",
					justifyContent: "flex-end",
					alignItems: "center",
					gap: 2,
				}}
			>
				<DatePicker
					label="Start Date"
					value={startDate}
					onChange={onStartDateChange}
					maxDate={maxDate}
					sx={pickerStyles}
				/>
				<DatePicker
					label="End Date"
					value={endDate}
					onChange={onEndDateChange}
					minDate={startDate || undefined}
					maxDate={maxDate}
					disabled={!startDate}
					sx={pickerStyles}
				/>
				{dateError && (
					<Typography color="error" variant="caption">
						{dateError}
					</Typography>
				)}
				{(startDate || endDate) && (
					<Button
						variant="outlined"
						sx={{
							color: "var(--color-primary)",
							borderColor: "var(--color-primary)",
						}}
						onClick={onClear}
					>
						Clear
					</Button>
				)}
			</Box>
		</LocalizationProvider>
	);
};

export default DateRangeFilter;
