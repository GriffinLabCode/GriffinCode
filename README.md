# Griffin Lab Code

Welcome to the Griffin lab online library for custom written scripts and functions used to
analyze our data! :) This page was primarily created as an online protocol for file conversion 
routines and as a back-up storage cloud for analysis code.

_________________________________________________________________________________________________________

SOME IMPORTANT NOTES ON CONVERSION: 
Our lab records neural activity using the neuralynx (digitalynx) hardware and cheetah software.
CSC and video-tracking data are converted using neuralynx functions and are not provided in this
library, despite being used by some functions. You can find them in the griffin lab drive here:

~~~ 
Lab Procedures and Protocols\MATLABToolbox\Nlx2Mat
~~~

Note that when you save CSC and VT data to a directory, you should not change that directory. For example,
if you save CSC1.mat to directory A, but then move CSC1.mat to directory B, you will have to go through some
loops to load CSC1.mat. It's easier to keep the CSC and VT1.mat files in the directories where you converted them.

TO BEGIN:
Go to the basic functions and scripts folder and read through the 1) README file.

__________________________________________________________________________________________________________

NOTE ON ANALYSIS:

For analysis, our lab frequently uses custom written scripts and functions (some included in this library),
and the chronux toolbox (can be downloaded for free online) and is found under the griffin lab drive here:

~~~
Lab Procedures and Protocols\MATLABToolbox\chronux\spectral_analysis\continuous
~~~

Note that not all functions in this folder are written by chronux, over the years, functions were added. But
if you ever want to know for certain which functions were, you can find a newer edition here:

~~~
Lab Procedures and Protocols\MATLABToolbox\chronux_2_12
~~~
__________________________________________________________________________________________________________              

IMPORTANT FOR USERS RECORDING FROM MULTIPLE REGIONS:
Future users who record single-units from multiple regions should not store data separately in
folders, despite some of the code in these folders being formatted to handle those storage habits. 
Instead, save the region single-units under specific .txt files. For example: if you recorded 10 units 
from mPFC and 10 from hippocampus, you should name the saved .txt something like 'mPFC_...' and 'hpc_...' 
instead of them all starting with 'TT...'with the dots indicating the rest of the name. Then when you go 
to load the TT files, you can specify to load the specific region based on the TT name, instead of based 
on an entirely different folder. This saves drive space and is more organized.
