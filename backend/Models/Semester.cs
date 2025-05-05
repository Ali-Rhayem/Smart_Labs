using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

public class Semester
{
    [BsonId]
    public int Id { get; set; } = 0;

    [BsonElement("Name")]
    public required string Name { get; set; }

    [BsonElement("CurrentSemester")]
    public bool CurrentSemester { get; set; } = false;

}