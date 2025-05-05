import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
import ThemeProviderComponent from "./themes/ThemeContext";
import { UserProvider } from "./contexts/UserContext";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const queryClient = new QueryClient();
const root = ReactDOM.createRoot(
	document.getElementById("root") as HTMLElement
);

root.render(
	<ThemeProviderComponent>
		<QueryClientProvider client={queryClient}>
			<UserProvider>
				<App />
			</UserProvider>
		</QueryClientProvider>
	</ThemeProviderComponent>
);
