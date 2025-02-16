import { smart_labs } from "../utils/axios";
import {
	Announcement,
	AnnouncementDTO,
	CommentDTO,
} from "../types/announcements";

export const announcementService = {
	sendAnnouncement: (lab_id: number, announcement: Announcement) =>
		smart_labs.postAPI<AnnouncementDTO, Announcement>(
			`/lab/${lab_id}/announcement`,
			announcement
		),

	CommentOnAnnouncement: (
		lab_id: number,
		announcement_id: number,
		comment: Comment
	) =>
		smart_labs.postAPI<CommentDTO, Comment>(
			`/lab/${lab_id}/announcement/${announcement_id}/comment`,
			comment
		),
};
