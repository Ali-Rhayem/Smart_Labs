using System;
using System.Net;
using MongoDB.Driver;
using System.Net.Mail;
using backend.Models;
using Google.Apis.Auth.OAuth2;
using Google.Apis.Gmail.v1;
using Google.Apis.Gmail.v1.Data;
using Google.Apis.Services;
using MimeKit;
using System.IO;
using System.Threading;
using Google.Apis.Util.Store;

namespace backend.helpers;

public class LabHelper
{
    private readonly IMongoCollection<Lab> _labs;
    private readonly IConfiguration _configuration;
    private readonly IMongoCollection<User> _users;

    public LabHelper(IMongoDatabase database, IConfiguration configuration)
    {
        _labs = database.GetCollection<Lab>("Labs");
        _users = database.GetCollection<User>("Users");
        _configuration = configuration;
    }


    public Boolean CreateStudentIfNotExists(string student_email)
    {
        // Check if student exists in the database
        var student = _users.Find(user => user.Email == student_email).FirstOrDefault();

        // if student exists, return true
        if (student != null)
        {
            return true;
        }

        var password = GenerateTempPassword();
        // If student does not exist, create a new student
        // find the last id
        var lastStudent = _users.Find(_ => true).SortByDescending(user => user.Id).FirstOrDefault();
        var studentId = lastStudent == null ? 1 : lastStudent.Id + 1;
        var newStudent = new User
        {
            Id = studentId,
            Email = student_email,
            Name = "Student_" + studentId,
            Role = "student",
            Password = BCrypt.Net.BCrypt.HashPassword(password),
        };

        // insert student into the database
        _users.InsertOne(newStudent);

        // send email to student with temp password
        SendEmail(student_email, password);

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


    private void SendEmail(string student_email, string password)
    {
        string[] Scopes = { GmailService.Scope.GmailSend };
        string ApplicationName = "smart_lab";
        var EmailSettings = _configuration.GetSection("EmailSettings");
        var appDir = AppDomain.CurrentDomain.BaseDirectory;
        var credPath = Path.Combine(appDir, "gmail_api", "credentials");
        var tokenPath = Path.Combine(appDir, "gmail_api", "token.json");
        // Load credentials.json file
        UserCredential credential;
        using (var stream = new FileStream(tokenPath, FileMode.Open, FileAccess.Read))
        {
            credential = GoogleWebAuthorizationBroker.AuthorizeAsync(
                GoogleClientSecrets.FromStream(stream).Secrets,
                Scopes,
                "user",
                CancellationToken.None,
                new FileDataStore(credPath)).Result;

            Console.WriteLine("Credential file saved to: " + credPath);
        }

        // Create Gmail API service
        var service = new GmailService(new BaseClientService.Initializer()
        {
            HttpClientInitializer = credential,
            ApplicationName = ApplicationName,
        });

        // Create the email content
        var email = new MimeMessage();
        email.From.Add(new MailboxAddress("Smart Labs", EmailSettings["Email"]));
        email.To.Add(new MailboxAddress(student_email.Split("@")[0], student_email));
        email.Subject = "Your Temporary Password";
        email.Body = new TextPart("plain")
        {
            Text = $"Dear Student,\n\nYour temporary password is: {password}\n\nPlease log in and change your password immediately.\n\nBest regards,\nUniversity Team"
        };

        // Convert the email to raw format
        using (var stream = new MemoryStream())
        {
            email.WriteTo(stream);
            var rawMessage = Convert.ToBase64String(stream.ToArray())
                                .Replace('+', '-')
                                .Replace('/', '_')
                                .Replace("=", "");

            var message = new Message { Raw = rawMessage };

            try
            {
                // Send the email
                var request = service.Users.Messages.Send(message, "me");
                request.Execute();
                Console.WriteLine("Email sent successfully!");
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred: " + ex.Message);
            }
        }


    }

}
