using System.Diagnostics;

namespace LMSLibrary.Services;

/// <summary>
///     Executes a python script from the command line.
/// </summary>
public class PythonService : IPythonService
{
    public readonly string PythonExePath = "C:/Users/dhoefs/AppData/Local/Programs/Python/Python310/python.exe";

    public string ExecutePython(string pythonScript, out string standardError)
    {
        standardError = string.Empty;
        var outputText = string.Empty;

        try
        {
            using Process process = new();
            process.StartInfo = new ProcessStartInfo(PythonExePath)
            {
                Arguments = pythonScript,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };

            process.Start();
            outputText = process.StandardOutput.ReadToEnd();
            outputText = outputText.Replace(Environment.NewLine, string.Empty);
            standardError = process.StandardError.ReadToEnd();

            process.WaitForExit();
        }
        catch (Exception ex)
        {
            var exceptionMessage = ex.Message;
        }

        return outputText;
    }
}