using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccessLibrary.Models
{
    public class BeaconModel
    {
        public int Id { get; set; }
        public string? BeaconName { get; set; }
        public string? ReaderName { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public int Obsolete { get; set; }
        public float Distance { get; set; }
        public float Rssi { get; set; }
        public DateTime LastDT { get; set; }
    }
}
