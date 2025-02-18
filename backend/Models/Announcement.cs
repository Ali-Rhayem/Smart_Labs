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
    public DateTime Time { get; set; } = DateTime.UtcNow;

    [BsonElement("Comments")]
    public List<Comment> Comments { get; set; } = [];

    [BsonElement("AssignmentId")]
    public bool Assignment { get; set; } = false;

    [BsonElement("can_submit")]
    public bool CanSubmit { get; set; } = false;

    [BsonElement("Deadline")]
    public DateTime Deadline { get; set; } = DateTime.UtcNow.AddDays(1);

    [BsonElement("Submissions")]
    public List<Submission> Submissions { get; set; } = [];

    [BsonElement("Grade")]
    public int? Grade { get; set; }
}


public class Submission
{
    [BsonElement("UserId")]
    public int UserId { get; set; }

    [BsonElement("Message")]
    public string? Message { get; set; }

    [BsonElement("Files")]
    public List<string> Files { get; set; } = [];

    [BsonElement("Time")]
    public DateTime Time { get; set; } = DateTime.UtcNow;

    [BsonElement("Submitted")]
    public bool Submitted { get; set; } = false;

    [BsonElement("Grade")]
    public int? Grade { get; set; }
}