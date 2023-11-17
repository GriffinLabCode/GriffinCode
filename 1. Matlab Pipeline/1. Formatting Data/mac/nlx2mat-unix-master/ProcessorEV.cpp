//********************************************************************************************************************
//	Processor.cpp
//********************************************************************************************************************
#include "ProcessorEV.h"

//********************************************************************************************************************
//********************************************************************************************************************
Processor::Processor(void)
{
	mFilename = "";
	memset( mFieldSelections, 0, sizeof(BOOL)*MaxFields );
	mHeaderSelected = FALSE;
	mHeader = NULL;
	mExtractionMode = 0;
	mModeParameters = NULL;
	mNumModeParameters = 0;
	mFileType = 0;
	mNumElectrodes = 0;

	mMatEventStringCell = NULL;
}

//********************************************************************************************************************
//********************************************************************************************************************
Processor::~Processor(void) {}

//********************************************************************************************************************
//********************************************************************************************************************
void Processor::ProcessFile( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	if( mGeneralOps.GetInputParameters(prhs, nlhs, mFilename, mFieldSelections, MaxFields, mHeaderSelected, mExtractionMode, mModeParameters, mNumModeParameters) != Nlx2MatOK ) { return; }

	if( mDataBucket.Open(mFilename) != 0 ) { return; }

	if( mDataBucket.GetDataSourceType(0, mFileType) != 0 ) { return; }

	if( mFileType == DATAFILETYPE_EVENT ) {
		ProcessData(plhs);
	} else {
		mexPrintf("\tInvalid filetype when allocating return variables\n");
		return; 
	}

	if( mHeaderSelected && (mDataBucket.GetDataSourceHeader(0, mHeader) == 0) ) {
		if( mGeneralOps.LoadHeader(plhs, nlhs-1, mHeader ) != Nlx2MatOK ) { return; }
	}

	mDataBucket.Close(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::AllocateOuputVariables(mxArray *plhs[], int numRecs )
{
	double* temp = NULL;
	mOutputVariables.clear();
	int index = 0;

	// Create matrices for return arguments if necessary. Assign pointers to each output. 
	for( int i = 0; i < MaxFields; i++ ) {
		if( mFieldSelections[i] ) {
			if( IndexExtras == i ) {
				plhs[index] = mxCreateDoubleMatrix( EVENT_NUM_EXTRAS, numRecs, mxREAL );	//special case for samples field b/c its a true double array
			} else if( IndexEventString == i ) {
				mMatEventStringCell = mxCreateCellMatrix( numRecs, 1 );
				plhs[index] = mMatEventStringCell ;
			} else {
				plhs[index] = mxCreateDoubleMatrix( 1, numRecs, mxREAL );	//this is for all other fields
			}
			temp = mxGetPr( plhs[index] );
			index++;
			if( NULL == temp ) {
				mexPrintf("\tError Allocating Memory For Output Variablies, Pointer Is Null In AllocateOuputVariables().\n");
				return(Nlx2MatError); 
			}
			mOutputVariables.push_back(temp);
		}
	}
	return(Nlx2MatOK);
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr Processor::ProcessData( mxArray *plhs[] )
{
	switch(mExtractionMode)
	{
	case ExtractionModeAll:
		return( ProcessDataAll(plhs) ) ;
	case ExtractionModeRecordRange:
		return( ProcessDataRecRange(plhs) ) ;
	case ExtractionModeRecordList:
		return( ProcessDataRecList(plhs) ) ;
	case ExtractionModeTsRange:
		return( ProcessDataTsRange(plhs) ) ;
	case ExtractionModeTsList:
		return( ProcessDataTsList(plhs) ) ;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataAll(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, numRecs ) != Nlx2MatOK ) { return(-1); }

	EventRec* rec = NULL;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&rec));
		InsertData(rec, i);
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecRange(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( mModeParameters[0] > mModeParameters[1] ) {
		mexPrintf("\tError Processing File, Record Range Values are not in Increasing Order.\n");
		return(-1);
	}

	if( mModeParameters[1] >= numRecs ) {
		mModeParameters[1] = numRecs - 1;
	}

	int recs2Process = (int)(mModeParameters[1] - mModeParameters[0] + 1);
	if( recs2Process <= 0 ) { return(-1); }

	if( AllocateOuputVariables(plhs, recs2Process ) != Nlx2MatOK ) { return(-1); }

	EventRec* rec = NULL;
	int index = 0;
	for( int i = (int)(mModeParameters[0]); i <= (int)(mModeParameters[1]); i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&rec));
		InsertData(rec, index);
		index++;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecList(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	EventRec* rec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		if( (mModeParameters[i] >= 0) && (mModeParameters[i] < numRecs) ) {
			mDataBucket.GetData((int)(mModeParameters[i]), 0, (void**)(&rec));
			InsertData(rec, index);
			index++;
		}
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsRange(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( mModeParameters[0] > mModeParameters[1] ) {
		mexPrintf("\tError Processing File, Timestamp Range Values are not in Increasing Order.\n");
		return(-1);
	}

	EventRec* rec = NULL;
	int recs2Process = 0;
	int initialRecIndex = -1;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&rec));
		if( (rec->qwTimeStamp >= mModeParameters[0]) && (rec->qwTimeStamp <= mModeParameters[1]) ) {
			if( initialRecIndex == -1 ) {
				initialRecIndex = i;
			}
			recs2Process++;
		}
	}

	if( AllocateOuputVariables(plhs, recs2Process ) != Nlx2MatOK ) { return(-1); }

	int index = 0;
	for( int i = initialRecIndex; i < initialRecIndex+recs2Process; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&rec));
		InsertData(rec, index);
		index++;
	}

	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsList(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	EventRec* rec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		mDataBucket.GetData((unsigned __int64)(mModeParameters[i]), 0, (void**)(&rec));
		if( rec->qwTimeStamp == mModeParameters[i]) {
			InsertData(rec, index);
			index++;
		}
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
void Processor::InsertData(EventRec* rec, int recordIndex)
{
	int index = 0;
	char buffer[NLX_EventRecStringSize];

	if( mFieldSelections[IndexTimestamp] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int64)(rec->qwTimeStamp) );
		index++;
	}
	if( mFieldSelections[IndexEventId] ) {
		mOutputVariables[index][recordIndex] = (double)rec->nevent_id;
		index++;
	}
	if( mFieldSelections[IndexTtl] ) {
		mOutputVariables[index][recordIndex] = (double)rec->nttl;
		index++;
	}
	if( mFieldSelections[IndexExtras] ) {
		for( int j = 0; j < EVENT_NUM_EXTRAS; j++) {
			mOutputVariables[index][j+(recordIndex*EVENT_NUM_EXTRAS)] = (double)rec->dnExtra[j];
		}
		index++;
	}
	if( mFieldSelections[IndexEventString] ) {
		memset(buffer, 0, sizeof(char)*NLX_EventRecStringSize);
		strcpy(buffer, rec->EventString);
		mxSetCell( mMatEventStringCell, recordIndex, mxCreateString(buffer) );
		index++;
	}
}
