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

    public async Task<Faculty?> AddMajorAsync(int id, string major)
    {
        var main_faculty = await _faculties.Find(faculty => faculty.Id == id).FirstOrDefaultAsync();
        if (main_faculty == null)
        {
            return null;
        }

        // check if major already exists
        if (main_faculty.Major.Contains(major))
        {
            return main_faculty;
        }
        main_faculty.Major.Add(major);
        await _faculties.ReplaceOneAsync(faculty => faculty.Id == id, main_faculty);
        return main_faculty;
    }

    public async Task<Faculty?> RemoveMajorAsync(int id, string major)
    {
        var main_faculty = await _faculties.Find(faculty => faculty.Id == id).FirstOrDefaultAsync();
        if (main_faculty == null)
        {
            return null;
        }

        // check if major exists
        if (!main_faculty.Major.Contains(major))
        {
            return null;
        }
        main_faculty.Major.Remove(major);
        await _faculties.ReplaceOneAsync(faculty => faculty.Id == id, main_faculty);
        return main_faculty;
    }


}
