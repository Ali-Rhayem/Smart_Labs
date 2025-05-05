namespace backend.Services
{
    public interface IDashboardService
    {
        Task<Dictionary<string, object>> GetDashboardAsync(int id, string role, int user_id);
    }
}