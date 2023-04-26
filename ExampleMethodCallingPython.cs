 private void RunPythonClassification()
    {
        var standardError = "";
        var dataString = " -83,-82,-88,-200,-200,-68,-200,-200,-200,-200";
        //" -40,-82,-88,-74,-200,-81,-90,-76,-69,-200";//" -88,-76,-82,-74,-78,-73,-78,-69,-200,-200";//" -85,-68,-84,-200,-76,-70,-78,-67,-200,-200";
        // c:/Users/dhoefs/source/repos/PythonTrilateration/RunFromSharp/PredictLocation.py

        var data =  BeaconData.GetDataForKnnClassificationAsync(SearchTextBoxValue.Trim());
        foreach (var item in data)
        {
            BeaconModel temp  = new();
            var test = item.RssiValues;
            var testDataString = ' ' + string.Join(',', test);
            testDataString = testDataString.PadLeft(1);

            var commandLineString = @$"c:/Users/dhoefs/source/repos/PythonTrilateration/RunFromSharp/PredictLocation.py -v ""{testDataString}""";
            var outputText = PythonService.ExecutePython(commandLineString, out standardError);
            var splitString = outputText.Split(",");
            temp.X = float.Parse(splitString[0]);
            temp.Y = float.Parse(splitString[1]);
            KnnResults.Add(temp);
        }

        StateHasChanged();
    }
