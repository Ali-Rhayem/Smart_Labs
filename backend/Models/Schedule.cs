using MongoDB.Bson.Serialization.Attributes;


public class Schedule
{
    [BsonElement("DayOfWeek")]
    public required string DayOfWeek { get; set; }

    [BsonElement("StartTime")]
    public required string StartTime { get; set; }

    [BsonElement("EndTime")]
    public required string EndTime { get; set; }
}