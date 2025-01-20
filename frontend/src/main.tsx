import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ThemeProviderComponent from "./themes/ThemeContext";

const queryClient = new QueryClient();

const root = ReactDOM.createRoot(
	document.getElementById("root") as HTMLElement
);

root.render(
	<QueryClientProvider client={queryClient}>
		<ThemeProviderComponent>
			<App />
		</ThemeProviderComponent>
	</QueryClientProvider>
);
