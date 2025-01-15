import {
	Drawer,
	List,
	ListItem,
	ListItemText,
	ListItemButton,
} from "@mui/material";
import { Link } from "react-router-dom";

const Sidebar = () => {
	return (
		<Drawer
			sx={{
				width: 240,
				flexShrink: 0,
				"& .MuiDrawer-paper": {
					width: 240,
					boxSizing: "border-box",
					backgroundColor: "#212121",
				},
			}}
			variant="permanent"
			anchor="left"
		>
			<List>
				<ListItem component="div">
					<ListItemButton
						component={Link}
						to="/labs"
						sx={{ color: "white" }}
					>
						<ListItemText primary="Labs" />
					</ListItemButton>
				</ListItem>
				<ListItem component="div">
					<ListItemButton
						component={Link}
						to="/dashboard"
						sx={{ color: "white" }}
					>
						<ListItemText primary="Dashboard" />
					</ListItemButton>
				</ListItem>
				<ListItem component="div">
					<ListItemButton
						component={Link}
						to="/messages"
						sx={{ color: "white" }}
					>
						<ListItemText primary="Messages" />
					</ListItemButton>
				</ListItem>
				<ListItem component="div">
					<ListItemButton
						component={Link}
						to="/profile"
						sx={{ color: "white" }}
					>
						<ListItemText primary="Profile" />
					</ListItemButton>
				</ListItem>
			</List>
		</Drawer>
	);
};

export default Sidebar;
