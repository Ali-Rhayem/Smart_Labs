import React, { useState, useEffect } from "react";
import {
	Drawer,
	List,
	ListItem,
	ListItemText,
	ListItemIcon,
	ListItemButton,
	Divider,
	Box,
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
	const [isMiniVariant, setIsMiniVariant] = useState(
		window.innerWidth <= 1200
	);

	useEffect(() => {
		const handleResize = () => {
			setIsMiniVariant(window.innerWidth <= 1200);
		};

		window.addEventListener("resize", handleResize);
		return () => window.removeEventListener("resize", handleResize);
	}, []);

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
			sx={{
				width: isMiniVariant ? 65 : 240,
				transition: "width 0.2s ease-in-out",
				"& .MuiDrawer-paper": {
					width: isMiniVariant ? 65 : 240,
					transition: "width 0.2s ease-in-out",
					overflowX: "hidden",
					bgcolor: "var(--color-card)",
					borderRight: "1px solid var(--color-border)",
					display: "flex",
					flexDirection: "column",
				},
			}}
		>
			<List sx={{ flex: 1 }}>
				{allowedNavItems.map((item) => (
					<ListItem
						key={item.path}
						disablePadding
						sx={{
							display: "block",
							bgcolor:
								location.pathname === item.path
									? "var(--color-card-hover)"
									: "transparent",
						}}
					>
						<ListItemButton
							onClick={() => navigate(item.path)}
							sx={{
								minHeight: 48,
								justifyContent: isMiniVariant
									? "center"
									: "initial",
								px: 2.5,
							}}
						>
							<ListItemIcon
								sx={{
									minWidth: 0,
									mr: isMiniVariant ? 0 : 3,
									justifyContent: "center",
									color:
										location.pathname === item.path
											? "var(--color-primary)"
											: "var(--color-text)",
								}}
							>
								{item.icon}
							</ListItemIcon>
							{!isMiniVariant && (
								<ListItemText
									primary={item.label}
									sx={{
										opacity: isMiniVariant ? 0 : 1,
										color:
											location.pathname === item.path
												? "var(--color-primary)"
												: "var(--color-text)",
									}}
								/>
							)}
						</ListItemButton>
					</ListItem>
				))}
			</List>

			<Box sx={{ mt: "auto" }}>
				<Divider sx={{ border: 0 }} />
				<List>
					<ListItem disablePadding>
						<ListItemButton
							sx={{
								minHeight: 48,
								justifyContent: isMiniVariant
									? "center"
									: "initial",
								px: 2.5,
								"&:hover": {
									bgcolor: "var(--color-card-hover)",
								},
								transition: "background-color 0.2s",
							}}
						>
							<ListItemIcon
								sx={{
									minWidth: 0,
									mr: isMiniVariant ? 0 : 3,
									justifyContent: "center",
								}}
							>
								<ThemeToggleButton />
							</ListItemIcon>
							{!isMiniVariant && (
								<ListItemText
									primary="Dark Mode"
									sx={{
										color: "var(--color-text)",
										"& .MuiTypography-root": {
											fontSize: "0.9rem",
											fontWeight: 500,
										},
									}}
								/>
							)}
						</ListItemButton>
					</ListItem>

					<ListItem disablePadding>
						<ListItemButton
							onClick={handleLogout}
							sx={{
								minHeight: 48,
								justifyContent: isMiniVariant
									? "center"
									: "initial",
								px: 2.5,
								"&:hover": {
									bgcolor: "var(--color-card-hover)",
								},
								transition: "background-color 0.2s",
							}}
						>
							<ListItemIcon
								sx={{
									minWidth: 0,
									mr: isMiniVariant ? 0 : 3,
									justifyContent: "center",
									color: "var(--color-danger)",
								}}
							>
								<LogoutIcon />
							</ListItemIcon>
							{!isMiniVariant && (
								<ListItemText
									primary="Logout"
									sx={{
										color: "var(--color-danger)",
										"& .MuiTypography-root": {
											fontSize: "0.9rem",
											fontWeight: 500,
										},
									}}
								/>
							)}
						</ListItemButton>
					</ListItem>
				</List>
			</Box>
		</Drawer>
	);
};

export default SideBar;
