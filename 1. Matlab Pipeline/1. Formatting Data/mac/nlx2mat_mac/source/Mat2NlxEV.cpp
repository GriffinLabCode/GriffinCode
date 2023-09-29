//******************************************************************************************************************************************************
//	Mat2NlxEV.cpp
//	Author: Kevin Iamiceli
//	Created Sept 17, 2003
//	Version 2.00
//******************************************************************************************************************************************************
#include "GeneralOperations.h"


#include <vector>
#include "Nlx_DataTypes.h"
#include <fstream>
#include <string>

const int MaxRecords = 100;
const int MaxFields = 6;

const int IndexTimestamp = 0;
const int IndexEventId = 1;
const int IndexTtl = 2;
const int IndexExtras = 3;
const int IndexEventString = 4;

const int Nlx2MatError = -1;
const int Nlx2MatOK = 0;

GeneralOperations mGeneralOps;  

std::vector<double*> mInputFields;
int mFileTypeExpected = DATAFILETYPE_EVENT;
int mRecordSize = sizeof(EventRec);

int GetInputFields(const mxArray *prhs[], int nrhs, BOOL* fieldSelections, int expectedNumRecords);
//int ProcessHeader(const mxArray *prhs[], int nrhs,  int prhsIndex);
int WriteFile(std::fstream& fileHandle, BOOL* fieldSelections, int extractionMode, double* modeParameters, int numModeParameters, int numRecs, const mxArray *prhs[], int prhsIndex);

//******************************************************************************************************************************************************
// This function is our matlab interface function.  It accepts paramters from the  matlab environment and passes them accordingly to the necessary C++ function.
// The function is responsible for allocating the right amount of memory and parameters to return to the matlab environment.
//******************************************************************************************************************************************************
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	if( nrhs == 1 ) {
		mexPrintf("\tMat2NlxEV() version 2.0\n");
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

	if( mGeneralOps.GetInputParametersMat2Nlx(prhs, nrhs, filename, appendToFile, extractionMode, modeParameters, numModeParameters, expectedNumRecords, fieldSelections, MaxFields) != Nlx2MatOK ) { return; }

	if( GetInputFields(prhs, nrhs, fieldSelections, expectedNumRecords) != Nlx2MatOK ) { return; }

	std::fstream fileHandle;
	if( mGeneralOps.OpenFileMat2Nlx( fileHandle, appendToFile, filename, mFileTypeExpected) != Nlx2MatOK ) { return; }

	if( fieldSelections[MaxFields-1] && !appendToFile ) {
		if( mGeneralOps.ProcessHeader(prhs, nrhs, nrhs-1, fileHandle) != Nlx2MatOK ) { 
			fileHandle.close();
			return; 
		}
	}

	if( WriteFile(fileHandle, fieldSelections, extractionMode, modeParameters, numModeParameters, expectedNumRecords, prhs, nrhs-2) != Nlx2MatOK ) {
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

	for( int i = IndexTimestamp; i < (MaxFields-2); i++ ) {
		if( fieldSelections[i] ) {
			if( IndexExtras == i ) { 
				expectedM = EVENT_NUM_EXTRAS;
			} else { 
				expectedM = 1;	
			}

			if( mGeneralOps.GetInputNumericArrayPtr(prhs, nrhs, prhsIndex, arrayPtr, expectedM, expectedNumRecords) != Nlx2MatOK ) { return(Nlx2MatError); }
			mInputFields.push_back(arrayPtr);
			prhsIndex++;
		}
	}
	return(Nlx2MatOK);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
int WriteFile(std::fstream& fileHandle, BOOL* fieldSelections, int extractionMode, double* modeParameters, int numModeParameters, int numRecs, const mxArray *prhs[], int prhsIndex)
{
	EventRec buf;
	memset(&buf, 0, mRecordSize );
	int index = 0;

	for( int i = 0; i < numRecs; i++ ) {

		index = 0;
		if( fieldSelections[IndexTimestamp] ) {
			buf.qwTimeStamp = (unsigned __int64)(mInputFields[index][i]);
			index++;	
		}

		if( !mGeneralOps.ValidRecToExtract(i, buf.qwTimeStamp, extractionMode, modeParameters, numModeParameters) ) { continue; }

		if( fieldSelections[IndexEventId] ) {
			buf.nevent_id = (short)(mInputFields[index][i]);
			index++;	
		}
		if( fieldSelections[IndexTtl] ) {
			buf.nttl = (short)(mInputFields[index][i]);
			index++;	
		}
		if( fieldSelections[IndexExtras] ) {
			for( int j = 0; j < EVENT_NUM_EXTRAS; j++) {
				buf.dnExtra[j] = (__int32)(mInputFields[index][(i*EVENT_NUM_EXTRAS)+j]);
			}
			index++;	
		}
		if( fieldSelections[IndexEventString] ) {
				memset( buf.EventString, 0, sizeof(char)*NLX_EventRecStringSize);
				mxGetString( mxGetCell( prhs[prhsIndex], i ), buf.EventString, NLX_EventRecStringSize );
		}

		fileHandle.write( (const char*)&buf, mRecordSize );
	}
	return(Nlx2MatOK);
}

