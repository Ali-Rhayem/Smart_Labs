using MongoDB.Driver;


public class SessionService
{
    private readonly IMongoCollection<Sessions> _sessions;

    public SessionService(IMongoDatabase database)
    {
        _sessions = database.GetCollection<Sessions>("Sessions");
    }

    public async Task<List<Sessions>> GetSessionsOfLabAsync(int labId)
    {
        return await _sessions.Find(session => session.LabId == labId).ToListAsync();
    }

}