using MongoDB.Bson.Serialization.Attributes;

public class Notifications
{
    [BsonId]
    public int Id { get; set; }

    [BsonElement("Title")]
    public string? Title { get; set; }

    [BsonElement("Message")]
    public string? Message { get; set; }

    [BsonElement("Data")]
    public Dictionary<string, string>? Data { get; set; }

    [BsonElement("Date")]
    public DateTime Date { get; set; }

    [BsonElement("UserID")]
    public int UserID { get; set; }

    [BsonElement("IsRead")]
    public bool IsRead { get; set; } = false;

    [BsonElement("IsDeleted")]
    public bool IsDeleted { get; set; } = false;

}