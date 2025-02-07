import { useQuery } from "@tanstack/react-query";
import { labService } from "../services/labService";
import { User, useUser,  } from "../contexts/UserContext";

const getLabs = async (user: User) => {
	if (!user.id) return [];

	switch (user.role) {
		case "instructor":
			return labService.getInstructerLabs(user.id);
		case "student":
			return labService.getStudentLabs(user.id);
		case "admin":
			return labService.getLabs();
		default:
			return [];
	}
};


export const useLabsQuery = () => {
	const { user } = useUser();

	return useQuery({
		queryKey: ["labs", user?.role, user?.id],
		queryFn: () => getLabs(user!),
		staleTime: 30 * 60 * 1000,
		enabled: !!user?.id,
	});
};
