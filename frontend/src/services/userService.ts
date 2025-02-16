import { UpdateUserDto, User } from "../types/user";
import { smart_labs } from "../utils/axios";

export const userService = {
	getUser: (id: number) => smart_labs.getAPI<User>(`/user/${id}`),

	getUsers: () => smart_labs.getAPI<User[]>(`/user`),

	createUser: (user: any) => smart_labs.postAPI(`/user`, user),

	editUser: (id: number, user: any) =>
		smart_labs.putAPI<User, UpdateUserDto>(`/user/${id}`, user),

	deleteUser: (id: number) => smart_labs.deleteAPI(`/user/${id}`),

	resetPassword: (email: string) =>
		smart_labs.postAPI<never, object>(`/user/resetPassword`, {
			email: email,
		}),
};
