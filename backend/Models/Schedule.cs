using MongoDB.Bson.Serialization.Attributes;


public class Schedule
{
    [BsonElement("DayOfWeek")]
    public required string DayOfWeek { get; set; }

    [BsonElement("StartTime")]
    public required DateTime StartTime { get; set; }

    [BsonElement("EndTime")]
    public required DateTime EndTime { get; set; }
}