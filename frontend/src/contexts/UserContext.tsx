import React, { createContext, useContext, ReactNode, useState } from "react";
import { Role } from "../config/routes";

interface User {
	id: number;
	role: Role;
	token: string;
}

interface UserContextType {
	user: User | null;
	login: (userData: User) => void;
	logout: () => void;
}

const UserContext = createContext<UserContextType | null>(null);

export const UserProvider: React.FC<{ children: ReactNode }> = ({
	children,
}) => {
	const [user, setUser] = useState<User | null>(() => {
		const token = localStorage.getItem("token");
		const userId = localStorage.getItem("userId");
		const userRole = localStorage.getItem("userRole");

		return token && userId && userRole
			? { id: parseInt(userId), role: userRole as Role, token }
			: null;
	});

	const login = (userData: User) => {
		setUser(userData);
		localStorage.setItem("token", userData.token);
		localStorage.setItem("userId", userData.id.toString());
		localStorage.setItem("userRole", userData.role);
	};

	const logout = () => {
		setUser(null);
		localStorage.removeItem("token");
		localStorage.removeItem("userId");
		localStorage.removeItem("userRole");
	};

	return (
		<UserContext.Provider value={{ user, login, logout }}>
			{children}
		</UserContext.Provider>
	);
};

export const useUser = () => {
	const context = useContext(UserContext);
	if (!context) throw new Error("useUser must be used within UserProvider");
	return context;
};
