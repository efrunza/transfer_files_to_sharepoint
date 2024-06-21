using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Data.SqlClient;
using System;
using System.IO;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Graph;
using System.Collections.Generic;
using Microsoft.Graph.Models;
using Microsoft.Graph.Drives.Item.Items.Item.CreateUploadSession;
using Azure.Identity;
using System.Security.Cryptography.X509Certificates;
using System.Linq;
using System.Net.Http;
using Microsoft.Graph.Users;
using Microsoft.Graph.DeviceManagement.ManagedDevices.Item.LogCollectionRequests.Item.CreateDownloadUrl;
using Azure;
using Microsoft.SharePoint.Client;
using User = Microsoft.Graph.Models.User;

namespace Demo.AzureFunction
{
    public class UploadDocuments
    {
        private readonly IConfiguration configuration;
        private readonly GraphServiceClient graphClient;

        public IList<User> Users { get; set; }

        public UploadDocuments(GraphServiceClient graphServiceClient, IConfiguration config)
        {
            this.configuration = config;            

            this.graphClient = graphServiceClient;
        }

        [FunctionName("GetUsers")]
        public async Task<string> GetUsers(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, ILogger log)
        {
            string message = "";
            log.LogInformation("GetUsers() log started.");

            try
            {
                var azureFunctionSettings = new AzureFunctionSettings();
                this.configuration.Bind(azureFunctionSettings);

                var siteName = azureFunctionSettings.GraphSiteUrl;
                log.LogInformation($"GetUsers() site name is {siteName}.");


                var users = await this.graphClient.Users.GetAsync();
                log.LogInformation($"GetUsers() after calling users.");

                // get users from a specific site



                //var newUsers = await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Lists["e5617ed8-da2f-40a7-a9c4-972ea48368c1"].Users;

                int i = 0;

                foreach (var u in users.Value)
                {
                    i++;

                    log.LogInformation($"GetUsers() Number of users is {i}.");

                    User user = new User();
                    user.UserPrincipalName = u.UserPrincipalName;

                    log.LogInformation($"GetUsers() User principal name is {u.UserPrincipalName}.");

                    message = "users has been read successfully.";
                }
            }
            catch (Exception ex)
            {
                message = "exception has been encountered.";

                string msg = ex.Message;

                log.LogInformation($"GetUsers() exception is: {msg} ");
            }

            log.LogInformation($"GetUsers() completed fine.");

            return message;

        }

        [FunctionName("DownloadFileVersionFromSharePoint")]
        public async Task<Stream> DownloadFileVersionFromSharePoint(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, ILogger log)
        {
            log.LogInformation("DownloadFileVersionFromSharePoint() log started.");

            string fileName = req.Query["fileName"];
            string fileVersion = req.Query["fileVersion"];

            var ms = await GetFileVersionFromSharePoint(fileName, fileVersion, log);

            return ms;
        }

        [FunctionName("DownloadFileFromSharePoint")]
        public async Task<Stream> DownloadFileFromSharePoint(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, ILogger log)
        {
            log.LogInformation("DownloadFileFromSharePoint() log started.");

            string fileName = req.Query["fileName"];

            var ms = await GetFileFromSharePoint(fileName, log);

            return ms;
        }

