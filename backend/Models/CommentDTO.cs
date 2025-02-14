using backend.Models;

public class CommentDTO
{
    public int Id { get; set; }

    public required UserDTO user { get; set; }

    public required string Message { get; set; }

    public DateTime Time { get; set; } = DateTime.UtcNow;

}