//******************************************************************************************************************************************************
//	Nlx2MatSpike.cpp
//	Author: Kevin Iamiceli
//	Modified March 9, 2003
//	Version 3.00
//******************************************************************************************************************************************************
#include "ProcessorSpike.h"

const int MinInputParameters = 4;
const int MaxInputParameters = 5;

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	//check number of input params
	if( (nrhs < MinInputParameters) || (nrhs > MaxInputParameters) ) {		
		mexPrintf("\tNlx2MatSpike - Incorrect Number Of Input Arguements Specified.  Please See Help File For Examples.\n");
		return;
	}

	Processor spikeProcessor;
	spikeProcessor.ProcessFile(nlhs, plhs, nrhs, prhs);
}
