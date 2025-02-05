import React from "react";
import { Button } from "@mui/material";
import { useTheme } from "../themes/ThemeContext";

const ThemeToggleButton: React.FC = () => {
  const { themeMode, toggleTheme } = useTheme();

  return (
    <div className="p-4 text-center">
      
      <Button onClick={toggleTheme} variant="contained">
        Switch to {themeMode === "dark" ? "Light" : "Dark"} Mode
      </Button>
    </div>
  );
};

export default ThemeToggleButton;
