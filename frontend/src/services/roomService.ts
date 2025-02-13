import { smart_labs } from "../utils/axios";
import { Room } from "../types/room";

export const roomService = {
	getRooms: () => smart_labs.getAPI<Room[]>(`/room`),
};
