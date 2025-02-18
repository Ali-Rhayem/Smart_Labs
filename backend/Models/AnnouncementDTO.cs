using backend.Models;
using backend.Services;

public class AnnouncementDTO
{
    public int? Id { get; set; }

    public required UserDTO user { get; set; }

    public required string Message { get; set; }

    public List<string> Files { get; set; } = [];

    public DateTime Time { get; set; }

    public List<CommentDTO> Comments { get; set; } = [];

    public bool Assignment { get; set; } = false;

    public bool CanSubmit { get; set; } = false;

    public DateTime Deadline { get; set; }

    public List<SubmissionDTO> Submissions { get; set; } = [];

    public int? Grade { get; set; }
}

public class SubmissionDTO
{
    public int UserId { get; set; }

    public required UserDTO User { get; set; }

    public string? Message { get; set; }

    public List<string> Files { get; set; } = [];

    public DateTime Time { get; set; }

    public bool Submitted { get; set; } = false;

    public int? Grade { get; set; }


    public static async Task<List<SubmissionDTO>> FromSubmissionAsync(List<Submission> v, UserService userService)
    {
        List<SubmissionDTO> results = [];
        foreach (var submission in v)
        {
            results.Add(new SubmissionDTO
            {
                UserId = submission.UserId,
                User = (UserDTO)await userService.GetUserById(submission.UserId),
                Message = submission.Message,
                Files = submission.Files,
                Time = submission.Time,
                Grade = submission.Grade,
            });
        }
        return results;
    }
}