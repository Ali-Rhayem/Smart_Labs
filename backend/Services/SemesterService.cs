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

    public async Task<List<Semester>> GetListOfSemestersAsync(List<int> ids)
    {
        return await _semesters.Find(semester => ids.Contains(semester.Id)).ToListAsync();
    }

    public async Task<Semester> CreateSemesterAsync(Semester semester)
    {
        var last_lab = _semesters.Find(_ => true).SortByDescending(semester => semester.Id).FirstOrDefault();
        semester.Id = last_lab == null ? 1 : last_lab.Id + 1;
        await _semesters.InsertOneAsync(semester);
        return semester;
    }

    public async Task<Semester?> UpdateSemesterAsync(int id, Semester semesterIn)
    {
        semesterIn.Id = id;
        var result = await _semesters.ReplaceOneAsync(semester => semester.Id == id, semesterIn);
        return result.IsAcknowledged ? semesterIn : null;
    }

    public async Task<bool> DeleteSemesterAsync(int id)
    {
        var result = await _semesters.DeleteOneAsync(semester => semester.Id == id);

        return result.DeletedCount > 0;

    }

    public async Task<bool> SetCurrentSemesterAsync(int id)
    {
        var semester = await GetSemesterByIdAsync(id);
        if (semester == null)
            return false;

        // set current semester to false for all semesters
        await _semesters.UpdateManyAsync(Builders<Semester>.Filter.Empty, Builders<Semester>.Update.Set("CurrentSemester", false));

        semester.CurrentSemester = true;
        var result = await UpdateSemesterAsync(id, semester);
        return result != null;

    }




}
