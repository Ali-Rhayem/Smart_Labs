import React, { createContext, useContext, ReactNode } from "react";
import { Role } from "../config/routes";

interface User {
	id: number;
	role: Role;
}

interface UserContextType {
	user: User | null;
}

const defaultUser: User = { role: "instructor", id: 1 };

const UserContext = createContext<UserContextType>({ user: defaultUser });

export const useUser = () => useContext(UserContext);

interface UserProviderProps {
	children: ReactNode;
}

export const UserProvider: React.FC<UserProviderProps> = ({ children }) => {
	return (
		<UserContext.Provider value={{ user: defaultUser }}>
			{children}
		</UserContext.Provider>
	);
};
