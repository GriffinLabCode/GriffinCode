# Griffin Lab Code

Welcome to the Griffin lab online library for custom written scripts and functions used to
analyze our data! :) This page was created to store our 'master' code for easy access to both 
our members and individuals outside of the lab.
__________________________________________________________________________________________________________

TO BEGIN:

Download the GriffinCode repository and open the Matlab Pipeline folder. This is where the bulk of our 
analysis code is stored. 

The Matlab Pipeline was designed to condense and organize the labs code so that future users can readily 
extend and replicate past work. Importantly, it was also developed with new matlab users in mind. Users 
can follow the instructions below to begin.

Open the 'Using the Matlab Pipeline' powerpoint. This document will walk users through the following:
    1) How to convert CSC and VT data to a matlab readible format
    2) How to extract, load, and use various files
    3) How to create the "Int" file, a record of timestamps that corresponds to specific locations of interest
    4) How to use and execute the functions in these folders
    5) How to store and name data for ease of use and replication with this repo.
__________________________________________________________________________________________________________

SOME IMPORTANT NOTES ON CONVERSION: 
Our lab records neural activity using the neuralynx (digitalynx) hardware and cheetah software.
CSC and video-tracking data are converted using neuralynx functions and are not provided in this
library, despite being used by some functions. You can find them in the griffin lab drive here:

Note that when you save CSC and VT data to a directory, you should not change that directory. For example,
if you save CSC1.mat to directory A, but then move CSC1.mat to directory B, you will have to go through some
loops to load CSC1.mat. It's easier to keep the CSC and VT1.mat files in the directories where you converted them.

__________________________________________________________________________________________________________

For lab users with access to our shared drive:

This repo contains everything you should need to replicate past work and run your own analyses. Note that
it is a work-in-progress, and new analyses should be added as time goes on. 

In the past, our users frequently stored and used functions/scripts in this folder:

~~~
Lab Procedures and Protocols\MATLABToolbox
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

__________________________________________________________________________________________________________

Please update the correspondent below, when the past user is no longer responsible for the repo.
__________________________________________________________________________________________________________

As of 8/6/2020, please refer any questions to John Stout at the following email: john.j.stout.jr@gmail.com



