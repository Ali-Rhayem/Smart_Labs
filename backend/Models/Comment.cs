using MongoDB.Bson.Serialization.Attributes;

public class Comment
{
    [BsonId]
    public int Id { get; set; }

    [BsonElement("Sender")]
    public int Sender { get; set; }

    [BsonElement("Message")]
    public required string Message { get; set; }

    [BsonElement("Time")]
    public DateTime Time { get; set; }

}