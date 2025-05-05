using MongoDB.Driver;
namespace backend.Services;

public class RoomService : IRoomService
{

    private readonly IMongoCollection<Rooms> _rooms;
    private readonly IServiceProvider _serviceProvider;


    public RoomService(IMongoDatabase database, IServiceProvider serviceProvider)
    {
        _rooms = database.GetCollection<Rooms>("Rooms");
        _serviceProvider = serviceProvider;
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
        var _labService = _serviceProvider.GetRequiredService<ILabService>();

        await _rooms.UpdateOneAsync(r => r.Name == name, Builders<Rooms>.Update.Set(r => r.Name, room.Name));
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
