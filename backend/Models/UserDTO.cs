namespace backend.Models;

public class UserDTO
{
    public int Id { get; set; }

    public required string Name { get; set; }

    public required string Email { get; set; }

    public string? Major { get; set; }

    public string? Faculty { get; set; }

    public string? Image { get; set; }


    public static explicit operator UserDTO(User v)
    {
        return new UserDTO
        {
            Id = v.Id,
            Name = v.Name,
            Email = v.Email,
            Major = v.Major,
            Faculty = v.Faculty,
            Image = v.Image,
        };
    }
}
