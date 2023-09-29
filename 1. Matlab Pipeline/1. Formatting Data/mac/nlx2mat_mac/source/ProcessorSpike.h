//********************************************************************************************************************
//	Processor.h
//********************************************************************************************************************
#include "FileDataBucket.h"
#include "GeneralOperations.h"


//params copied from Nlx2MatSpikeInclude.h

const int MaxFields = 5;
const int IndexScNumber = 1;
const int IndexCellNumber = 2;
const int IndexParams = 3;
const int IndexData = 4;

class Processor
{
public:
	Processor(void);
	virtual ~Processor(void);

	void ProcessFile(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] );

protected:
	ierr AllocateOuputVariables(mxArray *plhs[], int numRecs );

	ierr ProcessDataSE(mxArray *plhs[]);
	ierr ProcessDataAllSE(mxArray *plhs[]);
	ierr ProcessDataRecRangeSE(mxArray *plhs[]);
	ierr ProcessDataRecListSE(mxArray *plhs[]);
	ierr ProcessDataTsRangeSE(mxArray *plhs[]);
	ierr ProcessDataTsListSE(mxArray *plhs[]);
	void InsertDataSE(SERec* seRec, int recordIndex);

	ierr ProcessDataST(mxArray *plhs[]);
	ierr ProcessDataAllST(mxArray *plhs[]);
	ierr ProcessDataRecRangeST(mxArray *plhs[]);
	ierr ProcessDataRecListST(mxArray *plhs[]);
	ierr ProcessDataTsRangeST(mxArray *plhs[]);
	ierr ProcessDataTsListST(mxArray *plhs[]);
	void InsertDataST(STRec* stRec, int recordIndex);

	ierr ProcessDataTT(mxArray *plhs[]);
	ierr ProcessDataAllTT(mxArray *plhs[]);
	ierr ProcessDataRecRangeTT(mxArray *plhs[]);
	ierr ProcessDataRecListTT(mxArray *plhs[]);
	ierr ProcessDataTsRangeTT(mxArray *plhs[]);
	ierr ProcessDataTsListTT(mxArray *plhs[]);
	void InsertDataTT(TTRec* ttRec, int recordIndex);

private:
	GeneralOperations mGeneralOps;
	FileDataBucket mDataBucket;

	CString mFilename;					//parameter 1, our filename
	BOOL mFieldSelections[MaxFields];	//parameter 2, our field selection list
	BOOL mHeaderSelected;				//paramter 3, our header selection variable
	char* mHeader;		//
	int mExtractionMode;				//parameter 4, extraction mode
	double* mModeParameters;			//get param 5 if necessary, thats our input array based on mode selection
	int mNumModeParameters;
	UINT mFileType;
	int mNumElectrodes;
	std::vector<double*> mOutputVariables;
};
