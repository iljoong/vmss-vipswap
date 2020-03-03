using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Net;

namespace webapi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PingController : ControllerBase
    {

        private readonly IPingManager _pingManager;

        private readonly ILogger<PingController> _logger;

        public PingController(ILogger<PingController> logger, IPingManager pingManager)
        {
            _logger = logger;
            _pingManager = pingManager;
        }

        [HttpGet("/api/ping")]
        public ActionResult Ping([FromQuery]string slot)
        {
            string slotname = _pingManager.GetSlotName();

            _logger.LogInformation($"{slot}=={slotname}");

            if (slot == slotname)
                return Ok();
            else
                return NotFound();
        }

        [HttpGet("/api/test")]
        public string GetTest()
        {
            string hostname = Dns.GetHostName();
            string slotname =_pingManager.GetSlotName();
            return $"{hostname}: {slotname}";
        }

        [HttpGet("/")]
        public ActionResult GetDefault()
        {
            return Ok();
        }

    }
}
