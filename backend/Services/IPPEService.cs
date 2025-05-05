using backend.Models;
namespace backend.Services
{
    public interface IPPEService
    {
        Task<List<PPE>> GetAllPPEAsync();
        Task<List<PPE>> GetListOfPPEsAsync(List<int> ids);
        Task<PPE> CreatePPEAsync(PPE ppe);
        Task<PPE> UpdatePPEAsync(int id, PPE ppe);
        Task<bool> DeletePPEAsync(int id);
    }

}