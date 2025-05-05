import React from "react";
import DashboardIcon from "@mui/icons-material/Dashboard";
import ScienceIcon from "@mui/icons-material/Science";
import NotificationsIcon from "@mui/icons-material/Notifications";
import PersonIcon from "@mui/icons-material/Person";
import GroupIcon from "@mui/icons-material/Group";
import SchoolIcon from "@mui/icons-material/School";
import ApartmentIcon from "@mui/icons-material/Apartment";
import MeetingRoomIcon from "@mui/icons-material/MeetingRoom";
import SecurityIcon from "@mui/icons-material/Security";
import { Role } from "../types/user";

export interface NavItem {
	label: string;
	path: string;
	icon: React.ReactNode;
	roles: Role[];
}

export const navItems: NavItem[] = [
	{
		label: "Labs",
		path: "/labs",
		icon: <ScienceIcon />,
		roles: ["student", "instructor", "admin"],
	},
	{
		label: "Dashboard",
		path: "/dashboard",
		icon: <DashboardIcon />,
		roles: ["student", "instructor", "admin"],
	},
	{
		label: "Notifications",
		path: "/notifications",
		icon: <NotificationsIcon />,
		roles: ["student", "instructor"],
	},
	{
		label: "Profile",
		path: "/profile",
		icon: <PersonIcon />,
		roles: ["student", "instructor", "admin"],
	},
	{
		label: "Users",
		path: "/users",
		icon: <GroupIcon />,
		roles: ["admin"],
	},
	{
		label: "Semesters",
		path: "/semesters",
		icon: <SchoolIcon />,
		roles: ["admin"],
	},
	{
		label: "Rooms",
		path: "/rooms",
		icon: <MeetingRoomIcon />,
		roles: ["admin"],
	},
	{
		label: "PPEs",
		path: "/ppes",
		icon: <SecurityIcon />,
		roles: ["admin"],
	},
	{
		label: "faculties",
		path: "/faculties",
		icon: <ApartmentIcon />,
		roles: ["admin"],
	},
];
