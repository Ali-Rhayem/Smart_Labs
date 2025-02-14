public class FirstLogin
{
    public required int Id { get; set; }
    public required string Name { get; set; }
    public required string Faculty { get; set; }
    public required string Major { get; set; }
    public string Image { get; set; } = "";
    public required string Password { get; set; }
    public required string ConfirmPassword { get; set; }
    public bool First_login { get; set; } = true;
}