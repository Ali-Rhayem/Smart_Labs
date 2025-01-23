using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

public class Semaster
{
    [BsonId]
    public int Id { get; set; }

    [BsonElement("Name")]
    public required string Name { get; set; }

    [BsonElement("CurrentSemaster")]
    public bool CurrentSemaster { get; set; } = false;

}