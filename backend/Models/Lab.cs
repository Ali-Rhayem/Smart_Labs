using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.Collections.Generic;

public class Lab
{
    [BsonId]
    public int Id { get; set; }

    [BsonElement("Lab_Code")]
    public required string LabCode { get; set; }

    [BsonElement("Lab_Name")]
    public required string LabName { get; set; }

    [BsonElement("Description")]
    public string? Description { get; set; }

    [BsonElement("PPE")]
    public List<int> PPE { get; set; } = [];

    [BsonElement("Instructors")]
    public List<int> Instructors { get; set; } = [];

    [BsonElement("Students")]
    public List<int> Students { get; set; } = [];

    [BsonElement("Day")]
    public required List<Schedule> Schedule { get; set; }

    [BsonElement("Report")]
    public string? Report { get; set; }

    [BsonElement("SemesterID")]
    public int SemesterID { get; set; } = 0;

    [BsonElement("EndLab")]
    public bool EndLab { get; set; } = false;
}
