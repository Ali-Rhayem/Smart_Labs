using MongoDB.Bson.Serialization.Attributes;


public class Sessions
{

    [BsonId]
    public int Id { get; set; }

    [BsonElement("lab_id")]
    public int LabId { get; set; }

    [BsonElement("date")]
    public DateOnly Date { get; set; }

    [BsonElement("report")]
    public string? Report { get; set; }

    [BsonElement("result")]
    private string? Result { get; set; }

}