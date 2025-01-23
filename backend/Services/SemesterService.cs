using MongoDB.Driver;


namespace backend.Services;

public class SemesterService
{
    private readonly IMongoCollection<Semester> _semesters;

    public SemesterService(IMongoDatabase database)
    {
        _semesters = database.GetCollection<Semester>("Semester");
    }

    public async Task<List<Semester>> GetAllSemestersAsync()
    {
        return await _semesters.Find(_ => true).ToListAsync();
    }

    public async Task<Semester> GetSemesterByIdAsync(int id)
    {
        return await _semesters.Find(semester => semester.Id == id).FirstOrDefaultAsync();
    }

    public async Task<Semester> GetCurrentSemesterAsync()
    {
        return await _semesters.Find(semester => semester.CurrentSemester == true).FirstOrDefaultAsync();
    }

    public async Task<Semester> GetListOfSemestersAsync(List<int> ids)
    {
        return await _semesters.Find(semester => ids.Contains(semester.Id)).FirstOrDefaultAsync();
    }

    public async Task<Semester> CreateSemesterAsync(Semester semester)
    {
        var last_lab = _semesters.Find(_ => true).SortByDescending(semester => semester.Id).FirstOrDefault();
        semester.Id = last_lab == null ? 1 : last_lab.Id + 1;
        await _semesters.InsertOneAsync(semester);
        return semester;
    }

    public async Task<bool> UpdateSemesterAsync(int id, Semester semesterIn)
    {
        semesterIn.Id = id;
        var result = await _semesters.ReplaceOneAsync(semester => semester.Id == id, semesterIn);
        return result.ModifiedCount > 0;
    }

    public async Task<bool> DeleteSemesterAsync(int id)
    {
        var result = await _semesters.DeleteOneAsync(semester => semester.Id == id);

        return result.DeletedCount > 0;

    }

    public async Task<bool> SetCurrentSemesterAsync(int id)
    {
        var currentSemester = await GetCurrentSemesterAsync();
        if (currentSemester != null)
        {
            currentSemester.CurrentSemester = false;
            await UpdateSemesterAsync(currentSemester.Id, currentSemester);
        }
        var semester = await GetSemesterByIdAsync(id);
        semester.CurrentSemester = true;
        return await UpdateSemesterAsync(id, semester);
    }




}
