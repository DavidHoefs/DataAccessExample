using DataAccessLibrary.Models;

namespace DataAccessLibrary.DataAccess;

public interface IBeaconDataAccess
{
    Task<List<BeaconModel>> GetBeaconDataAsync(string beaconName);
    void AddReader(BeaconModel beaconModel);
}