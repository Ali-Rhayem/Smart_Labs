import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LoginPage from "./pages/LoginPage";
import LabsPage from "./pages/LabsPage";

const App: React.FC = () => {
	document.documentElement.setAttribute("data-theme","dark")
	return (
		<Router>
			<Routes>
				<Route path="/" element={<LoginPage />} />
				<Route path="/labs" element={<LabsPage />} />
			</Routes>
		</Router>
	);
};

export default App;
