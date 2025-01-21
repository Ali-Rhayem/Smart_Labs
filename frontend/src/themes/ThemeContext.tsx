import React, { createContext, useContext, useState, ReactNode } from "react";
import { createTheme, ThemeProvider } from "@mui/material/styles";
import { CssBaseline } from "@mui/material";

interface ThemeContextType {
	// toggleTheme: () => void;
	themeMode: string;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const useTheme = () => {
	const context = useContext(ThemeContext);
	if (!context) {
		throw new Error("useTheme must be used within a ThemeProvider");
	}
	return context;
};

const ThemeProviderComponent: React.FC<{ children: ReactNode }> = ({
	children,
}) => {
	const [themeMode] = useState<"dark">("dark");

	// const toggleTheme = () => {
	// 	setThemeMode((prev) => (prev === "light" ? "dark" : "light"));
	// };

	const theme = createTheme({
		palette: {
			mode: themeMode,
		},
	});

	return (
		<ThemeContext.Provider value={{ themeMode }}>
			<ThemeProvider theme={theme}>
				<CssBaseline />
				{children}
			</ThemeProvider>
		</ThemeContext.Provider>
	);
};

export default ThemeProviderComponent;
