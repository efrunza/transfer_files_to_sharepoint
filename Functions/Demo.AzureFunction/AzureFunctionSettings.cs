﻿using System;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using System.Text;

namespace Demo.AzureFunction
{
    class AzureFunctionSettings
    {
        public string SiteUrl { get; set; }
        public string TenantId { get; set; }
        public string ClientId { get; set; }
        public string SiteName { get; set; }
        public StoreName CertificateStoreName { get; set; }
        public StoreLocation CertificateStoreLocation { get; set; }
        public string CertificateThumbprint { get; set; }
        
        public string GraphSiteUrl { get; set; }
        public string GraphScopes { get; set; }

        public string DownloadScope { get; set; }

    }
}
