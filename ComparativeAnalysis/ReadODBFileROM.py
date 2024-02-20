# Import necessary modules from Abaqus and standard Python libraries
from abaqus import *
import xyPlot
import visualization

import os
import sys

def ReadODBFileROM(LoadName): # RoM-data
    # Construct job name and report file name based on the load name provided
    job_name = 'Job' + LoadName
    rpt_name = './ResultsFiles/AbaqusResults' + LoadName + 'ROM.rpt'

    # If the report file already exists, delete it to prevent appending to old data
    if os.path.exists(rpt_name):
        os.remove(rpt_name)

    # Open the ODB (output database) file for the specified job and set it as the displayed object in the viewport
    o1 = session.openOdb(name=job_name + '.odb')
    session.viewports['Viewport: 1'].setValues(displayedObject=o1)
    odb = session.odbs[job_name + '.odb']
    # Extract XY data for rotational displacements at specified node and direction
    # UR1: Rotational displacement around X-axis
    xy1 = xyPlot.XYDataFromHistory(odb=odb, 
    outputVariableName='Rotational displacement: UR1 PI: rootAssembly Node 1 in NSET RP-LOAD', 
    suppressQuery=True, __linkedVpName__='Viewport: 1')
    c1 = session.Curve(xyData=xy1)
    # UR2: Rotational displacement around Y-axis
    xy2 = xyPlot.XYDataFromHistory(odb=odb, 
    outputVariableName='Rotational displacement: UR2 PI: rootAssembly Node 1 in NSET RP-LOAD', 
    suppressQuery=True, __linkedVpName__='Viewport: 1')
    c2 = session.Curve(xyData=xy2)
    # UR3: Rotational displacement around Z-axis
    xy3 = xyPlot.XYDataFromHistory(odb=odb, 
    outputVariableName='Rotational displacement: UR3 PI: rootAssembly Node 1 in NSET RP-LOAD', 
    suppressQuery=True, __linkedVpName__='Viewport: 1')
    c3 = session.Curve(xyData=xy3)
    # Create an XY plot and configure it to display the extracted data
    xyp = session.XYPlot('XYPlot-1')   
    chartName = xyp.charts.keys()[0]
    chart = xyp.charts[chartName]
    chart.setValues(curvesToPlot=(c1, c2, c3, ), )
    session.viewports['Viewport: 1'].setValues(displayedObject=xyp)
    # Retrieve temporary XY data objects for report generation
    x0 = session.xyDataObjects['_temp_' + str(1)]
    x1 = session.xyDataObjects['_temp_'+ str(2)]
    x2 = session.xyDataObjects['_temp_'+ str(3)]
    # Set report options (e.g., number format) and generate the report file with the extracted data
    session.xyReportOptions.setValues(numberFormat=AUTOMATIC)
    session.writeXYReport(fileName=rpt_name, xyData=(x0, x1, x2))
    # Clean up temporary data objects
    del x0 
    del x1
    del x2    

# Main execution block: reads the load name from command line arguments and calls the function to process the ODB file
if __name__ == '__main__':

    LoadName = sys.argv[-1] # Retrieves the last argument: LoadName
    ReadODBFileROM(LoadName)