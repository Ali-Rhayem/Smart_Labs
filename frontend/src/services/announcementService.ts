import { smart_labs } from "../utils/axios";
import { Announcement, AnnouncementDTO } from "../types/announcements";

export const announcementService = {
	sendAnnouncement: (lab_id: number, announcement: Announcement) =>
		smart_labs.postAPI<AnnouncementDTO, Announcement>(
			`/lab/${lab_id}/announcement`,
			announcement
		),
};
