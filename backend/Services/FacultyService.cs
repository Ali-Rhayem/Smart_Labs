using MongoDB.Driver;


namespace backend.Services;

public class FacultyService
{
    private readonly IMongoCollection<Faculty> _faculties;

    public FacultyService( IMongoDatabase database)
    {
        _faculties = database.GetCollection<Faculty>("Faculties");
    }

    public async Task<List<Faculty>> GetAllFacultiesAsync()
    {
        return await _faculties.Find(faculty => true).ToListAsync();
    }

    

}
