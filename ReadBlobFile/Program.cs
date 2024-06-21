
using Aspose.Words;
using Aspose.Words.XAttr;
using Aspose.Pdf;
using DiffMatchPatch;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using System;
using System.Net.Http.Headers;
using System.Runtime.Intrinsics.Arm;
using System.Security.Cryptography.X509Certificates;
using static System.Runtime.InteropServices.JavaScript.JSType;
using Aspose.Pdf.Text;
using Aspose.Words.Pdf2Word.FixedFormats;
using Aspose.Pdf.Devices;
using System.Text;
using static System.Net.WebRequestMethods;

public static partial class Program
{   
    private static IConfiguration? Configuration { get; set; }

    private static async Task Main(string[] args)
    {
        var builder = new ConfigurationBuilder()
        .SetBasePath(Directory.GetCurrentDirectory())
        .AddJsonFile("appsettings.json");

        Configuration = builder.Build();

        // 

        // await UploadFileToSharePoint(Configuration);

        //await DownloadFile();

        await CompareFileVersions();

        /*
        await UploadFileToBlob(Configuration);

        var bytes2 = await DownloadFileFromBlob(Configuration);
        if (bytes2 != null)
        {
            var fileCreated2 = Configuration["Parameters:FileCreated2"];
            if (fileCreated2 != null)
            {
                CreateFileToFileSystem(fileCreated2, bytes2);
            }
        }
        

        UploadFileToSQL(Configuration);

        var bytes3 = RetrieveFileFromSQL(Configuration);
        if (bytes3 != null)
        {
            var fileCreated3 = Configuration["Parameters:FileCreated3"];
            if (fileCreated3 != null)
            {
                CreateFileToFileSystem(fileCreated3, bytes3);
            }
        }
        */

    }

    private static async Task DownloadFile()
    {
        var bytes1 = await DownloadFileFromSharePoint(Configuration);

        if (bytes1.Length == 0)
        {
            Console.WriteLine("The downloaded file is empty");
        }
        else
        {
            var fileCreated1 = Configuration["Parameters:FileCreated1"];
            if (fileCreated1 != null)
            {
                CreateFileToFileSystem(fileCreated1, bytes1);
            }

            Console.WriteLine("Files uploaded, downloaded, and created successfully");
        }
    }

    static async Task CompareFileVersions()
    {
        var filePath1 = "C:\\Work_SharePoint\\testFiles\\fileVersion\\SharePoint POC.docx";

        //var filePath1 = "C:\\Work_SharePoint\\testFiles\\fileVersion\\example.pdf";

        Aspose.Words.Document doc1 = new Aspose.Words.Document(filePath1);

        //var doc1 = new Aspose.Pdf.Document(filePath1);

        var fileContent1 = doc1.GetText();

        /*
        TextAbsorber textAbsorber = new TextAbsorber();
        // Accept the absorber for all the pages
        doc1.Pages.Accept(textAbsorber);
        // Get the extracted text
        string fileContent1 = textAbsorber.Text;
        */

        //decimal doc1WordsCountTest = GetPdfWordsCount(doc1);

        var bytes2 = await DownloadFileVersionFromSharePoint(Configuration);

        // calculate percentage of deleted words
        var percentage = "100";

        if (bytes2.Length == 0)
        {
            Console.WriteLine("The downloaded file version is empty");
        }
        else
        {
            Aspose.Words.Document doc2 = new Aspose.Words.Document(new MemoryStream(bytes2));

            //Aspose.Pdf.Document doc2 = new Aspose.Pdf.Document(new MemoryStream(bytes2));

            var fileContent2 = doc2.GetText();

            /*

            doc1.Pages.Accept(textAbsorber);
            // Get the extracted text
            string fileContent2 = textAbsorber.Text;

            */

            diff_match_patch dmp = new diff_match_patch();
            List<Diff> diff = dmp.diff_main(fileContent1, fileContent2);

            dmp.diff_cleanupSemantic(diff);

            decimal deleteCount = 0;
            decimal insertCount = 0;
            for (int i = 0; i < diff.Count; i++)
            {
                //Console.WriteLine(diff[i]);

                if (diff[i].operation == Operation.DELETE)
                {
                    deleteCount++;
                }

                if (diff[i].operation == Operation.INSERT)
                {
                    insertCount++;
                }
            }

            Console.WriteLine($"Number of words deleted: {deleteCount}");
            Console.WriteLine($"Number of words inserted: {insertCount}");

            decimal doc1WordsCount = doc1.BuiltInDocumentProperties.Words;
            decimal doc2WordsCount = doc2.BuiltInDocumentProperties.Words;

            //decimal doc1WordsCount = GetPdfWordsCount(doc1);
            //decimal doc2WordsCount = GetPdfWordsCount(doc2);

            var result = 0.0;
            bool lessThan10PercentChanged = false;
            if (doc1WordsCount > doc2WordsCount)
            {
                result = (double)((doc1WordsCount - doc2WordsCount) / doc1WordsCount);
                if (result <= 1)
                {
                    result = result * 100;

                    if (result <= 10)
                    {
                        lessThan10PercentChanged = true;
                    }
                }

                Console.WriteLine($"The document has been reduced with {result} percent");
            }
            else
            {
                result = (double)((doc2WordsCount - doc1WordsCount) / doc1WordsCount);
                if (result <= 1)
                {
                    result = result * 100;

                    if (result <= 10)
                    {
                        lessThan10PercentChanged = true;
                    }
                }

                Console.WriteLine($"The document has been increased with {result} percent");
            }

            if (lessThan10PercentChanged)
            {
                percentage = Math.Round((deleteCount / doc1WordsCount), 2).ToString("");
                Console.WriteLine($"The document has been changed {percentage} percent");
            }
        }


        // update custom field in SharePoint with the percentage of deleted words
        await UpdateCustomAttribute(Configuration, percentage);
    }

