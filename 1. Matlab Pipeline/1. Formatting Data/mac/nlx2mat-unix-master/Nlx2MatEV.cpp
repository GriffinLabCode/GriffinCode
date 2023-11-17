//******************************************************************************************************************************************************
//	Nlx2MatEV.cpp
//	Author: Kevin Iamiceli
//	Created March 15, 2003
//	Version 3.00
//******************************************************************************************************************************************************
#include "ProcessorEV.h"

const int MinInputParameters = 4;
const int MaxInputParameters = 5;

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	
	//check number of input params
	if( (nrhs < MinInputParameters) || (nrhs > MaxInputParameters) ) {		
		mexPrintf("\tIncorrect Number Of Input Arguements Specified.  Please See Help File For Examples.\n");
		return;
	}

	Processor spikeProcessor;
	spikeProcessor.ProcessFile(nlhs, plhs, nrhs, prhs);
}