        [FunctionName("SetCustomAttribute")]
        public async Task<IActionResult> SetCustomAttribute(
       [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, ILogger log)
        {
            log.LogInformation("UpdateCustomAttribute()");

            try
            {
                //patch request to sites/list/list-id/items/item-id/fields

                string percentage = req.Query["percentage"];

                var azureFunctionSettings = new AzureFunctionSettings();
                this.configuration.Bind(azureFunctionSettings);

                var fieldset = new FieldValueSet
                {
                    AdditionalData = new Dictionary<string, object>
                        {
                            { "CustomAttribute", percentage }
                        }
                };

                await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Lists["e5617ed8-da2f-40a7-a9c4-972ea48368c1"].Items["171"].Fields.PatchAsync(fieldset);

                return new OkObjectResult("Custom Attribute updated successfully");
            }
            catch (Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }
        }

        [FunctionName("UpdateCustomAttribute")]
        public async Task<IActionResult> UpdateCustomAttribute(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, ILogger log)
        {
            log.LogInformation("UpdateCustomAttribute()");

            try
            {
                //patch request to sites/list/list-id/items/item-id/fields

                string percentage = req.Query["percentage"];

                var azureFunctionSettings = new AzureFunctionSettings();
                this.configuration.Bind(azureFunctionSettings);

                var fieldset = new FieldValueSet
                {
                    AdditionalData = new Dictionary<string, object>
                        {
                            { "CustomAttribute", percentage }
                        }
                };

                var lists = this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Lists["e5617ed8-da2f-40a7-a9c4-972ea48368c1"];
                log.LogInformation("call Lists succeeded.");

                var items = lists.Items;
                log.LogInformation("call Items succeeded.");

                var item = items["171"];
                log.LogInformation("call item 171 succeeded.");

                var fields = item.Fields;
                log.LogInformation("call Fields succeeded.");

                await fields.PatchAsync(fieldset);
                log.LogInformation("call patch fieldset succeeded.");

                //await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Lists["e5617ed8-da2f-40a7-a9c4-972ea48368c1"].Items["171"].Fields.PatchAsync(fieldset);

                return new OkObjectResult("Custom Attribute updated successfully");
            }
            catch (Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }
        }

        [FunctionName("UploadFileToSharePoint")]
        public async Task<IActionResult> UploadFileToSharePoint(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, ILogger log)
        {
            log.LogInformation("UploadFileToSharePoint()");

            try
            {
                var formData = await req.ReadFormAsync();
                var file = formData.Files[0];               

                //get bytes from file
                byte[] bytes = new byte[file.Length];
                using (var ms = new MemoryStream())
                {
                    file.CopyTo(ms);
                    bytes = ms.ToArray();
                    ms.Position = 0;
                }                           

                // use file name to upload to SharePoint
                UploadFileToSharePoint(file.FileName, bytes, log);

                return new OkObjectResult("File uploaded successfully");
            }
            catch(Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }
        }


        [FunctionName("UploadAFileVersionToSharePoint")]
        public async Task<IActionResult> UploadAFileVersionToSharePoint(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, ILogger log)
        {
            log.LogInformation("UploadAFileVersionToSharePoint()");

            try
            {
                var formData = await req.ReadFormAsync();
                var file = formData.Files[0];

                string fileVersion = req.Query["fileVersion"];

                UploadAFileVersionToSharePoint(file.FileName, fileVersion, log);

                return new OkObjectResult("File uploaded successfully");
            }
            catch (Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }
        }

        [FunctionName("DeleteAFileVersionToSharePoint")]
        public async Task<IActionResult> DeleteAFileVersionToSharePoint(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, ILogger log)
        {
            log.LogInformation("DeleteAFileVersionToSharePoint()");

            try
            {
                var formData = await req.ReadFormAsync();
                var file = formData.Files[0];               

                string fileVersion = req.Query["fileVersion"];

                DeleteAFileVersionFromSharePoint(file.FileName, fileVersion, log);

                return new OkObjectResult("File uploaded successfully");
            }
            catch (Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }
        }

        [FunctionName("DownloadFileFromBlob")]
        public async Task<Stream> DownloadFileFromBlob(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, ILogger log)
        {
            log.LogInformation("DownloadFileFromBlob()");

            string fileName = req.Query["fileName"];

            var bytes = await GetFileFromBlob(fileName, log);

            Stream ms = new MemoryStream(bytes);
            ms.Position = 0;

            return ms;
        }

        [FunctionName("UploadFileToBlob")]
        public async Task<IActionResult> UploadFileToBlob(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, ILogger log)
        {
            log.LogInformation("UploadFileToBlob()");

            try
            {
                var formData = await req.ReadFormAsync();
                var file = formData.Files[0];

                //get bytes from file
                byte[] bytes = new byte[file.Length];
                using (var ms = new MemoryStream())
                {
                    file.CopyTo(ms);
                    bytes = ms.ToArray();
                    ms.Position = 0;
                }

                UploadFileToBlob(bytes, file.FileName, log);
                return new OkObjectResult("File uploaded successfully");
            }
            catch (Exception ex)
            {
                return new BadRequestObjectResult(ex.Message);
            }
        }              

        [FunctionName("ReadFileFromBlobUploadToSharePoint")]
        public async Task ReadFileFromBlobUploadToSharePoint(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, ILogger log)
        {
            log.LogInformation("ReadFileFromBlobUploadToSharePoint()");

            string fileName = req.Query["fileName"];

            var bytes = await GetFileFromBlob(fileName, log);

            UploadFileToSharePoint(fileName, bytes, log);
        }

        [FunctionName("ReadFileFromSQLUploadToSharePoint")]
        public Task ReadFileFromSQLUploadToSharePoint(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, ILogger log)
        {
            log.LogInformation("ReadFileFromSQLUploadToSharePoint()");

            string blobID = req.Query["blobID"];
            string fileName = req.Query["fileName"];

            var bytes = GetFileFromSQL(blobID, log);

            UploadFileToSharePoint(fileName, bytes, log);
            return Task.CompletedTask;
        }
        
        // private functions

        private async Task<Stream> GetFileVersionFromSharePoint(string fileName, string fileVersionNumber, ILogger log)
        {
            log.LogInformation("GetFileVersionFromSharePoint() Graph API");

            try
            {               
                var downloadUrl = await GetDownloadedUrl(fileName, fileVersionNumber);

                return await GetFileResponse(downloadUrl.ToString());

            }
            catch (System.Exception ex)
            {
                log.LogInformation($"The function failed with the error: {ex.Message}");
            }

            return null;            
        }

        private async Task<object> GetDownloadedUrl(string fileName, string fileVersionNumber)
        {
            var azureFunctionSettings = new AzureFunctionSettings();
            this.configuration.Bind(azureFunctionSettings);

            var drive = await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Drive.GetAsync();
            var driveID = drive.Id;

            var file = await this.graphClient.Drives[driveID].Root.ItemWithPath($"{fileName}").GetAsync();

            var fileVersion = await this.graphClient.Drives[driveID].Items[file.Id].Versions[fileVersionNumber].GetAsync();

            fileVersion.AdditionalData.TryGetValue(azureFunctionSettings.DownloadScope, out object downloadUrl);
            return downloadUrl;
        }

        private async Task<Stream> GetFileResponse(string downloadUrl)
        {
            using (var httpClient = new HttpClient())
            {
                var response = await httpClient.GetAsync(downloadUrl.ToString());
                
                return response.Content.ReadAsStream();
            }
        }

        private async Task<Stream> GetFileFromSharePoint(string fileName, ILogger log)
        {
            log.LogInformation("GetFileFromSharePoint() Graph API - Get Version");

            try
            {                               
                var azureFunctionSettings = new AzureFunctionSettings();
                this.configuration.Bind(azureFunctionSettings);
                
                var drive = await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Drive.GetAsync();
                var driveID = drive.Id;                

                var fileStream = await this.graphClient.Drives[driveID].Root.ItemWithPath($"{fileName}").Content.GetAsync();

                return fileStream;

            }
            catch (System.Exception ex)
            {
                log.LogInformation($"The function failed with the error: {ex.Message}");
            }

            return null;
        }

        private async void UploadFileToSharePoint(string fileName, byte[] fileContent, ILogger log)
        {
            log.LogInformation("UploadFileToSharePoint() Graph API");

            Stream ms = new MemoryStream(fileContent);
            ms.Position = 0;

            var azureFunctionSettings = new AzureFunctionSettings();
            this.configuration.Bind(azureFunctionSettings);         

            //var file = await this.graphClient.Drives[driveID].Root.ItemWithPath($"{fileName}").GetAsync();
            //var fileVersion = await this.graphClient.Drives[driveID].Items[file.Id].Versions["1.0"].GetAsync();

            try
            {
                log.LogInformation("UploadFileToSharePoint() Graph API - Step 1");

                var drive = await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Drive.GetAsync();
                var driveID = drive.Id;

                log.LogInformation("UploadFileToSharePoint() Graph API - Step 2");

                var uploadSessionRequestBody = new CreateUploadSessionPostRequestBody
                {                    
                    Item = new DriveItemUploadableProperties
                    {
                        AdditionalData = new Dictionary<string, object>
                        {
                            { "@microsoft.graph.conflictBehavior", "replace" },
                        },                        
                    },                    
                };

                log.LogInformation("UploadFileToSharePoint() Graph API - Step 3");

                var uploadSession = await this.graphClient.Drives[driveID].Root.ItemWithPath($"{fileName}").CreateUploadSession.PostAsync(uploadSessionRequestBody);

                log.LogInformation("UploadFileToSharePoint() Graph API - Step 4");

                int maxSliceSize = 320 * 1024 * 33; // ~10MB
                var fileUploadTask = new LargeFileUploadTask<DriveItem>(uploadSession, ms, maxSliceSize);

                log.LogInformation("UploadFileToSharePoint() Graph API - Step 5");

                var uploadResult = await fileUploadTask.UploadAsync();

                log.LogInformation("UploadFileToSharePoint() Graph API - Step 6");

            }
            catch (System.Exception ex)
            {
                log.LogInformation("UploadFileToSharePoint() Graph API - exception found.");

                log.LogError(ex.Message);
            }
        }

        private async void UploadAFileVersionToSharePoint(string fileName, string fileVersion, ILogger log)
        {
            log.LogInformation("UploadAFileVersionToSharePoint() Graph API");

            var azureFunctionSettings = new AzureFunctionSettings();
            this.configuration.Bind(azureFunctionSettings);

            var drive = await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Drive.GetAsync();
            var driveID = drive.Id;

            var file = await this.graphClient.Drives[driveID].Root.ItemWithPath($"{fileName}").GetAsync();
            var versionFile = await this.graphClient.Drives[driveID].Items[file.Id].Versions[fileVersion].GetAsync();

            try
            {
                var uploadSessionRequestBody = new CreateUploadSessionPostRequestBody
                {
                    Item = new DriveItemUploadableProperties
                    {
                        AdditionalData = new Dictionary<string, object>
                        {
                            { "@microsoft.graph.conflictBehavior", "replace" },
                        },
                    },
                };

                await this.graphClient.Drives[driveID].Items[file.Id].Versions[fileVersion].RestoreVersion.PostAsync();

            }
            catch (System.Exception ex)
            {
                log.LogError(ex.Message);
            }
        }

        private async void DeleteAFileVersionFromSharePoint(string fileName, string fileVersion, ILogger log)
        {
            log.LogInformation("DeleteAFileVersionFromSharePoint() Graph API");

            var azureFunctionSettings = new AzureFunctionSettings();
            this.configuration.Bind(azureFunctionSettings);

            var drive = await this.graphClient.Sites[azureFunctionSettings.GraphSiteUrl].Drive.GetAsync();
            var driveID = drive.Id;

            var file = await this.graphClient.Drives[driveID].Root.ItemWithPath($"{fileName}").GetAsync();
            var versionFile = await this.graphClient.Drives[driveID].Items[file.Id].Versions[fileVersion].GetAsync();

            try
            {
                var uploadSessionRequestBody = new CreateUploadSessionPostRequestBody
                {
                    Item = new DriveItemUploadableProperties
                    {
                        AdditionalData = new Dictionary<string, object>
                        {
                            { "@microsoft.graph.conflictBehavior", "replace" },
                        },
                    },
                };

                await this.graphClient.Drives[driveID].Items[file.Id].Versions[fileVersion].DeleteAsync();

            }
            catch (System.Exception ex)
            {
                log.LogError(ex.Message);
            }
        }

        private async Task<byte[]> GetFileFromBlob(string fileName, ILogger log)
        {
            log.LogInformation("GetFileFromBlob()");
           
            var cs = Environment.GetEnvironmentVariable("BlobStorage");         
            string containerName = Environment.GetEnvironmentVariable("BlobContainerName");

            try
            {
                BlobContainerClient containerClient = new BlobContainerClient(cs, containerName);

                BlobClient blobClient = containerClient.GetBlobClient(fileName);

                byte[] data;

                if (await blobClient.ExistsAsync())
                {
                    var memorystream = new MemoryStream();
                    blobClient.DownloadTo(memorystream);

                    data = memorystream.ToArray();
                    return data;
                }
            }
            catch (Exception ex)
            {
                log.LogError(ex.Message);
            }
            return null;
        }

        private void UploadFileToBlob(byte[] bytes, string fileName, ILogger log)
        {
            log.LogInformation("UploadFileToBlob()");

            var cs = Environment.GetEnvironmentVariable("BlobStorage");
            string containerName = Environment.GetEnvironmentVariable("BlobContainerName");

            BlobContainerClient containerClient = new BlobContainerClient(cs, containerName);
            containerClient.CreateIfNotExists();

            BlobClient blobClient = containerClient.GetBlobClient(fileName);

            using (var ms = new MemoryStream(bytes))
            {
                blobClient.Upload(ms, true);
            }
        }      

        private byte[] GetFileFromSQL(string blobID, ILogger log)
        {
            log.LogInformation("GetFileFromSQL()");

            var cs = this.configuration.GetConnectionString("SQLDB");
            SqlConnection connection = new SqlConnection(cs);

            SqlCommand command = new SqlCommand($"SELECT Blob_content,Blob_image FROM BlobFilesTable where ID = {blobID}", connection);

            connection.Open();

            SqlDataReader reader = command.ExecuteReader(System.Data.CommandBehavior.SequentialAccess);
            reader.Read();
            MemoryStream memory = new MemoryStream();
            long startIndex = 0;
            const int ChunkSize = 256;
            while (true)
            {
                byte[] buffer = new byte[ChunkSize];
                long retrievedBytes = reader.GetBytes(1, startIndex, buffer, 0, ChunkSize);
                memory.Write(buffer, 0, (int)retrievedBytes);
                startIndex += retrievedBytes;
                if (retrievedBytes != ChunkSize)
                    break;
            }

            byte[] data = memory.ToArray();
            memory.Dispose();
            connection.Close();

            return data;
        }

        private void UploadFileToSQL(byte[] bytes, ILogger log)
        {
            log.LogInformation("UploadFileToSQL()");

            var cs = this.configuration.GetConnectionString("SQLDB");
            using var connection = new SqlConnection(cs);

            // get the next id available from blob storage
            connection.Open();
            SqlCommand command = new SqlCommand("SELECT MAX(ID) FROM BlobFilesTable", connection);
            int nextId = (int)command.ExecuteScalar() + 1;
            command.ExecuteNonQuery();

            using var command2 = new SqlCommand("INSERT INTO BlobFilesTable VALUES (@ID, '', @FileBinary)", connection)
            {
                CommandType = System.Data.CommandType.Text,
                Parameters =
                {
                    new SqlParameter("@ID", nextId),
                    new SqlParameter("@FileBinary", bytes)
                }
            };

            command.ExecuteNonQuery();
            connection.Close();
        }
    }
}
