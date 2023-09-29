//******************************************************************************************************************************************************
//	GeneralOperations.cpp
//	Author: Kevin Iamiceli
//	Modified March 9, 2003
//	Version 3.00
//******************************************************************************************************************************************************
#include "Nlx2MatEVInclude.h"
#include "GeneralOperations.h"

//********************************************************************************************************************
//********************************************************************************************************************
GeneralOperations::GeneralOperations(void) {}

//********************************************************************************************************************
//********************************************************************************************************************
GeneralOperations::~GeneralOperations(void) {}

//********************************************************************************************************************
//********************************************************************************************************************
int GeneralOperations::GetInputParameters(const mxArray *prhs[], int nlhs, CString& filename, BOOL* fieldSelections, int maxFields, BOOL& headerSelected, int& extractionMode, double*& modeParameters, int& numModeParameters)
{
	//get parameter 1, our filename
	if( GetInputString(filename, prhs, InputParamFilename) != Nlx2MatOK ) { return(Nlx2MatError); }

	//get parameter 2, our field selection list
	int expectedOutputArgs = 0;
	if( GetFieldSelections(prhs, InputParamFieldList, fieldSelections, maxFields, expectedOutputArgs) != Nlx2MatOK ) { return(Nlx2MatError); }

	//get parameter 3, our header selection variable
	double temp = mxGetScalar(prhs[InputParamExtractHeader]);
	if( 1 == temp ) { 
		headerSelected = TRUE; 
		expectedOutputArgs++;
	}

	//make sure we have a valid number of output args
	if( nlhs != expectedOutputArgs ) {
		mexPrintf("Invalid Number Of Output Arguments. Please See Help File For Examples.\n");
		return(Nlx2MatError);
	}

	//get parameter 4, extraction mode
	extractionMode = (int)(mxGetScalar(prhs[InputParamExtractionMode]));
	if( (extractionMode < ExtractionModeAll) || (extractionMode > ExtractionModeTsList) ){ 
		mexPrintf("Invalid Extraction Mode Value. Please See Help File For Examples.\n");
		return(Nlx2MatError);
	}

	//get param 5 if necessary, thats our input array based on mode selection
	if( ExtractionModeAll != extractionMode ) {
		if( GetModeParameters(prhs, InputParamInputArray, modeParameters, numModeParameters) != Nlx2MatOK ) { return(Nlx2MatError); }
	}
	return(Nlx2MatOK);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
int GeneralOperations::GetInputString(CString& inputStr, const mxArray *prhs[], int prhsIndex) 
{
	//check index for args array
	if( prhsIndex < 0 ) { 
		mexPrintf("\tInvalid Index for Input Arguments Array In GetInputString().\n");
		return(Nlx2MatError); 
	}

   //Input must be a string, and a row vector.
    if( !mxIsChar(prhs[prhsIndex]) ) {
		mexPrintf("\tInvalid Argument In GetInputString(), Input Argument Must Be A String.\n");
		return(Nlx2MatError); 
	} else if( !mxGetM(prhs[prhsIndex]) ) {
		mexPrintf("\tInvalid Argument In GetInputString(), Input Argument Must Be A Row Vector.\n");
		return(Nlx2MatError); 
	}
    
    //Get the length of the input string.
    int strLength = ( mxGetM(prhs[prhsIndex]) * mxGetN(prhs[prhsIndex]) ) + 1;
	if( strLength <= 1 ) { 
		mexPrintf("\tError Retrieving String Length In GetInputString(), cannot retrieve Input String.\n");
		return(Nlx2MatError); 
	}
	if( strLength > MaxStringLength ) {
		mexPrintf("\tError Retrieving String Length In GetInputString(), String Length Is Too Large.\n");
		return(Nlx2MatError); 
	}

	char* buffer = new char[strLength];
	if( NULL == buffer ) {
		mexPrintf("\tError Allocating Memory For Input String In GetInputString(), Input String Pointer Is Null.\n");
		return(Nlx2MatError); 
	}
	memset( buffer, 0, sizeof(char)*strLength );

    //Copy the string data from prhs[0] into a C string input_ buf. If the string array contains several rows, they are copied, one column at a time, into one long string array.
    if(mxGetString( prhs[prhsIndex], buffer, strLength) != 0) {
		mexPrintf("\tError Retrieving String In GetInpuString().\n");
		return(Nlx2MatError); 
	}

	inputStr = buffer;
	delete [] buffer;
	return(Nlx2MatOK);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
int GeneralOperations::GetFieldSelections(const mxArray *prhs[], int prhsIndex, BOOL* fieldSelections, const int numFields, int& numFieldsSelected)
{
	//error check input params
	if( prhsIndex < 0 ) { 
		mexPrintf("\tInvalid Index for Input Arguments Array In GetFieldSelections().\n");
		return(Nlx2MatError); 
	}
	if( NULL == fieldSelections ) {
		mexPrintf("\tPointer To Field Selections Array Is Null In GetFieldSelections().\n");
		return(Nlx2MatError); 
	}

	//type check field parameter and extract
	if( !mxIsNumeric(prhs[prhsIndex]) ) {
		mexPrintf("\tInvalid Type Array In GetFieldSelections(), Type Must Be Numeric.\n");
		return(Nlx2MatError); 
	} 

	//get a pointer to the input array
	double* inputArray = mxGetPr(prhs[prhsIndex]);
	if( NULL == inputArray ) {
		mexPrintf("\tError Retrieving Pointer To Field Array In GetFieldSelections().\n");
		return(Nlx2MatError); 
	}

	//check if array size matches the number of fields we are expecting
	if( numFields != (mxGetM(prhs[prhsIndex]) * mxGetN(prhs[prhsIndex])) ) {
		mexPrintf("\tInvalic Size Of Input Array Calculated In GetFieldSelections().\n");
		return(Nlx2MatError); 
	}

	//extract data from input array into our array
	numFieldsSelected = 0;
	for( int i = 0; i < numFields; i++ ) {
		if( 1 == inputArray[i] ) {
			fieldSelections[i] =	TRUE;
			numFieldsSelected++;
		}
	}

	return(Nlx2MatOK);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
int GeneralOperations::GetModeParameters(const mxArray *prhs[], int prhsIndex, double* &modeParameters, int& numModeParameters)
{
	//error check input params
	if( prhsIndex < 0 ) { 
		mexPrintf("\tInvalid Index for Input Arguments Array In GetModeParameters().\n");
		return(Nlx2MatError); 
	}

	//type check field parameter and extract
	if( !mxIsNumeric(prhs[prhsIndex]) ) {
		mexPrintf("\tInvalid Type Array In GetModeParameters(), Type Must Be Numeric.\n");
		return(Nlx2MatError); 
	} 

	//get a pointer to the input array
	modeParameters = mxGetPr(prhs[prhsIndex]);
	if( NULL == modeParameters ) {
		mexPrintf("\tError Retrieving Pointer To Mode Parameters Array In GetModeParameters().\n");
		return(Nlx2MatError); 
	}

	numModeParameters = mxGetM(prhs[prhsIndex]) * mxGetN(prhs[prhsIndex]);
	if( numModeParameters <= 0 ) {
		mexPrintf("\tInvalic Size Of Mode Input Array Calculated In GetModeParameters().\n");
		return(Nlx2MatError); 
	}

	return(Nlx2MatOK);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
int GeneralOperations::LoadHeader(mxArray *plhs[],	int plhsIndex, char* headerBuffer )
{
	if( NULL == headerBuffer ) {
		mexPrintf("\tError Loading Header Into Matlab, Pointer Is Null In LoadHeader().\n");
		return(Nlx2MatOK);
	}

	//Find the number of lines in the header - that equalls how many cells we need
	int numCellsNeeded = 0;
	for( int i = 0; i < NlxHeaderSize; i++ ) {
		if( headerBuffer[i] == '\n' ) {
			numCellsNeeded++;
		}
	}
	numCellsNeeded++;
	
	//Create and assign header variable in matlab
	mxArray *cellArrayPtr = mxCreateCellMatrix( numCellsNeeded, 1 );
	plhs[plhsIndex] = cellArrayPtr;
	
	//Loop to fill CellArray from string buffer that was filled from file read
	char lineBuffer[MaxHeaderLine];			//Temp string variable to hold data before being put into cell array, used for header
	int headerIndex = 0;				//Used to parse the Nlx header
	int tempIndex = 0;					//Index for storing strings before being put into the cell array

	for( int index = 0; index < numCellsNeeded; index++) {
		memset( lineBuffer, 0, sizeof(char)*MaxHeaderLine );
		//loop to create string
		while( headerIndex < NlxHeaderSize ) {
			lineBuffer[tempIndex] = headerBuffer[headerIndex];
			headerIndex++;
			tempIndex++;
			//chech to see if we are at the end of a line or the end of our buffer 
			if( ( headerBuffer[headerIndex-1] == '\n') || ( tempIndex >= MaxHeaderLine ) ) {
				lineBuffer[tempIndex-2] = 0;
				// Enter string into cell
				mxSetCell(cellArrayPtr, index, mxCreateString(lineBuffer) );
				tempIndex = 0;
				break;
			}
		}
	}
	return(Nlx2MatOK);
}
