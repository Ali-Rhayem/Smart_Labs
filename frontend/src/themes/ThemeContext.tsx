import React, {
	createContext,
	useContext,
	useState,
	useEffect,
	ReactNode,
} from "react";

// Define the theme mode type.
type ThemeMode = "light" | "dark";

// Define the shape of the theme context.
interface ThemeContextType {
	themeMode: ThemeMode;
	toggleTheme: () => void;
}

// Create the context.
const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Custom hook for accessing the theme context.
export const useTheme = () => {
	const context = useContext(ThemeContext);
	if (!context) {
		throw new Error(
			"useTheme must be used within a ThemeProviderComponent"
		);
	}
	return context;
};

interface ThemeProviderProps {
	children: ReactNode;
}

const ThemeProviderComponent: React.FC<ThemeProviderProps> = ({ children }) => {
	// Initialize theme from localStorage or default to 'dark'.
	const [themeMode, setThemeMode] = useState<ThemeMode>(() => {
		const stored = localStorage.getItem("themeMode") as ThemeMode | null;
		return stored === "light" || stored === "dark" ? stored : "dark";
	});

	// Update the HTML data attribute and localStorage whenever themeMode changes.
	useEffect(() => {
		document.documentElement.setAttribute("data-theme", themeMode);
		localStorage.setItem("themeMode", themeMode);
	}, [themeMode]);

	// Toggle between light and dark themes.
	const toggleTheme = () => {
		setThemeMode((prev) => (prev === "dark" ? "light" : "dark"));
	};

	return (
		<ThemeContext.Provider value={{ themeMode, toggleTheme }}>
			{children}
		</ThemeContext.Provider>
	);
};

export default ThemeProviderComponent;
