//********************************************************************************************************************
//	Processor.h
//********************************************************************************************************************
#include "FileDataBucket.h"
#include "GeneralOperations.h"


const int MaxFields = 5;

class Processor
{
public:
	Processor(void);
	virtual ~Processor(void);

	void ProcessFile(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] );

protected:
	ierr AllocateOuputVariables(mxArray *plhs[], int numRecs );

	ierr ProcessData(mxArray *plhs[]);
	ierr ProcessDataAll(mxArray *plhs[]);
	ierr ProcessDataRecRange(mxArray *plhs[]);
	ierr ProcessDataRecList(mxArray *plhs[]);
	ierr ProcessDataTsRange(mxArray *plhs[]);
	ierr ProcessDataTsList(mxArray *plhs[]);
	void InsertData(EventRec* rec, int recordIndex);

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

	mxArray* mMatEventStringCell;
};


