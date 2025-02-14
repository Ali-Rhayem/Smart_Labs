using backend.Models;
using backend.Services;
using MongoDB.Driver;


public class SessionService
{
    private readonly IMongoCollection<Sessions> _sessions;
    private readonly UserService _userService;

    public SessionService(IMongoDatabase database, UserService userService)
    {
        _sessions = database.GetCollection<Sessions>("Sessions");
        _userService = userService;
    }

    public async Task<List<SessionsDTO>> GetSessionsOfLabAsync(int labId)
    {
        var sessions = await _sessions.Find(session => session.LabId == labId).ToListAsync();
        List<SessionsDTO> sessionsDTO = [];
        foreach (Sessions session in sessions)
        {
            var sessionDTO = new SessionsDTO
            {
                Id = session.Id,
                LabId = session.LabId,
                Date = session.Date,
                Report = session.Report,
                TotalAttendance = session.TotalAttendance,
                TotalPPECompliance = session.TotalPPECompliance,
                Total_ppe_compliance_bytime = session.Total_ppe_compliance_bytime,
                Total_attendance_bytime = session.Total_attendance_bytime,
                PPE_compliance_bytime = session.PPE_compliance_bytime,
            };
            var result = new List<ObjectResultDTO>();
            foreach (ObjectResult r in session.Result)
            {
                var user = (UserDTO)await _userService.GetUserById(r.Id);
                var output = new ObjectResultDTO
                {
                    Id = r.Id,
                    Name = r.Name,
                    User = user,
                    Attendance_percentage = r.Attendance_percentage,
                    PPE_compliance = r.PPE_compliance
                };
                result.Add(output);
            }
            sessionDTO.Result = result;
            sessionsDTO.Add(sessionDTO);
        }
        return sessionsDTO;
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