import React from "react";
import {
	Drawer,
	List,
	ListItem,
	ListItemText,
	ListItemIcon,
} from "@mui/material";
import { Link, useLocation } from "react-router-dom";
import ThemeToggleButton from "./ThemeToggleButton";
import { navItems, Role } from "../config/routes";

interface SideBarProps {
	userRole: Role;
}

const SideBar: React.FC<SideBarProps> = ({ userRole }) => {
	const location = useLocation();

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
			<List>
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
			</List>
		</Drawer>
	);
};

export default SideBar;
