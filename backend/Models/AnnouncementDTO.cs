using backend.Models;

public class AnnouncementDTO
{
    public int? Id { get; set; }

    public required UserDTO user { get; set; }

    public required string Message { get; set; }

    public List<string> Files { get; set; } = [];

    public DateTime Time { get; set; }

    public List<CommentDTO> Comments { get; set; } = [];
}