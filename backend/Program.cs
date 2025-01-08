using MongoDB.Driver;
using backend.Services;
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

builder.Services.AddScoped<UserService>();
builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// add swagger
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.MapControllers();

app.Run();