    static int GetPdfWordsCount(Aspose.Pdf.Document pdfDocument)
    {
        System.Text.StringBuilder builder = new System.Text.StringBuilder();

        //string to hold extracted text

        string extractedText = "";

        foreach (Page pdfPage in pdfDocument.Pages)
        {
            using (MemoryStream textStream = new MemoryStream())
            {
                //create text device
                TextDevice textDevice = new TextDevice();

                //set text extraction options - set text extraction mode (Raw or Pure)
                var textExtOptions = new
                Aspose.Pdf.Text.TextExtractionOptions(Aspose.Pdf.Text.TextExtractionOptions.TextFormattingMode.Pure);
                textDevice.ExtractionOptions = textExtOptions;

                //convert a particular page and save text to the stream

                textDevice.Process(pdfPage, textStream);

                //close memory stream

                textStream.Close();

                //get text from memory stream
                extractedText = Encoding.Unicode.GetString(textStream.ToArray());
            }

            builder.Append(extractedText);
        }

        // get the list of individual word with space as separator
        IList<string> words = builder.ToString().Split(' ');

        return words.Count;
    }

    static async Task UploadFileToSharePoint(IConfiguration configuration)
    {
        var fileUploaded = configuration["Parameters:FileUploaded"];
        var webAPIAddress = configuration["Parameters:UploadFileURL1"];

        if (fileUploaded != null && webAPIAddress != null)
        {
            await CommonUploadToWebAPI(configuration, fileUploaded, webAPIAddress);
        }
    }

