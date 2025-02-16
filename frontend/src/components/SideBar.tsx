import React from "react";
import {
	Drawer,
	List,
	ListItem,
	ListItemText,
	ListItemIcon,
} from "@mui/material";
import { Link, useLocation, useNavigate } from "react-router-dom";
import ThemeToggleButton from "./ThemeToggleButton";
import { navItems } from "../config/routes";
import { Role } from "../types/user";
import LogoutIcon from "@mui/icons-material/Logout";
import { useUser } from "../contexts/UserContext";

interface SideBarProps {
	userRole: Role;
}

const SideBar: React.FC<SideBarProps> = ({ userRole }) => {
	const location = useLocation();
	const { logout } = useUser();
	const navigate = useNavigate();

	const handleLogout = () => {
		logout();
		navigate("/login");
	};

	// Filter navigation items based on the current user's role.
	const allowedNavItems = navItems.filter((item) =>
		item.roles.includes(userRole)
	);

	return (
		<Drawer
			variant="permanent"
			PaperProps={{
				sx: {
					backgroundColor: "var(--color-background)",
					color: "var(--color-text)",
				},
			}}
			sx={{
				width: 240,
				flexShrink: 0,
				"& .MuiDrawer-paper": {
					width: 240,
					boxSizing: "border-box",
				},
			}}
		>
			<List sx={{ height: "100%" }}>
				{allowedNavItems.map((item) => (
					<ListItem
						key={item.label}
						component={Link}
						to={item.path}
						sx={{
							backgroundColor:
								location.pathname === item.path
									? "var(--color-primary-light)"
									: "transparent",
							cursor: "pointer",
							"&:hover": {
								backgroundColor: "var(--color-card)",
							},
						}}
					>
						<ListItemIcon sx={{ color: "var(--color-text)" }}>
							{item.icon}
						</ListItemIcon>
						<ListItemText primary={item.label} />
					</ListItem>
				))}
				{/* Always include the theme toggle at the end of the list */}
				<ThemeToggleButton />
				<ListItem
					component="button"
					onClick={handleLogout}
					sx={{
						position: "absolute",
						bottom: 10,
						width: "100%",
						color: "var(--color-danger)",
						"&:hover": {
							bgcolor:
								"rgb(from var(--color-danger) r g b / 0.08)",
						},
					}}
				>
					<ListItemIcon sx={{ color: "inherit" }}>
						<LogoutIcon />
					</ListItemIcon>
					<ListItemText primary="Logout" />
				</ListItem>
			</List>
		</Drawer>
	);
};

export default SideBar;
