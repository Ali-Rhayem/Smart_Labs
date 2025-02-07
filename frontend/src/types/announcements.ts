export interface Comment {
  id: number;
  userId: number;
  content: string;
  time: Date;
}

export interface Announcement {
  id: number;
  sender: number;
  message: string;
  files: string[];
  time: Date;
  comments: Comment[];
}