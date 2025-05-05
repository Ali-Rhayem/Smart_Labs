using MongoDB.Driver;
namespace backend.Services
{
    public interface IRoomService
    {
        Task<List<Rooms>> GetAllRoomsAsync();
        Task<Rooms> GetRoomAsync(string name);
        Task<Rooms> CreateRoomAsync(Rooms room);
        Task<Rooms> UpdateRoomAsync(string name, Rooms room);
        Task<bool> DeleteRoomAsync(string name);
    }
}