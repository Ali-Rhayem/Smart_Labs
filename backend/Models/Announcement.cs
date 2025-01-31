using MongoDB.Bson.Serialization.Attributes;

public class Aannouncement
{
    [BsonId]
    public int Id { get; set; }

    [BsonElement("Sender")]
    public int Sender { get; set; }

    [BsonElement("Message")]
    public required string Message { get; set; }

    [BsonElement("files")]
    public List<string> Files { get; set; } = [];

    [BsonElement("Time")]
    public DateTime Time { get; set; }

    [BsonElement("comments")]
    public List<Comment> Comments { get; set; } = [];
}