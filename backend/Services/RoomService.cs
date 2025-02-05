using MongoDB.Driver;
namespace backend.Services;

public class RoomService
{

    private readonly IMongoCollection<Rooms> _rooms;
    private readonly LabService _labService;


    public RoomService(IMongoDatabase database, LabService labService)
    {
        _rooms = database.GetCollection<Rooms>("Rooms");
        _labService = labService;
    }

    public async Task<List<Rooms>> GetAllRoomsAsync()
    {
        return await _rooms.Find(_ => true).ToListAsync();
    }

    public async Task<Rooms> GetRoomAsync(string name)
    {
        return await _rooms.Find(room => room.Name == name).FirstOrDefaultAsync();
    }

    public async Task<Rooms> CreateRoomAsync(Rooms room)
    {
        await _rooms.InsertOneAsync(room);
        return room;
    }

    public async Task<Rooms> UpdateRoomAsync(string name, Rooms room)
    {
        await _rooms.ReplaceOneAsync(r => r.Name == name, room);
        var labs = await _labService.GetLabsByRoomAsync(name);
        foreach (var lab in labs)
        {
            lab.Room = room.Name;
            await _labService.UpdateLabAsync(lab.Id, lab);
        }
        return room;
    }

    public async Task<bool> DeleteRoomAsync(string name)
    {
        var result = await _rooms.DeleteOneAsync(r => r.Name == name);
        return result.DeletedCount > 0;
    }
}
