using WorkerServiceTest;

var builder = Host.CreateApplicationBuilder(new HostApplicationBuilderSettings
{
    ContentRootPath = AppContext.BaseDirectory
});

builder.Services.AddHostedService<Worker>();


builder.Services.AddWindowsService(options =>
{
    options.ServiceName = "Worker Service Test";
});

var host = builder.Build();
host.Run();
