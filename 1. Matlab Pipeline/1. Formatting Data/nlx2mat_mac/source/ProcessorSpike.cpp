//********************************************************************************************************************
//	Processor.cpp
//********************************************************************************************************************
#include "ProcessorSpike.h"

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

	if( mFileType == DATAFILETYPE_SESPIKE ) {
		mNumElectrodes = SE_NUMELECTRODES;
		ProcessDataSE(plhs);
	} else if( mFileType == DATAFILETYPE_STSPIKE ) {
		mNumElectrodes = ST_NUMELECTRODES;
		ProcessDataST(plhs);
	} else if( mFileType == DATAFILETYPE_TTSPIKE ) {
		mNumElectrodes = TT_NUMELECTRODES;
		ProcessDataTT(plhs);
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
			if( IndexParams == i ) {
				plhs[index] = mxCreateDoubleMatrix( MAX_PARAMS, numRecs, mxREAL );	//special case for samples field b/c its a true double array
			} else if( IndexData == i ) {
				mwSize  ADDataDims[3];					//This array specifies the dimensions for a 3D array
				ADDataDims[0] = SPIKE_NUMPOINTS; //num of points in a spike
				ADDataDims[1] = mNumElectrodes;
				ADDataDims[2] = numRecs;
				plhs[index] = mxCreateNumericArray( 3, ADDataDims, mxDOUBLE_CLASS, mxREAL );
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
ierr Processor::ProcessDataSE( mxArray *plhs[] )
{
	switch(mExtractionMode)
	{
	case ExtractionModeAll:
		return( ProcessDataAllSE(plhs) ) ;
	case ExtractionModeRecordRange:
		return( ProcessDataRecRangeSE(plhs) ) ;
	case ExtractionModeRecordList:
		return( ProcessDataRecListSE(plhs) ) ;
	case ExtractionModeTsRange:
		return( ProcessDataTsRangeSE(plhs) ) ;
	case ExtractionModeTsList:
		return( ProcessDataTsListSE(plhs) ) ;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataAllSE(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, numRecs ) != Nlx2MatOK ) { return(-1); }

	SERec* seRec = NULL;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&seRec));
		InsertDataSE(seRec, i);
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecRangeSE(mxArray *plhs[])
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

	SERec* seRec = NULL;
	int index = 0;
	for( int i = (int)(mModeParameters[0]); i <= (int)(mModeParameters[1]); i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&seRec));
		InsertDataSE(seRec, index);
		index++;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecListSE(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	SERec* seRec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		if( (mModeParameters[i] >= 0) && (mModeParameters[i] < numRecs) ) {
			mDataBucket.GetData((int)(mModeParameters[i]), 0, (void**)(&seRec));
			InsertDataSE(seRec, index);
			index++;
		}
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsRangeSE(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( mModeParameters[0] > mModeParameters[1] ) {
		mexPrintf("\tError Processing File, Timestamp Range Values are not in Increasing Order.\n");
		return(-1);
	}

	SERec* seRec = NULL;
	int recs2Process = 0;
	int initialRecIndex = -1;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&seRec));
		if( (seRec->qwTimeStamp >= mModeParameters[0]) && (seRec->qwTimeStamp <= mModeParameters[1]) ) {
			if( initialRecIndex == -1 ) {
				initialRecIndex = i;
			}
			recs2Process++;
		}
	}

	if( AllocateOuputVariables(plhs, recs2Process ) != Nlx2MatOK ) { return(-1); }

	int index = 0;
	for( int i = initialRecIndex; i < initialRecIndex+recs2Process; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&seRec));
		InsertDataSE(seRec, index);
		index++;
	}

	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsListSE(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	SERec* seRec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		mDataBucket.GetData((unsigned __int64)(mModeParameters[i]), 0, (void**)(&seRec));
		if( seRec->qwTimeStamp == mModeParameters[i]) {
			InsertDataSE(seRec, index);
			index++;
		}
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
void Processor::InsertDataSE(SERec* seRec, int recordIndex)
{
	int j = 0;
	int n = 0;
	int k = 0;
	int index = 0;

	if( mFieldSelections[IndexTimestamp] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int64)(seRec->qwTimeStamp) );
		index++;
	}
	if( mFieldSelections[IndexScNumber] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int32)(seRec->dwScNumber) );
		index++;
	}
	if( mFieldSelections[IndexCellNumber] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int32)(seRec->dwCellNumber) );
		index++;
	}
	if( mFieldSelections[IndexParams] ) {
		for( k = 0; k < MAX_PARAMS; k++ ) {
			mOutputVariables[index][k+(recordIndex*MAX_PARAMS)] = (double)(seRec->dnParams[k]);
		}
		index++;
	}
	if( mFieldSelections[IndexData] ) {
		for( n = 0; n < mNumElectrodes; n++ ) {
			for( j = 0; j < SPIKE_NUMPOINTS; j++ ) {
				mOutputVariables[index][(recordIndex*mNumElectrodes*SPIKE_NUMPOINTS)+(n*SPIKE_NUMPOINTS)+j] = (double)(seRec->snData[j].snADVal[0]);
			}
		}
		index++;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//********************************************************************************************************************
//********************************************************************************************************************
ierr Processor::ProcessDataST( mxArray *plhs[] )
{
	switch(mExtractionMode)
	{
	case ExtractionModeAll:
		return( ProcessDataAllST(plhs) ) ;
	case ExtractionModeRecordRange:
		return( ProcessDataRecRangeST(plhs) ) ;
	case ExtractionModeRecordList:
		return( ProcessDataRecListST(plhs) ) ;
	case ExtractionModeTsRange:
		return( ProcessDataTsRangeST(plhs) ) ;
	case ExtractionModeTsList:
		return( ProcessDataTsListST(plhs) ) ;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataAllST(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, numRecs ) != Nlx2MatOK ) { return(-1); }

	STRec* stRec = NULL;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&stRec));
		InsertDataST(stRec, i);
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecRangeST(mxArray *plhs[])
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

	STRec* stRec = NULL;
	int index = 0;
	for( int i = (int)(mModeParameters[0]); i <= (int)(mModeParameters[1]); i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&stRec));
		InsertDataST(stRec, index);
		index++;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecListST(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	STRec* stRec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		if( (mModeParameters[i] >= 0) && (mModeParameters[i] < numRecs) ) {
			mDataBucket.GetData((int)(mModeParameters[i]), 0, (void**)(&stRec));
			InsertDataST(stRec, index);
			index++;
		}
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsRangeST(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( mModeParameters[0] > mModeParameters[1] ) {
		mexPrintf("\tError Processing File, Timestamp Range Values are not in Increasing Order.\n");
		return(-1);
	}

	STRec* stRec = NULL;
	int recs2Process = 0;
	int initialRecIndex = -1;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&stRec));
		if( (stRec->qwTimeStamp >= mModeParameters[0]) && (stRec->qwTimeStamp <= mModeParameters[1]) ) {
			if( initialRecIndex == -1 ) {
				initialRecIndex = i;
			}
			recs2Process++;
		}
	}

	if( AllocateOuputVariables(plhs, recs2Process ) != Nlx2MatOK ) { return(-1); }

	int index = 0;
	for( int i = initialRecIndex; i < initialRecIndex+recs2Process; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&stRec));
		InsertDataST(stRec, index);
		index++;
	}

	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsListST(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	STRec* stRec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		mDataBucket.GetData((unsigned __int64)(mModeParameters[i]), 0, (void**)(&stRec));
		if( stRec->qwTimeStamp == mModeParameters[i]) {
			InsertDataST(stRec, index);
			index++;
		}
	}
	return(0);
}


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
void Processor::InsertDataST(STRec* stRec, int recordIndex)
{
	int j = 0;
	int n = 0;
	int k = 0;
	int index = 0;

	if( mFieldSelections[IndexTimestamp] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int64)(stRec->qwTimeStamp) );
		index++;
	}
	if( mFieldSelections[IndexScNumber] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int32)(stRec->dwScNumber) );
		index++;
	}
	if( mFieldSelections[IndexCellNumber] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int32)(stRec->dwCellNumber) );
		index++;
	}
	if( mFieldSelections[IndexParams] ) {
		for( k = 0; k < MAX_PARAMS; k++ ) {
			mOutputVariables[index][k+(recordIndex*MAX_PARAMS)] = (double)(stRec->dnParams[k]);
		}
		index++;
	}
	if( mFieldSelections[IndexData] ) {
		for( n = 0; n < mNumElectrodes; n++ ) {
			for( j = 0; j < SPIKE_NUMPOINTS; j++ ) {
				mOutputVariables[index][(recordIndex*mNumElectrodes*SPIKE_NUMPOINTS)+(n*SPIKE_NUMPOINTS)+j] = (double)(stRec->snData[j].snADVal[n]);
			}
		}
		index++;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//********************************************************************************************************************
//********************************************************************************************************************
ierr Processor::ProcessDataTT( mxArray *plhs[] )
{
	switch(mExtractionMode)
	{
	case ExtractionModeAll:
		return( ProcessDataAllTT(plhs) ) ;
	case ExtractionModeRecordRange:
		return( ProcessDataRecRangeTT(plhs) ) ;
	case ExtractionModeRecordList:
		return( ProcessDataRecListTT(plhs) ) ;
	case ExtractionModeTsRange:
		return( ProcessDataTsRangeTT(plhs) ) ;
	case ExtractionModeTsList:
		return( ProcessDataTsListTT(plhs) ) ;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataAllTT(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, numRecs ) != Nlx2MatOK ) { return(-1); }

	TTRec* ttRec = NULL;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&ttRec));
		InsertDataTT(ttRec, i);
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecRangeTT(mxArray *plhs[])
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

	TTRec* ttRec = NULL;
	int index = 0;
	for( int i = (int)(mModeParameters[0]); i <= (int)(mModeParameters[1]); i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&ttRec));
		InsertDataTT(ttRec, index);
		index++;
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataRecListTT(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	TTRec* ttRec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		if( (mModeParameters[i] >= 0) && (mModeParameters[i] < numRecs) ) {
			mDataBucket.GetData((int)(mModeParameters[i]), 0, (void**)(&ttRec));
			InsertDataTT(ttRec, index);
			index++;
		}
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsRangeTT(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( mModeParameters[0] > mModeParameters[1] ) {
		mexPrintf("\tError Processing File, Timestamp Range Values are not in Increasing Order.\n");
		return(-1);
	}

	TTRec* ttRec = NULL;
	int recs2Process = 0;
	int initialRecIndex = -1;
	for( int i = 0; i < numRecs; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&ttRec));
		if( (ttRec->qwTimeStamp >= mModeParameters[0]) && (ttRec->qwTimeStamp <= mModeParameters[1]) ) {
			if( initialRecIndex == -1 ) {
				initialRecIndex = i;
			}
			recs2Process++;
		}
	}

	if( AllocateOuputVariables(plhs, recs2Process ) != Nlx2MatOK ) { return(-1); }

	int index = 0;
	for( int i = initialRecIndex; i < initialRecIndex+recs2Process; i++ ) {
		mDataBucket.GetData(i, 0, (void**)(&ttRec));
		InsertDataTT(ttRec, index);
		index++;
	}

	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
