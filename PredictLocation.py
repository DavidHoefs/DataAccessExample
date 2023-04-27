# import libraries
import os
import sys
import time
import traceback
import argparse
import numpy as np
import pandas as pd
import pickle
from io import StringIO
from codecs import decode
import warnings
warnings.filterwarnings('ignore')

def print_exception_message(self, message_orientation="horizontal"):
    """
    print full exception message
    :param message_orientation: horizontal or vertical
    :return None
    """
    try:
        exc_type, exc_value, exc_tb = sys.exc_info()           
        file_name, line_number, procedure_name, line_code = traceback.extract_tb(exc_tb)[-1]      
        time_stamp = " [Time Stamp]: " + str(time.strftime("%Y-%m-%d %I:%M:%S %p"))
        file_name = " [File Name]: " + str(file_name)
        procedure_name = " [Procedure Name]: " + str(procedure_name)
        error_message = " [Error Message]: " + str(exc_value)       
        error_type = " [Error Type]: " + str(exc_type)                   
        line_number = " [Line Number]: " + str(line_number)               
        line_code = " [Line Code]: " + str(line_code)
        if (message_orientation == "horizontal"):
            print( "An error occurred:{};{};{};{};{};{};{}".format(time_stamp, file_name, procedure_name, error_message, error_type, line_number, line_code))
        elif (message_orientation == "vertical"):
            print( "An error occurred:\n{}\n{}\n{}\n{}\n{}\n{}\n{}".format(time_stamp, file_name, procedure_name, error_message, error_type, line_number, line_code))                    
    except:
        pass

def main(dataToPredict):
    try:
        loaded_model = pickle.load(open('C:\\Users\\dhoefs\\source\\repos\\PythonTrilateration\\v2\\baggedwknnpicklefile', 'rb'))
        loaded_scaler = pickle.load(open('C:\\Users\\dhoefs\\source\\repos\\PythonTrilateration\\v2\\knnscalerpickle', 'rb'))
        dataToPredict = dataToPredict.lstrip()
        df = pd.read_csv(StringIO(dataToPredict), sep=',', header=None)
        dataToPredict = np.array(df)

        dataToPredict = loaded_scaler.transform(dataToPredict)
        outputResult = loaded_model.predict(dataToPredict)


        print(str(outputResult[0,0]) + ',' + str(outputResult[0,1]))

    except:
        print('Error')
        print_exception_message()
        
if __name__ == '__main__':
    argParse = argparse.ArgumentParser(description='Predict X/Y location of lot based on RSSI values')
    argParse.add_argument('-v','--values',help='A comma seperated list of RSSI values for beacon')
    arguments = argParse.parse_args()
    rssiValues = arguments.values
    rssiValues = decode(rssiValues,'unicode_escape')
    main(rssiValues)
