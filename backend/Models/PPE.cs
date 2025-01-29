using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;


public class PPE
{

    [BsonId]
    public int Id { get; set; };

    [BsonElement("Name")]
    public string Name { get; set; };

}