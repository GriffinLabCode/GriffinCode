# Griffin Lab Code

Welcome to the Griffin lab online library for custom written scripts and functions used to
analyze our data! :) This page was primarily created as an online protocol for file conversion 
routines and as a back-up storage cloud for analysis code.

_________________________________________________________________________________________________________

~~~ SOME NOTES: 
Our lab records neural activity using the neuralynx (digitalynx) hardware and cheetah software.
Some conversions
~~~

FOR NEW USERS: Make sure to start out in the 'basic functions and scripts' folders. You will
               want to convert your CSC and video-tracking files prior to analysis. If using a
               t-maze, you will want to generate an Int file. Most analysis scripts are made
               with the intentions of use with the Int file but can be modified to fit your
               needs.
               

IMPORTANT FOR USERS RECORDING FROM MULTIPLE REGIONS:
Future users who record single-units from multiple regions should not store data separately in
folders, despite some of the code in these folders being formatted to handle those storage habits. 
Instead, save the region single-units under specific .txt files. For example: if you recorded 10 units 
from mPFC and 10 from hippocampus, you should name the saved .txt something like 'mPFC_...' and 'hpc_...' 
instead of them all starting with 'TT...'with the dots indicating the rest of the name. Then when you go 
to load the TT files, you can specify to load the specific region based on the TT name, instead of based 
on an entirely different folder. This saves drive space and is more organized.
