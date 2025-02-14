using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

public class Rooms
{
    [BsonId]
    public ObjectId Id { get; set; }

    [BsonElement("name")]
    public required string Name { get; set; }

}