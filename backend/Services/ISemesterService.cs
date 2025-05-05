using backend.Models;

namespace backend.Services
{

    public interface ISemesterService
    {
        Task<List<Semester>> GetAllSemestersAsync();
        Task<Semester> GetSemesterByIdAsync(int id);
        Task<Semester> GetCurrentSemesterAsync();
        Task<List<Semester>> GetListOfSemestersAsync(List<int> ids);
        Task<Semester> CreateSemesterAsync(Semester semester);
        Task<Semester?> UpdateSemesterAsync(int id, Semester semesterIn);
        Task<bool> DeleteSemesterAsync(int id);
        Task<bool> SetCurrentSemesterAsync(int id);
    }

}