namespace LMSLibrary.Services;

public interface IPythonService
{
    string ExecutePython(string pythonScript, out string standardError);
}