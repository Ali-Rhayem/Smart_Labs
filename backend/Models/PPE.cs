using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;


public class PPE
{

    [BsonId]
    public int Id { get; set; }

    [BsonElement("Name")]
    public required string Name { get; set; }

}