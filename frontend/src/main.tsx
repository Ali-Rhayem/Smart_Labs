import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
import ThemeProviderComponent from "./themes/ThemeContext";
import { UserProvider } from "./contexts/UserContext";

// const queryClient = new QueryClient();

const root = ReactDOM.createRoot(
	document.getElementById("root") as HTMLElement
);

root.render(
	<ThemeProviderComponent>
		<UserProvider>
			<App />
		</UserProvider>
	</ThemeProviderComponent>
);
