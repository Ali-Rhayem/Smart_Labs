using MongoDB.Driver;


namespace backend.Services;

public class FacultyService
{
    private readonly IMongoCollection<Faculty> _faculties;

    public FacultyService(IMongoDatabase database)
    {
        _faculties = database.GetCollection<Faculty>("Faculties");
    }

    public async Task<List<Faculty>> GetAllFacultiesAsync()
    {
        return await _faculties.Find(faculty => true).ToListAsync();
    }

    public async Task<Faculty> AddFacultyAsync(Faculty faculty)
    {
        var lastFaculty = await _faculties.Find(faculty => true).SortByDescending(faculty => faculty.Id).FirstOrDefaultAsync();
        faculty.Id = lastFaculty == null ? 1 : lastFaculty.Id + 1;
        faculty.Major = [];
        await _faculties.InsertOneAsync(faculty);
        return faculty;
    }

    public async Task<Faculty?> UpdateFacultNameyAsync(int id, Faculty faculty)
    {
        var main_faculty = await _faculties.Find(faculty => faculty.Id == id).FirstOrDefaultAsync();
        if (main_faculty == null)
        {
            return null;
        }
        faculty.Id = id;
        faculty.Major = main_faculty.Major;
        await _faculties.ReplaceOneAsync(faculty => faculty.Id == id, faculty);
        return faculty;
    }



}
