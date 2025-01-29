using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;


public class Faculty
{

    [BsonId]
    public int Id { get; set; }

    [BsonElement("Faculty")]
    public required string faculty { get; set; }

    [BsonElement("Major")]
    public List<string> Major { get; set; } = [];

}