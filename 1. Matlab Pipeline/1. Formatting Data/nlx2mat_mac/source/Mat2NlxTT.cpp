//******************************************************************************************************************************************************
//	Mat2NlxTT.cpp
//	Author: Kevin Iamiceli
//	Created Sept 17, 2003
//	Version 2.00
//******************************************************************************************************************************************************
#include "GeneralOperations.h"

#include <vector>
#include "Nlx_DataTypes.h"

const int MaxRecords = 100;
const int MaxFields = 6;

const int IndexTimestamp = 0;
const int IndexScNumber = 1;
const int IndexCellNumber = 2;
const int IndexParams = 3;
const int IndexData = 4;

const int Nlx2MatOK2 = 0;
const int Nlx2MatError2 = -1;


GeneralOperations mGeneralOps;  

std::vector<double*> mInputFields;
int mFileTypeExpected = DATAFILETYPE_TTSPIKE;
int mNumChannels = TT_NUMELECTRODES;
int mRecordSize = sizeof(TTRec);

int GetInputFields(const mxArray *prhs[], int nrhs, BOOL* fieldSelections, int expectedNumRecords);
int WriteFile(std::fstream& fileHandle, BOOL* fieldSelections, int extractionMode, double* modeParameters, int numModeParameters, int numRecs);

//******************************************************************************************************************************************************
// This function is our matlab interface function.  It accepts paramters from the  matlab environment and passes them accordingly to the necessary C++ function.
// The function is responsible for allocating the right amount of memory and parameters to return to the matlab environment.
//******************************************************************************************************************************************************
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	if( nrhs == 1 ) {
		mexPrintf("\tMat2NlxTT() version 2.0\n");
		return;
	}

	//check number of input params
	if(nrhs < MinInputParametersMat2Nlx) {
		mexPrintf("\tIncorrect Number Of Input Arguements Specified.  Please See Help File For Examples.\n");
		return;
	}

	CString filename;//get parameter 1, our filename
	BOOL appendToFile = FALSE;
	int extractionMode = 0;	//get parameter 4, extraction mode
	double* modeParameters = NULL;	//get param 5 if necessary, thats our input array based on mode selection
	int numModeParameters = 0;
	int expectedNumRecords = 0;
	BOOL fieldSelections[MaxFields];	//get parameter 2, our field selection list
	memset( fieldSelections, 0, sizeof(BOOL)*MaxFields );

	if( mGeneralOps.GetInputParametersMat2Nlx(prhs, nrhs, filename, appendToFile, extractionMode, modeParameters, numModeParameters, expectedNumRecords, fieldSelections, MaxFields) != Nlx2MatOK2 ) { return; }

	if( GetInputFields(prhs, nrhs, fieldSelections, expectedNumRecords) != Nlx2MatOK2 ) { return; }

	std::fstream fileHandle;
	if( mGeneralOps.OpenFileMat2Nlx( fileHandle, appendToFile, filename, mFileTypeExpected) != Nlx2MatOK2 ) { return; }

	if( fieldSelections[MaxFields-1] && !appendToFile ) {
		if( mGeneralOps.ProcessHeader(prhs, nrhs, nrhs-1, fileHandle) != Nlx2MatOK2 ) { 
			fileHandle.close();
			return; 
		}
	}

	if( WriteFile(fileHandle, fieldSelections, extractionMode, modeParameters, numModeParameters, expectedNumRecords) != Nlx2MatOK2 ) {
			fileHandle.close();
			return; 
	}

	fileHandle.close();
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
int GetInputFields(const mxArray *prhs[], int nrhs, BOOL* fieldSelections, int expectedNumRecords)
{
	mInputFields.clear();
	double* arrayPtr = NULL;
	int prhsIndex = MinInputParametersMat2Nlx-1;
	int expectedM = 1;
	int expectedN = 1;

	for( int i = IndexTimestamp; i < (MaxFields-1); i++ ) {
		if( fieldSelections[i] ) {
			if( IndexParams == i ) { 
				expectedM = MAX_PARAMS;
				expectedN = expectedNumRecords;
			} else if( IndexData == i ) { 
				expectedM = SPIKE_NUMPOINTS;
				expectedN = expectedNumRecords*mNumChannels;
			} else { 
				expectedM = 1;	
				expectedN = expectedNumRecords;
			}

			if( mGeneralOps.GetInputNumericArrayPtr(prhs, nrhs, prhsIndex, arrayPtr, expectedM, expectedN) != Nlx2MatOK2 ) { return(Nlx2MatError2); }
			mInputFields.push_back(arrayPtr);
			prhsIndex++;
		}
	}
	return(Nlx2MatOK2);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
int WriteFile(std::fstream& fileHandle, BOOL* fieldSelections, int extractionMode, double* modeParameters, int numModeParameters, int numRecs)
{
	TTRec buf;
	memset(&buf, 0, mRecordSize );
	int index = 0;

	for( int i = 0; i < numRecs; i++ ) {

		index = 0;
		if( fieldSelections[IndexTimestamp] ) {
			buf.qwTimeStamp = (unsigned __int64)(mInputFields[index][i]);
			index++;	
		}

		if( !mGeneralOps.ValidRecToExtract(i, buf.qwTimeStamp, extractionMode, modeParameters, numModeParameters) ) { continue; }

		if( fieldSelections[IndexScNumber] ) {
			buf.dwScNumber = (unsigned __int32)(mInputFields[index][i]);
			index++;	
		}
		if( fieldSelections[IndexCellNumber] ) {
			buf.dwCellNumber = (unsigned __int32)(mInputFields[index][i]);
			index++;	
		}
		if( fieldSelections[IndexParams] ) {
			for( int k = 0; k < MAX_PARAMS; k++ ) {
				buf.dnParams[k] = (signed __int32)(mInputFields[index][(i*MAX_PARAMS)+k]);
			}
			index++;	
		}
		if( fieldSelections[IndexData] ) {
			for( int n = 0; n < mNumChannels; n++) {
				for( int j = 0; j < SPIKE_NUMPOINTS; j++) {
					buf.snData[j].snADVal[n] =  (signed __int16)(mInputFields[index][(i*SPIKE_NUMPOINTS*mNumChannels) + (n*SPIKE_NUMPOINTS) + j]);
				}
			}
			index++;	
		}

		//fileHandle.Write( &buf, mRecordSize );
		fileHandle.write( (const char*)&buf, mRecordSize );

	}
	return(Nlx2MatOK2);
}

