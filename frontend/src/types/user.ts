export type Role = "student" | "instructor" | "admin";

export interface User {
	id: number;
	name: string;
	email: string;
	major?: string;
	faculty?: string;
	image?: string;
	role: Role;
	fcm_token?: string;
}

export interface CreateUserDto extends Omit<User, "id" | "fcm_token"> {
	password: string;
}

export interface UpdateUserDto
	extends Partial<Omit<User, "id" | "role" | "fcm_token">> {}

export interface UserDTO extends Omit<User, "role" | "fcm_token"> {}
