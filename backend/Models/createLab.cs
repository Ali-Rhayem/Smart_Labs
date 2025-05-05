public class CreateLab
{
    public required Lab Lab { get; set; }
    public List<string> Student_Emails { get; set; } = [];
    public List<string> Instructor_Emails { get; set; } = [];
}
