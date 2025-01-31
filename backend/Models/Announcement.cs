using MongoDB.Bson.Serialization.Attributes;

public class Announcement
{
    [BsonId]
    public int Id { get; set; }

    [BsonElement("Sender")]
    public int Sender { get; set; }

    [BsonElement("Message")]
    public required string Message { get; set; }

    [BsonElement("Files")]
    public List<string> Files { get; set; } = [];

    [BsonElement("Time")]
    public DateTime Time { get; set; }

    [BsonElement("Comments")]
    public List<Comment> Comments { get; set; } = [];
}