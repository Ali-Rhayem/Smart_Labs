import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
import ThemeProviderComponent from "./themes/ThemeContext";

const root = ReactDOM.createRoot(
	document.getElementById("root") as HTMLElement
);

root.render(
	<ThemeProviderComponent>
		<App />
	</ThemeProviderComponent>
);
