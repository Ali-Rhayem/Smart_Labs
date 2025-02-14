using MongoDB.Bson.Serialization.Attributes;
using System.ComponentModel.DataAnnotations;

namespace backend.Models;

public class User
{
    [BsonId]
    public int Id { get; set; }

    [BsonElement("name")]
    [Required]
    [StringLength(100)]
    public required string Name { get; set; }

    [BsonElement("email")]
    [Required]
    [EmailAddress]
    public required string Email { get; set; }

    [BsonElement("password")]
    [Required]
    public required string Password { get; set; }

    [BsonElement("major")]
    public string? Major { get; set; }

    [BsonElement("faculty")]
    public string? Faculty { get; set; }

    [BsonElement("profile")]
    public string? Image { get; set; }

    [BsonElement("role")]
    [Required]
    public required string Role { get; set; }

    [BsonElement("face_identity_vector")]
    private List<List<float>> FaceIdentityVector { get; set; } = new();

    [BsonElement("fcm_token")]
    public string? FcmToken { get; set; }

    [BsonElement("first_login")]
    public bool First_login { get; set; } = true;
}
