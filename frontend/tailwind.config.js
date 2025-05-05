const colors = require("tailwindcss/colors");

module.exports = {
	content: ["./src/**/*.{js,jsx,ts,tsx}"],
	theme: {
		extend: {
			colors: {
				primary: {
					DEFAULT: "#FFFF00", 
					light: "#1976d2", 
				},
				secondary: "#1C1C1C",
				background: {
					dark: "#121212",
					light: "#ffffff",
				},
				text: {
					dark: "#FFFFFF",
					light: "#000000",
				},
				card: {
					dark: "#1C1C1C",
					light: "#f5f5f5",
				},
			},
		},
	},
	plugins: [],
};
