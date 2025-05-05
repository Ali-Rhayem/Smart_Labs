namespace backend.helpers
{
    public interface ILabHelper
    {
        Boolean CreateStudentIfNotExists(string student_email);
        string GenerateTempPassword();
        bool SendEmail(string student_email, string send_message, string subject);
    }
}