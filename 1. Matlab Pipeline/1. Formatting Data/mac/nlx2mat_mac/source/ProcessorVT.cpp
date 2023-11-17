//********************************************************************************************************************
//	Processor.cpp
//********************************************************************************************************************
#include "ProcessorVT.h"



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

	if( mFileType == DATAFILETYPE_VIDEO ) {
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
			if( IndexTargets == i ) {
				plhs[index] = mxCreateDoubleMatrix( NLX_VTREC_NUM_TARGETS, numRecs, mxREAL );	//special case for samples field b/c its a true double array
			} else if( IndexPoints == i ) {
				plhs[index] = mxCreateDoubleMatrix( NLX_VTREC_NUM_POINTS, numRecs, mxREAL );	//special case for samples field b/c its a true double array
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

	VideoRec* rec = NULL;
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

	VideoRec* rec = NULL;
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

	VideoRec* rec = NULL;
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

	VideoRec* rec = NULL;
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

	VideoRec* rec = NULL;
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
void Processor::InsertData(VideoRec* rec, int recordIndex)
{
	int index = 0;

	if( mFieldSelections[IndexTimestamp] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int64)(rec->qwTimeStamp) );
		index++;
	}
	if( mFieldSelections[IndexExtractedX] ) {
		mOutputVariables[index][recordIndex] = (double)rec->dnextracted_x;
		index++;
	}
	if( mFieldSelections[IndexExtractedY] ) {
		mOutputVariables[index][recordIndex] = (double)rec->dnextracted_y;
		index++;
	}
	if( mFieldSelections[IndexExtractedAngle] ) {
		mOutputVariables[index][recordIndex] = (double)(rec->dnextracted_angle);
		index++;
	}
	if( mFieldSelections[IndexTargets] ) {
		for( int j = 0; j < NLX_VTREC_NUM_TARGETS; j++) {
			mOutputVariables[index][j+(recordIndex*NLX_VTREC_NUM_TARGETS)] = (double)rec->dntargets[j];
		}
		index++;
	}
	if( mFieldSelections[IndexPoints] ) {
		for( int k = 0; k < NLX_VTREC_NUM_POINTS; k++) {
			mOutputVariables[index][k+(recordIndex*NLX_VTREC_NUM_POINTS)] = (double)( (signed __int32)(rec->dwPoints[k]) );
		}
		index++;
	}
}
