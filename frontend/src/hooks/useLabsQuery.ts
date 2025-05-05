import { useQuery } from "@tanstack/react-query";
import { labService } from "../services/labService";
import { User, useUser } from "../contexts/UserContext";

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

export const useLabUsers = (labId: number) => {
	const instructorsQuery = useQuery({
		queryKey: ["labInstructors", labId],
		queryFn: () => labService.getInstructorsInLab(labId),
		staleTime: 30 * 60 * 1000,
	});

	const studentsQuery = useQuery({
		queryKey: ["labStudents", labId],
		queryFn: () => labService.getStudentsInLab(labId),
		staleTime: 30 * 60 * 1000,
	});

	return {
		instructors: instructorsQuery.data || [],
		students: studentsQuery.data || [],
		isLoading: instructorsQuery.isLoading || studentsQuery.isLoading,
		error: instructorsQuery.error || studentsQuery.error,
	};
};

export const useLabAnnouncements = (labId: number) => {
	return useQuery({
		queryKey: ["labAnnouncements", labId],
		queryFn: () => labService.getAnnouncements(labId),
		staleTime: 30 * 60 * 1000,
	});
};

export const useLabAnalytics = (labId: number) => {
	return useQuery({
		queryKey: ["labAnalytics", labId],
		queryFn: () => labService.getLabAnalytics(labId),
		staleTime: 30 * 60 * 1000,
	});
};
