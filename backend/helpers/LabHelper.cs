using System;
using System.ComponentModel.DataAnnotations;
using System.Net;
using System.Net.Mail;

namespace backend.helpers;

public class LabHelper
{
    private readonly IMongoCollection<Lab> _labs;
    private readonly IConfiguration _configuration;

    public LabHelper(IMongoDatabase database, IConfiguration configuration)
    {
        _labs = database.GetCollection<Lab>("Labs");
        _configuration = configuration;
    }


    public Boolean CreateStudentIfNotExists(int studentId)
    {
        // Check if student exists in the database
        var student = _users.Find(user => user.Id == studentId).FirstOrDefault();

        // if student exists, return true
        if (student != null)
        {
            return true;
        }

        // If student does not exist, create a new student
        var newStudent = new User
        {
            Id = studentId,
            Email = studentId + "@mu.edu.lb",
            Name = "Student_" + studentId,
            Role = "student"
        };

        // add temp password
        newStudent.Password = GenerateTempPassword();

        // insert student into the database
        _users.InsertOne(newStudent)

        // send email to student with temp password
        SendEmail(newStudent.Email, newStudent.Password);

        return true;

    }

    private string GenerateTempPassword()
    {
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_-+=}{:;/?.>,<0123456789abcdefghijklmnopqrstuvwxyz";
        var stringChars = new char[10];
        var random = new Random();

        for (int i = 0; i < stringChars.Length; i++)
        {
            stringChars[i] = chars[random.Next(chars.Length)];
        }

        return new String(stringChars);
    }

    private void SendEmail(string email, string password)
    {

        try
        {
            var EmailSettings = _configuration.GetSection("EmailSettings");

            var smtpClient = new SmtpClient(EmailSettings["Host"])
            {
                Port = EmailSettings.GetValue<int>("Port"),
                Credentials = new NetworkCredential(EmailSettings["Email"], EmailSettings["Password"]),
                EnableSsl = true,
            };

            var mailMessage = new MailMessage
            {
                From = new MailAddress(EmailSettings["Email"]),
                Subject = "Your Temporary Password",
                Body = $"Dear Student,\n\nYour temporary password is: {password}\n\nPlease log in and change your password immediately.\n\nBest regards,\nUniversity Team",
                IsBodyHtml = false,
            };

            mailMessage.To.Add(email);

            smtpClient.Send(mailMessage);

            Console.WriteLine("Email sent successfully to " + email);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Failed to send email: " + ex.Message);
        }

    }

}