    static async Task<byte[]> DownloadFileVersionFromSharePoint(IConfiguration configuration)
    {
        var fileName = configuration["Parameters:FileDownloadedFromSharePoint"];
        var certificateFileName = configuration["Parameters:CertificateFileName"];
        var certificatePassword = configuration["Parameters:CertificatePassword"];
        var downloadSharePointFileVersionURL = configuration["Parameters:DownloadSharePointVersionFileURL"];
        var ocpKey = configuration["Parameters:OcpKey"];

        var cert = certificateFileName != null ? new X509Certificate2(certificateFileName, certificatePassword) : throw new ArgumentNullException(nameof(certificateFileName));

        var handler = new HttpClientHandler();
        handler.ClientCertificates.Add(cert);

        var client = new HttpClient(handler);

        // &fileName= for the Azure web api
        // ?fileName= for the APIM

        var request = new HttpRequestMessage()
        {
            RequestUri = new Uri($"{downloadSharePointFileVersionURL}?fileName={fileName}&fileVersion=7.0"),
            Method = HttpMethod.Get
        };

        request.Headers.Add("Ocp-Apim-Subscription-Key", ocpKey);

        var response = await client.SendAsync(request);

        if (response.IsSuccessStatusCode)
        {
            //Console.WriteLine("SharePoint file downloaded successfully");

            var responseContent = await response.Content.ReadAsStreamAsync();

            byte[] data;

            using var memoryStream = new MemoryStream();
            responseContent.CopyTo(memoryStream);
            data = memoryStream.ToArray();

            return data;
        }
        else
        {
            throw new FileNotFoundException();
        }
    }
    static async Task<byte[]> DownloadFileFromSharePoint(IConfiguration configuration)
    {
        var fileName = configuration["Parameters:FileDownloadedFromSharePoint"];
        var certificateFileName = configuration["Parameters:CertificateFileName"];
        var certificatePassword = configuration["Parameters:CertificatePassword"];
        var downloadSharePointFileURL = configuration["Parameters:DownloadSharePointFileURL"];
        var ocpKey = configuration["Parameters:OcpKey"];

        var cert = certificateFileName != null ? new X509Certificate2(certificateFileName, certificatePassword) : throw new ArgumentNullException(nameof(certificateFileName));

        var handler = new HttpClientHandler();
        handler.ClientCertificates.Add(cert);

        var client = new HttpClient(handler);

        // &fileName= for the Azure web api
        // ?fileName= for the APIM

        var request = new HttpRequestMessage()
        {
            RequestUri = new Uri($"{downloadSharePointFileURL}?fileName={fileName}"),
            Method = HttpMethod.Get
        };

        request.Headers.Add("Ocp-Apim-Subscription-Key", ocpKey);

        var response = await client.SendAsync(request);

        if (response.IsSuccessStatusCode)
        {
            //Console.WriteLine("SharePoint file downloaded successfully");

            var responseContent = await response.Content.ReadAsStreamAsync();

            byte[] data;

            using var memoryStream = new MemoryStream();
            responseContent.CopyTo(memoryStream);
            data = memoryStream.ToArray();

            return data;
        }
        else
        {
            throw new FileNotFoundException();
        }
    }

    static async Task UploadFileToBlob(IConfiguration configuration)
    {
        var filePath = configuration["Parameters:FileUploaded"];
        var webAPIAddress = configuration["Parameters:UploadFileURL2"];

        if (filePath != null && webAPIAddress != null)
        {
            await CommonUploadToWebAPI(configuration, filePath, webAPIAddress);
        }
    }

    static async Task<byte[]> DownloadFileFromBlob(IConfiguration configuration)
    {
        var fileName = configuration["Parameters:FileDownloadedFromBlob"];
        var downloadBlobFileURL = configuration["Parameters:DownloadBlobFileURL"];
        var ocpKey = configuration["Parameters:OcpKey"];
        var certificateFileName = configuration["Parameters:CertificateFileName"];
        var certificatePassword = configuration["Parameters:CertificatePassword"];

        var cert = certificateFileName != null ? new X509Certificate2(certificateFileName, certificatePassword) : throw new ArgumentNullException(nameof(certificateFileName));

        var handler = new HttpClientHandler();
        handler.ClientCertificates.Add(cert);

        var client = new HttpClient(handler);

        // &fileName= for the Azure web api
        // ?fileName= for the APIM

        var request = new HttpRequestMessage()
        {
            RequestUri = new Uri($"{downloadBlobFileURL}?fileName={fileName}"),
            Method = HttpMethod.Get
        };

        request.Headers.Add("Ocp-Apim-Subscription-Key", ocpKey);

        var response = await client.SendAsync(request);

        if (response.IsSuccessStatusCode)
        {
            Console.WriteLine("Blob file downloaded successfully");

            var responseContent = await response.Content.ReadAsStreamAsync();

            byte[] data;

            using var memoryStream = new MemoryStream();
            responseContent.CopyTo(memoryStream);
            data = memoryStream.ToArray();

            return data;
        }
        else
        {
            throw new FileNotFoundException();
        }
    }

