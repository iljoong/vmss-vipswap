using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

namespace webapi
{
    // Implemented Singleton EventHubClient

    public interface IPingManager
    {
        string GetVMName();
        string GetSlotName();

        string GetFileVersion();
    }

    public class PingManager : IPingManager
    {
        string _vmname = "_NONAME_";
        string _slot = "_SLOT_";
        string _fileversion = "_0_";

        public PingManager(IConfiguration _config)
        {
            _fileversion = FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location).ProductVersion;

            // get VMName using metadataservice
            //curl.exe -H Metadata:true http://169.254.169.254/metadata/instance/compute?api-version=2019-06-04

            //_vmname = "workload-prod-vmss-slot0_000";
            _vmname = GetIMDS().Result;

            var vals = _vmname.Split("-");
            string hostslot = vals.Last();
            _slot = hostslot.Substring(0, 5);
        }

        ~PingManager()
        {
        }

        public string GetVMName()
        {
            return _vmname;
        }

        public string GetSlotName()
        {
            return _slot;
        }

        public string GetFileVersion()
        {
            return _fileversion;
        }

        // GET Azure VM Name using IMDS
        public async Task<string> GetIMDS()
        {
            try
            {
                using (var client = new HttpClient())
                {
                    client.BaseAddress = new Uri("http://169.254.169.254");
                    var request = new HttpRequestMessage(HttpMethod.Get, "metadata/instance/compute?api-version=2019-06-04");

                    client.DefaultRequestHeaders.Add("Metadata", "true");
                    var response = await client.SendAsync(request);

                    var res = await response.Content.ReadAsStringAsync();
                    var imds = JsonConvert.DeserializeObject<IMDS>(res);

                    return imds.name;

                }
            }
            catch
            {
                return "workload-prod-vmss-slotX";
            }
        }

    }

    public class IMDS
    {
        public string name { get; set; }
        public string vmScaleSetName { get; set; }
        public string location { get; set; }
        public string vmId { get; set; }
        public string vmSize { get; set; }

    }


}