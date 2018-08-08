# jermyn-toolbox
Classification, machine learning, and data visualization toolbox

This is an open-source Matlab toolbox for machine learning, classification, and data visualization.

Installation:

1. Download and unzip the toolbox.
2. In Matlab, go to Set Path -> Add With Subfolders, choose the folder you unzipped, and Save.

Use:

Type "jclassify" (without quotes) in Matlab to launch the classification and machine learning tool.

Type "jviz" (without quotes) in Matlab to launch the data visualization tool.

jclassify takes two primary inputs, a data matrix, and classes vector. The data matrix consists of one row per data sample, where each column is a feature. The classes vector indicates the class for each data sample. As long as these variables are in the Matlab workspace when you launch jclassify, it will automatically detect them and make them available for selection in the drop-down menus.