namespace backend.Services
{
    public interface IFacultyService
    {
        Task<List<Faculty>> GetAllFacultiesAsync();
        Task<Faculty> AddFacultyAsync(Faculty faculty);
        Task<Faculty?> UpdateFacultNameyAsync(int id, Faculty faculty);
        Task<Faculty?> AddMajorAsync(int id, string major);
        Task<Faculty?> RemoveMajorAsync(int id, string major);
        Task<bool> DeleteFacultyAsync(int id);
        Task<bool> FacultyExists(string faculty);
        Task<bool> MajorExistsInFaculty(string? faculty, string major);
    }
}