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
    public required List<int> PPE { get; set; }

    [BsonElement("Instructors")]
    public List<int> Instructors { get; set; } = [];

    [BsonElement("Students")]
    public List<int> Students { get; set; } = [];

    [BsonElement("Day")]
    public required string Day { get; set; }

    [BsonElement("StartTime")]
    public required string StartTime { get; set; }

    [BsonElement("EndTime")]
    public required string EndTime { get; set; }

    [BsonElement("Report")]
    public string? Report { get; set; }

    [BsonElement("SemesterID")]
    public int SemesterID { get; set; } = 0;

    public bool EndLab { get; set; } = false;
}
