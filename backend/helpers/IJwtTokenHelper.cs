using System;

namespace backend.helpers
{
    public interface IJwtTokenHelper
    {
        string GenerateToken(int userId, string role);
    }
}