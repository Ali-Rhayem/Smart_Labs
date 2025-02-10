import { smart_labs } from "../utils/axios";
import { Session } from "../types/sessions";

export const sessionService = {
	getLabSessions: (id: number) =>
		smart_labs.getAPI<Session[]>(`/sessions/lab/${id}`),
};
