import { useQuery } from "@tanstack/react-query";
import { roomService } from "../services/roomService";

export const useRooms = () => {
	return useQuery({
		queryKey: ["Rooms"],
		queryFn: () => roomService.getRooms(),
		staleTime: 30 * 60 * 1000,
	});
};
