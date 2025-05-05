import React from "react";
import IconButton from "@mui/material/IconButton";
import Brightness4Icon from "@mui/icons-material/Brightness4";
import Brightness7Icon from "@mui/icons-material/Brightness7";
import { useTheme } from "../themes/ThemeContext";

const ThemeToggleButton: React.FC = () => {
  const { themeMode, toggleTheme } = useTheme();

  return (
    <IconButton 
      onClick={toggleTheme}
      sx={{ 
        padding: 0,
        color: "var(--color-text)",
        "&:hover": {
          color: "var(--color-primary)",
        },
      }}
    >
      {themeMode === "dark" ? <Brightness7Icon /> : <Brightness4Icon />}
    </IconButton>
  );
};

export default ThemeToggleButton;
