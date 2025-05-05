using MongoDB.Bson.Serialization.Attributes;
using System.ComponentModel.DataAnnotations;

namespace backend.Models;

public class UpdateUser
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

    [BsonElement("major")]
    public string? Major { get; set; }

    [BsonElement("faculty")]
    public string? Faculty { get; set; }

    [BsonElement("profile")]
    public string? Image { get; set; }
}
