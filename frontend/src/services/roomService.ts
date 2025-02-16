import { smart_labs } from "../utils/axios";
import { Room, RoomDTO } from "../types/room";

export const roomService = {
	getRooms: () => smart_labs.getAPI<Room[]>(`/room`),

	createRoom: (room: Room) =>
		smart_labs.postAPI<Room, RoomDTO>(`/room`, room),

	updateRoom: (old_name: string, room: Room) =>
		smart_labs.putAPI<Room, RoomDTO>(`/room/${old_name}`, room),

	deleteRoom: (name: string) => smart_labs.deleteAPI<Room>(`/room/${name}`),
};
