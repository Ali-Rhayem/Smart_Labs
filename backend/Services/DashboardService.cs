using MongoDB.Driver;
namespace backend.Services;

public class DashboardService
{


    private readonly IServiceProvider _serviceProvider;


    public DashboardService(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public async Task<Dictionary<string, object>> GetDashboardAsync(int id, string role)
    {
        var _labService = _serviceProvider.GetRequiredService<LabService>();
        var result = new Dictionary<string, object>();
        List<Lab> labs = [];
        if (role == "instructor")
            labs = await _labService.GetInstructorLabsAsync(id);
        else if (role == "admin")
            labs = await _labService.GetAllLabsAsync();
        else if (role == "student")
            labs = await _labService.GetStudentLabsAsync(id);
        else
            return result;

        List<Dictionary<string, object>> labs_result = [];

        int total_students = 0;
        int total_sessions = 0;
        int total_labs = labs.Count;
        int avg_attandance = 0;
        int ppe_compliance = 0;



        foreach (var lab in labs)
        {
            total_students += lab.Students.Count;
            var labResult = await _labService.AnalyzeLabAsync(lab.Id);
            labs_result.Add(labResult);
            if (labResult.ContainsKey("xaxis"))
                total_sessions += ((List<string>)labResult["xaxis"]).Count;
            if (labResult.ContainsKey("total_attendance"))
                avg_attandance += (int)labResult["total_attendance"];
            if (labResult.ContainsKey("total_ppe_compliance"))
                ppe_compliance += (int)labResult["total_ppe_compliance"];

        }

        if (role == "student")
            result["total_students"] = total_sessions;
        else
            result["total_students"] = total_students;
        result["labs"] = labs_result;
        result["total_labs"] = total_labs;
        result["avg_attandance"] = avg_attandance / total_labs;
        result["ppe_compliance"] = ppe_compliance / total_labs;
        return result;
    }


}
