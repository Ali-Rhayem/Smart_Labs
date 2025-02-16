import React from "react";
import { TextField, InputAdornment } from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";

interface SearchFieldProps {
  value: string;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
}

const SearchField: React.FC<SearchFieldProps> = ({
  value,
  onChange,
  placeholder = "Search...",
}) => {
  return (
    <TextField
      placeholder={placeholder}
      value={value}
      onChange={onChange}
      size="small"
      sx={{
        flex: 1,
        maxWidth: "400px",
        borderRadius: "10px",
        bgcolor: "var(--color-card)",
        "& .MuiOutlinedInput-root": {
          "& fieldset": {
            borderColor: "var(--color-text-secondary)",
            borderRadius: "10px",
          },
          "&:hover fieldset": {
            borderColor: "var(--color-primary)",
          },
          "&.Mui-focused fieldset": {
            borderColor: "var(--color-primary)",
          },
        },
        "& .MuiInputBase-input": {
          color: "var(--color-text)",
        },
      }}
      InputProps={{
        startAdornment: (
          <InputAdornment position="start">
            <SearchIcon sx={{ color: "var(--color-text-secondary)" }} />
          </InputAdornment>
        ),
      }}
    />
  );
};

export default SearchField;