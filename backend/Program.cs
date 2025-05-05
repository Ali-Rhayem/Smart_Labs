using MongoDB.Driver;
using backend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using backend.helpers;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.
        // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
        builder.Services.AddSingleton<IMongoClient>(sp =>
        {
            var mongoSettings = builder.Configuration.GetSection("MongoDB");
            var connectionString = mongoSettings["ConnectionString"];
            return new MongoClient(connectionString);
        });

        builder.Services.AddScoped(sp =>
        {
            var mongoSettings = builder.Configuration.GetSection("MongoDB");
            var client = sp.GetRequiredService<IMongoClient>();
            var databaseName = mongoSettings["DatabaseName"];
            return client.GetDatabase(databaseName);
        });

        builder.Services.AddCors(options =>
        {
            options.AddPolicy("AllowEverything", policy =>
            {
                policy.AllowAnyOrigin()
                      .AllowAnyHeader()
                      .AllowAnyMethod();
            });
        });

        builder.Services.AddScoped<IUserService, UserService>();
        builder.Services.AddScoped<ILabService, LabService>();
        builder.Services.AddScoped<ISemesterService, SemesterService>();
        builder.Services.AddScoped<IPPEService, PPEService>();
        builder.Services.AddScoped<IRoomService, RoomService>();
        builder.Services.AddScoped<ISessionService, SessionService>();
        builder.Services.AddScoped<INotificationService, NotificationService>();
        builder.Services.AddScoped<IFacultyService, FacultyService>();
        builder.Services.AddScoped<IDashboardService, DashboardService>();
        builder.Services.AddScoped<ILabHelper, LabHelper>();
        builder.Services.AddSingleton<IKafkaProducer, KafkaProducer>();
        builder.Services.AddSingleton<IJwtTokenHelper, JwtTokenHelper>();
        builder.Services.AddControllers();

        // Add JWT Authentication
        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = builder.Configuration["JwtSettings:Issuer"],
                    ValidAudience = builder.Configuration["JwtSettings:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JwtSettings:Key"]!))
                };
            });

        builder.Services.AddAuthorization();

        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(c =>
        {
            c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                In = Microsoft.OpenApi.Models.ParameterLocation.Header,
                Description = "Enter 'Bearer' followed by a space and the token",
                Name = "Authorization",
                Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
                Scheme = "Bearer"
            });
            c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
            {
                {
                    new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                    {
                        Reference = new Microsoft.OpenApi.Models.OpenApiReference
                        {
                            Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        }
                    },
                    Array.Empty<string>()
                }
            });
        });
        FirebaseApp.Create(new AppOptions
        {
            Credential = GoogleCredential.FromFile(builder.Configuration["Firebase:credentials_path"])
        });
        var app = builder.Build();

        // add swagger
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseCors("AllowEverything");
        app.UseHttpsRedirection();
        app.UseAuthentication();
        app.UseAuthorization();
        app.MapControllers();
        app.UseStaticFiles();

        app.Run();
    }
}