ierr Processor::ProcessDataTsListTT(mxArray *plhs[])
{
	int numRecs = mDataBucket.GetDataSourceNumRecs(0);
	if( numRecs <= 0 ) { return(0); }

	if( AllocateOuputVariables(plhs, mNumModeParameters ) != Nlx2MatOK ) { return(-1); }

	TTRec* ttRec = NULL;
	int index = 0;
	for( int i = 0; i < mNumModeParameters; i++ ) {
		mDataBucket.GetData((unsigned __int64)(mModeParameters[i]), 0, (void**)(&ttRec));
		if( ttRec->qwTimeStamp == mModeParameters[i]) {
			InsertDataTT(ttRec, index);
			index++;
		}
	}
	return(0);
}

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
void Processor::InsertDataTT(TTRec* ttRec, int recordIndex)
{
	int j = 0;
	int n = 0;
	int k = 0;
	int index = 0;

	if( mFieldSelections[IndexTimestamp] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int64)(ttRec->qwTimeStamp) );
		index++;
	}
	if( mFieldSelections[IndexScNumber] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int32)(ttRec->dwScNumber) );
		index++;
	}
	if( mFieldSelections[IndexCellNumber] ) {
		mOutputVariables[index][recordIndex] = (double)( (signed __int32)(ttRec->dwCellNumber) );
		index++;
	}
	if( mFieldSelections[IndexParams] ) {
		for( k = 0; k < MAX_PARAMS; k++ ) {
			mOutputVariables[index][k+(recordIndex*MAX_PARAMS)] = (double)(ttRec->dnParams[k]);
		}
		index++;
	}
	if( mFieldSelections[IndexData] ) {
		for( n = 0; n < mNumElectrodes; n++ ) {
			for( j = 0; j < SPIKE_NUMPOINTS; j++ ) {
				mOutputVariables[index][(recordIndex*mNumElectrodes*SPIKE_NUMPOINTS)+(n*SPIKE_NUMPOINTS)+j] = (double)(ttRec->snData[j].snADVal[n]);
			}
		}
		index++;
	}
}
