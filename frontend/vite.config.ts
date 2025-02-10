import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
	plugins: [react()],
	css: {
		postcss: "./postcss.config.mjs",
	},
	optimizeDeps: {
		include: [
			"@mui/material",
			"@mui/icons-material",
			"@mui/x-date-pickers",
			"@mui/x-date-pickers/AdapterDateFns",
		],
		exclude: ["date-fns"],
	},
});