    static async Task UpdateCustomAttribute(IConfiguration configuration, string customAttribute)
    {
        var certificateFileName = configuration["Parameters:CertificateFileName"];
        var certificatePassword = configuration["Parameters:CertificatePassword"];
        var ocpKey = configuration["Parameters:OcpKey"];
        var UpdateCustomAttributeURL = configuration["Parameters:UpdateCustomAttributeURL"];

        var cert = certificateFileName != null ? new X509Certificate2(certificateFileName, certificatePassword) : throw new ArgumentNullException(nameof(certificateFileName));

        var handler = new HttpClientHandler();
        handler.ClientCertificates.Add(cert);

        var client = new HttpClient(handler);

        var request = new HttpRequestMessage()
        {
            RequestUri = new Uri($"{UpdateCustomAttributeURL}?percentage={customAttribute}"),
            Method = HttpMethod.Get
        };

        request.Headers.Add("Ocp-Apim-Subscription-Key", ocpKey);

        try
        {
            var response = await client.SendAsync(request);

            if (response.IsSuccessStatusCode)
            {
                Console.WriteLine("Custom Attribute uploaded successfully");
            }
            else
            {
                Console.WriteLine("Problems have been encountered when updating the custom attribute.");
            }
        }
        catch(Exception ex)
        {
            Console.WriteLine(ex.Message);
        }      
    }

    static async Task CommonUploadToWebAPI(IConfiguration configuration, string filePath, string webAPIAddress)
    {
        var certificateFileName = configuration["Parameters:CertificateFileName"];
        var certificatePassword = configuration["Parameters:CertificatePassword"];
        var ocpKey = configuration["Parameters:OcpKey"];
        var webAPIURL = configuration["Parameters:WebAPIURL"];

        using var form = new MultipartFormDataContent();
        using var fileContent = new ByteArrayContent(await System.IO.File.ReadAllBytesAsync(filePath));
        fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse("multipart/form-data");

        // here it is important that the second parameter matches with the name given in the API.
        form.Add(fileContent, "formFile", Path.GetFileName(filePath));

        var cert = certificateFileName != null ? new X509Certificate2(certificateFileName, certificatePassword) : throw new ArgumentNullException(nameof(certificateFileName));

        var handler = new HttpClientHandler();
        handler.ClientCertificates.Add(cert);

        var client = new HttpClient(handler);

        var request = new HttpRequestMessage()
        {
            RequestUri = new Uri($"{webAPIURL}{webAPIAddress}"),
            Content = form,
            Method = HttpMethod.Post
        };

        request.Headers.Add("Ocp-Apim-Subscription-Key", ocpKey);

        var response = await client.SendAsync(request);

        if (response.IsSuccessStatusCode)
        {
            Console.WriteLine("File uploaded call was made successfully");
        }
    }

    static void UploadFileToSQL(IConfiguration configuration)
    {
        var fileName = configuration["Parameters:FileUploaded"];

        if (!string.IsNullOrEmpty(fileName))
        {
            using var file = new FileStream(fileName, FileMode.Open, FileAccess.Read);
            byte[] bytes = new byte[file.Length];
            file.Read(bytes, 0, (int)file.Length);

            InsertFileToSQL(configuration, bytes);
        }
        else
        {
            throw new ArgumentNullException(nameof(fileName));
        }
    }

    static void InsertFileToSQL(IConfiguration configuration, byte[] bytes)
    {
        var sqlConnectionString = configuration["Parameters:SqlConnectionString"];

        using var connection = new SqlConnection(sqlConnectionString);

        using var command = new SqlCommand("INSERT INTO BlobFilesTable VALUES (6, '', @FileBinary)", connection);
        command.Parameters.AddWithValue("@FileBinary", bytes);

        connection.Open();

        command.ExecuteNonQuery();
    }

    static byte[] RetrieveFileFromSQL(IConfiguration configuration)
    {
        var blobID = configuration["Parameters:BlobID"];
        var sqlConnectionString = configuration["Parameters:SqlConnectionString"];

        using var connection = new SqlConnection(sqlConnectionString);

        using var command = new SqlCommand($"SELECT Blob_content,Blob_image FROM BlobFilesTable where ID = {blobID}", connection);

        connection.Open();

        using var reader = command.ExecuteReader(System.Data.CommandBehavior.SequentialAccess);
        reader.Read();
        using var memory = new MemoryStream();
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

        connection.Close();
        byte[] data = memory.ToArray();
        memory.Dispose();
        return data;
    }

    static void CreateFileToFileSystem(string filePath, byte[] bytes)
    {
        using var file = new FileStream(filePath, FileMode.Create, FileAccess.Write);
        file.Write(bytes, 0, bytes.Length);
    }
    
}
