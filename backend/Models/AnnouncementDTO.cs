using backend.Models;

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

    public int? Grade { get; set; }
}