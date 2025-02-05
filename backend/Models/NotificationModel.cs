

public class NotificationModel
{
    public List<string> TargetFcmTokens { get; set; } = [];
    public string Title { get; set; } = "";
    public string Body { get; set; } = "";
    public Dictionary<string, string>? Data { get; set; } = [];
}