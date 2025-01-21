const colors = require("tailwindcss/colors");

module.exports = {
	content: ["./src/**/*.{js,jsx,ts,tsx}"],
	theme: {
		extend: {
			colors: {
				primary: {
					DEFAULT: "#FFFF00", // Neon Yellow
				},
				secondary: "#1C1C1C", // Slightly Lighter Dark Gray
				background: {
					dark: "#121212", // Dark Mode Background
				},
				text: {
					dark: "#FFFFFF", // Dark Mode Text
				},
				card: {
					dark: "#1C1C1C", // Dark Mode Card
				},
			},
		},
	},
	plugins: [],
};
