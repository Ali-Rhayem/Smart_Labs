using MongoDB.Bson.Serialization.Attributes;

public class Rooms
{
    [BsonElement("name")]
    public required string Name { get; set; }

}