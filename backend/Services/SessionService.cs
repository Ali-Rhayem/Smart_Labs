using MongoDB.Driver;


public class SessionService
{
    private readonly IMongoCollection<Sessions> _sessions;

    public SessionService(IMongoDatabase database)
    {
        _sessions = database.GetCollection<Sessions>("Sessions");
    }

}