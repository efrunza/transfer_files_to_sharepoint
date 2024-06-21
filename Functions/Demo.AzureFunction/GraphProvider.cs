using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Azure.Identity;
using Microsoft.Graph;
using System.Security.Cryptography.X509Certificates;
using System;
using System.Linq;
using Microsoft.Online.SharePoint.TenantAdministration;
using Azure.Security.KeyVault.Secrets;

namespace Demo.AzureFunction
{
    public static class GraphProvider
    {
        public static string TenantId { get; set; }
        public static string ClientId { get; set; }
        public static string SiteName { get; set; }
        public static string SiteUrl { get; set; }
        public static string CertificateThumbprint { get; set; }
        public static string GraphScopes { get; set; }
        public static string DownloadScope { get; set; }

        public static void LoadConfiguration(IConfiguration configuration)
        {
            var settings = new AzureFunctionSettings();
            configuration.Bind(settings);

            TenantId = settings.TenantId;
            ClientId = settings.ClientId;
            SiteName = settings.SiteName;
            SiteUrl = settings.SiteUrl;
            GraphScopes = settings.GraphScopes;
            DownloadScope = settings.DownloadScope;
            CertificateThumbprint = settings.CertificateThumbprint;
        }       

        public static IServiceCollection ConfigureGraphClient(this IServiceCollection services, IConfiguration configuration)
        {
            LoadConfiguration(configuration);

            // Create the Graph service client with a ChainedTokenCredential which gets an access
            // token using the available Managed Identity or environment variables if running
            // in development.
            var credential = new ChainedTokenCredential(
                new ManagedIdentityCredential(),
                new EnvironmentCredential());

            string[] scopes = new[] { "https://graph.microsoft.com/.default" };

            var graphServiceClient = new GraphServiceClient(credential, scopes);

            /*

            var scopes = new[] { "https://graph.microsoft.com/.default" };

            //var clientCertificate = LoadCertificate(CertificateThumbprint);

            // using Azure.Identity;
            var options = new ClientCertificateCredentialOptions
            {
                AuthorityHost = AzureAuthorityHosts.AzurePublicCloud,
    
            };

            //var clientCredential = new ClientCertificateCredential(TenantId, ClientId, clientCertificate, options);

            var clientCredential = new ClientSecretCredential(TenantId, ClientId, "", options);  

            var graphClient = new GraphServiceClient(clientCredential, scopes);
            */
            
            services.AddScoped(sp =>
            {
                //return new GraphServiceClient(clientCredential, scopes);

                return graphServiceClient;
            });            

            return services;
        }

        private static X509Certificate2 LoadCertificate(string certificateThumbprint)
        {
            string certBase64Encoded = Environment.GetEnvironmentVariable("CertificateFromKV");

            if (!string.IsNullOrEmpty(certBase64Encoded))
            {
                // Azure Function flow
                return new X509Certificate2(Convert.FromBase64String(certBase64Encoded),
                                            "",
                                            X509KeyStorageFlags.Exportable |
                                            X509KeyStorageFlags.MachineKeySet |
                                            X509KeyStorageFlags.EphemeralKeySet);
            }
            else
            {
                var store = new X509Store(StoreName.My, StoreLocation.LocalMachine);
                store.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);
                var certificateCollection = store.Certificates.Find(X509FindType.FindByThumbprint, certificateThumbprint, false);
                store.Close();

                var firstCertificate = certificateCollection.First();

                return firstCertificate;
            }
        }

    }
}
