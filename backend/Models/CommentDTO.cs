using backend.Models;
using backend.Services;

public class CommentDTO
{
    public int Id { get; set; }

    public required UserDTO user { get; set; }

    public required string Message { get; set; }

    public DateTime Time { get; set; } = DateTime.UtcNow;

    public static async Task<List<CommentDTO>> FromCommentListAsync(List<Comment> v, UserService userService)
    {
        List<CommentDTO> results = [];
        foreach (var comment in v)
        {
            results.Add(new CommentDTO
            {
                Id = comment.Id,
                user = (UserDTO)await userService.GetUserById(comment.Sender),
                Message = comment.Message,
                Time = comment.Time,
            });
        }
        return results;
    }
}