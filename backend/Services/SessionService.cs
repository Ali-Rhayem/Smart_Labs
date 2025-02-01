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

    public async Task<Sessions> CreateSessionAsync(int labId)
    {
        var last_session = await _sessions.Find(session => true).SortByDescending(session => session.Id).FirstOrDefaultAsync();
        var session = new Sessions
        {
            Id = last_session == null ? 1 : last_session.Id + 1,
            LabId = labId,
            Date = DateOnly.FromDateTime(DateTime.Now)
        };
        await _sessions.InsertOneAsync(session);
        return session;
    }


}