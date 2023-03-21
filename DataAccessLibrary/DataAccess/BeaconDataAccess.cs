using DataAccessLibrary.DataAccess.Internal;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DataAccessLibrary.Models;

namespace DataAccessLibrary.DataAccess
{
    public class BeaconDataAccess : IBeaconDataAccess
    {
        private readonly ISqlDataAccess _sql;

        public BeaconDataAccess(ISqlDataAccess sql)
        {
            _sql = sql;
        }

        public async Task<List<BeaconModel>> GetBeaconDataAsync(string beaconName)
        {
            return await _sql.LoadDataAsync<BeaconModel, dynamic>("dbo.LMS_GetBeaconDataByName",
                new { BeaconName = beaconName }, "xpertloc");
        }

        public void AddReader(BeaconModel beaconModel)
        {
            _sql.SaveDataAsync("dbo.LMS_AddReaderLocation", new { beaconModel.ReaderName, beaconModel.X, beaconModel.Y },
                "xpertloc");
        }
    }
}
