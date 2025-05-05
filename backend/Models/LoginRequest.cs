namespace backend.Models;

public class LoginRequest
{
    public required string Email { get; set; }
    public required string Password { get; set; }
    public required string? Fcm_token { get; set; }
}
