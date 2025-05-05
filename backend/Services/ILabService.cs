using OneOf;
using backend.Models;

namespace backend.Services
{
    public interface ILabService
    {
        Task<List<Lab>> GetAllLabsAsync();
        Task<List<Lab>> GetInstructorLabsAsync(int instructorId, bool active = false);
        Task<List<User>?> GetStudentsInLabAsync(int labId);
        Task<List<User>?> GetInstructorsInLabAsync(int labId);
        Task<List<Lab>> GetStudentLabsAsync(int studentId);
        Task<Lab> GetLabByIdAsync(int id);
        Task<OneOf<Lab, ErrorMessage>> CreateLabAsync(Lab lab, List<string> student_emails, List<string> instructors_emails);
        Task<Boolean> UpdateLabAsync(int id, Lab updatedLab);
        Task<List<int>> AddStudentToLabAsync(int labId, List<String> emails);
        Task<Boolean> AddInstructorToLabAsync(int labId, List<int> instructorIds);
        Task<Boolean> EditPPEOfLabAsync(int labId, List<int> ppeId);
        Task<Boolean> RemoveStudentFromLabAsync(int labId, int studentId);
        Task<Boolean> RemoveInstructorFromLabAsync(int labId, int instructorId);
        Task<Boolean> DeleteLabAsync(int id);
        Task<Boolean> EndLabAsync(int id);
        Task<AnnouncementDTO?> SendAnnouncementToLabAsync(int id, Announcement announcement, IFormFileCollection? files);
        Task<string> DeleteAnnouncementFromLabAsync(int lab_id, int announcementId, int user_id);
        Task<CommentDTO?> CommentOnAnnouncementAsync(int lab_id, int announcementId, Comment comment);
        Task<Comment?> GetCommentByIdAsync(int lab_id, int announcementId, int commentId);
        Task<Boolean> DeleteCommentFromAnnouncementAsync(int lab_id, int announcementId, int commentId);
        Task<List<AnnouncementDTO>> GetAnnouncementsAsync(int lab_id);
        Task<OneOf<Sessions, ErrorMessage>> StartSessionAsync(int lab_id);
        Task<OneOf<bool, ErrorMessage>> EndSessionAsync(int lab_id);
        Task<List<Lab>> GetLabsByRoomAsync(string room);
        Task<Dictionary<string, object>> AnalyzeLabAsync(int lab_id, string role, int id);
        Task<AnnouncementDTO?> SubmitSolutionToAssignmentAsync(int lab_id, int assignment_id, Submission submission, IFormFileCollection? files);
        Task<bool> SetGradeAsync(int lab_id, int assignment_id, int user_id, int grade);
    }
}