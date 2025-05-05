using backend.Models;

namespace backend.Services
{
    public interface ISessionService
    {
        Task<List<SessionsDTO>> GetSessionsOfLabAsync(int labId);
        Task<Sessions> CreateSessionAsync(int labId);
    }

}