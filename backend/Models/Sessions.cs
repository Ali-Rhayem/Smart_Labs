using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Bson;
using Org.BouncyCastle.Security;
using backend.Models;


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
    public List<ObjectResult> Result { get; set; } = [];

    [BsonElement("total_attendance")]
    public decimal TotalAttendance { get; set; }

    [BsonElement("total_ppe_compliance")]
    public Dictionary<string, decimal> TotalPPECompliance { get; set; } = [];

    [BsonElement("outputs")]
    public List<Output> Outputs { get; set; } = [];

    [BsonElement("total_attendance_bytime")]
    public List<int> Total_attendance_bytime { get; set; } = [];

    [BsonElement("ppe_compliance_bytime")]
    public Dictionary<string, List<int>> PPE_compliance_bytime { get; set; } = [];

    [BsonElement("total_ppe_compliance_bytime")] 
    public List<int> Total_ppe_compliance_bytime { get; set; } = [];


}

public class ObjectResult
{
    [BsonId]
    public int Id { get; set; }
    [BsonElement("name")]
    public string? Name { get; set; }
    [BsonElement("attendance_percentage")]
    public decimal Attendance_percentage { get; set; }
    [BsonElement("ppe_compliance")]
    public Dictionary<string, decimal> PPE_compliance { get; set; } = [];
}

public class Output
{
    [BsonElement("time")]
    public string? Time { get; set; }
    [BsonElement("people")]
    public List<Person> People { get; set; } = new List<Person>();
}

public class Person
{
    [BsonElement("id")]
    public int Person_id { get; set; }

    [BsonElement("name")]
    public string Name { get; set; } = "";

    [BsonElement("ppe")]
    public Dictionary<string, int> PPE { get; set; } = [];
}

public class SessionsDTO
{
    public int? Id { get; set; }

    public int LabId { get; set; }

    public DateOnly Date { get; set; }

    public string? Report { get; set; }

    public List<ObjectResultDTO> Result { get; set; } = [];

    public decimal TotalAttendance { get; set; }

    public Dictionary<string, decimal> TotalPPECompliance { get; set; } = [];

    private List<Output> Outputs { get; set; } = [];
    public List<int> Total_attendance_bytime { get; set; } = [];
    public Dictionary<string, List<int>> PPE_compliance_bytime { get; set; } = [];
    public List<int> Total_ppe_compliance_bytime { get; set; } = [];
}

public class ObjectResultDTO
{
    public int Id { get; set; }
    public string? Name { get; set; }
    public required UserDTO User { get; set; }
    public decimal Attendance_percentage { get; set; }
    public Dictionary<string, decimal> PPE_compliance { get; set; } = [];
}