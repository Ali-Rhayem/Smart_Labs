import React from "react";
import { Navigate } from "react-router-dom";
import { useUser } from "../contexts/UserContext";
import { Role } from "../config/routes";

interface ProtectedRouteProps {
	requiredRoles: Role[];
	children: JSX.Element;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
	requiredRoles,
	children,
}) => {
    const { user } = useUser();
    
	if (!user?.token) {
		return <Navigate to="/" replace />;
	}

	if (!requiredRoles.includes(user.role)) {
		return <Navigate to="/unauthorized" replace />;
	}

	return children;
};

export default ProtectedRoute;
