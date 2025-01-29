using MongoDB.Driver;


namespace backend.Services;

public class PPEService
{
    private readonly IMongoCollection<PPE> _PPEs;

    public PPEService(IMongoDatabase database)
    {
        _PPEs = database.GetCollection<PPE>("PPES");
    }

    public async Task<List<PPE>> GetAllPPEAsync()
    {
        return await _PPEs.Find(_ => true).ToListAsync();
    }
    
    public async Task<List<PPE>> GetListOfPPEsAsync(List<int> ids)
    {
        return await _PPEs.Find(ppe => ids.Contains(ppe.Id)).ToListAsync();
    }

    public async Task<PPE> CreatePPEAsync(PPE ppe)
    {
        await _PPEs.InsertOneAsync(ppe);
        return ppe;
    }

    public async Task<PPE> UpdatePPEAsync(int id, PPE ppe)
    {
        await _PPEs.ReplaceOneAsync(p => p.Id == id, ppe);
        return ppe;
    }

    public async Task<bool> DeletePPEAsync(int id)
    {
        var result = await _PPEs.DeleteOneAsync(p => p.Id == id);
        return result.DeletedCount > 0;
    }


}
