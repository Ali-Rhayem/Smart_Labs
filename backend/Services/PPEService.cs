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



}
