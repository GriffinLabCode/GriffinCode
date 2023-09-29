//******************************************************************************************************************************************************
//	Nlx2MatVT.cpp
//	Author: Kevin Iamiceli
//	Created Sept 15, 2003
//	Version 2.00
//******************************************************************************************************************************************************
#include "ProcessorVT.h"

const int MinInputParameters = 4;
const int MaxInputParameters = 5;



//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	//check number of input params
	if( (nrhs < MinInputParameters) || (nrhs > MaxInputParameters) ) {		
		mexPrintf("\tNlx2MatVt: Incorrect Number Of Input Arguements Specified.  Please See Help File For Examples.\n");
		return;
	}


	//mexPrintf("\tNlx2MatVt: init\n");

	Processor spikeProcessor;
	spikeProcessor.ProcessFile(nlhs, plhs, nrhs, prhs);
}
