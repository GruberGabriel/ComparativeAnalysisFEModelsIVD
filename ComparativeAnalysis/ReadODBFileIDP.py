# Import necessary modules from Abaqus and standard Python libraries
from abaqus import *
import xyPlot
import visualization

import os
import sys

def ReadODBFileIDP(LoadName): # IDP-data
    # Construct job name and report file name based on the load name provided
    job_name = 'Job' + LoadName
    rpt_name = './ResultsFiles/AbaqusResults' + LoadName + 'IDP.rpt'

    # Determine element ID based on model
    if 'HGO' in LoadName:
        eID = 12043
    else:
        eID = 13051

    # Remove existing report file if it exists to avoid appending to old data
    if os.path.exists(rpt_name):
        os.remove(rpt_name)

    # Open the ODB file and set the viewport to display the opened ODB
    o1 = session.openOdb(name=job_name + '.odb')
    session.viewports['Viewport: 1'].setValues(displayedObject=o1)
    odb = session.odbs[job_name + '.odb']
    # Initialize variables for tracking maximum pressure value
    max = 0
    i = 1

    # Loop through 27 integration points (quadratic hexaeder) to find the maximum pressure value
    for j in range(1,28):
        # Construct output variable name for pressure at specific integration point
        ovName = 'SINV: PRESS PI: IVD_L4L5 Element ' + str(eID) + ' Int Point ' + str(j) + ' in ELSET NP-CENTER'
        # Retrieve XY data for the specified output variable
        xy1 = xyPlot.XYDataFromHistory(odb=odb, 
        outputVariableName=ovName, 
        suppressQuery=True, __linkedVpName__='Viewport: 1')
        c1 = session.Curve(xyData=xy1)

        # Create an XY plot and set it to display the retrieved data
        xyp = session.XYPlot('XYPlot-' + str(i))   
        chartName = xyp.charts.keys()[0]
        chart = xyp.charts[chartName]
        chart.setValues(curvesToPlot=(c1, ), )
        session.viewports['Viewport: 1'].setValues(displayedObject=xyp)

        # Temporary variable to hold current data set
        x0 = session.xyDataObjects['_temp_' + str(i)]
        # Update maximum pressure value and corresponding integration point ID if current value is greater
        if x0[-1][1] > max:
            max = x0[-1][1]
            maxID = j
            x = x0                
        elif abs(x0[-1][1] ) > max:
            max2 = x0[-1][1]
            x2 = x0
        # Clean up temporary data 
        del x0
        i = i +1
    # If no maximum value found, fallback to the second highest value
    if max == 0:
        x = x2
    # Set report options and write the data to the specified report file
    session.xyReportOptions.setValues(numberFormat=AUTOMATIC)
    session.writeXYReport(fileName=rpt_name, xyData=(x))
    # Clean up the final dataset
    del x

# Main execution block: reads the load name from command line arguments and calls the function to process the ODB file
if __name__ == '__main__':

    LoadName = sys.argv[-1] # Retrieves the last argument: LoadName
    ReadODBFileIDP(LoadName)