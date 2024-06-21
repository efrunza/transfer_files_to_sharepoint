using Microsoft.ApplicationInsights.WorkerService;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

[assembly: FunctionsStartup(typeof(Demo.AzureFunction.Startup))]

namespace Demo.AzureFunction
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var config = builder.GetContext().Configuration;

            using (var provider = builder.Services.BuildServiceProvider())
            {
                builder.Services.AddApplicationInsightsTelemetryWorkerService();
                
                builder.Services.AddLogging(logBuilder => logBuilder.AddApplicationInsights());          
                
                builder.Services.ConfigureGraphClient(config);                
            }
        }
    }
}