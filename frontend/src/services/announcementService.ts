import { smart_labs } from "../utils/axios";
import {
	Announcement,
	AnnouncementDTO,
	CommentDTO,
	Comment,
} from "../types/announcements";
import { labService } from "./labService";

export const announcementService = {
	sendAnnouncement: (lab_id: number, formData: FormData) =>
		smart_labs.postAPI<AnnouncementDTO, FormData>(
			`/lab/${lab_id}/announcement`,
			formData,
			{
				headers: {
					"Content-Type": "multipart/form-data",
				},
			}
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

	deleteAnnouncement: (lab_id: number, announcement_id: number) =>
		smart_labs.deleteAPI(`/lab/${lab_id}/announcement/${announcement_id}`),

	deleteComment: (
		lab_id: number,
		announcement_id: number,
		comment_id: number
	) =>
		smart_labs.deleteAPI(
			`/lab/${lab_id}/announcement/${announcement_id}/comment/${comment_id}`
		),

	submiteAssignment: (
		lab_id: number,
		announcement_id: number,
		formData: FormData
	) =>
		smart_labs.postAPI<AnnouncementDTO, FormData>(
			`/lab/${lab_id}/assignment/${announcement_id}/submit`,
			formData,
			{
				headers: {
					"Content-Type": "multipart/form-data",
				},
			}
		),
};
