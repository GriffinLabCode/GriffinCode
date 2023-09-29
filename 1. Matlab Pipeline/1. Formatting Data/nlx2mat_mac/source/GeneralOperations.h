//******************************************************************************************************************************************************
//	GeneralOperations.h
//	Author: Kevin Iamiceli
//	Modified March 9, 2003
//	Version 3.00
//******************************************************************************************************************************************************


#include "mex.h"
#include "compatibility.h"
#include <fstream>

//const int Nlx2MatError = -1;
//const int Nlx2MatOK = 0;
const int MinInputParametersMat2Nlx = 7;


const int Mat2NlxInputParamFilename = 0;
const int Mat2NlxInputParamAppendFile = 1;
const int Mat2NlxInputParamExtractionMode = 2;
const int Mat2NlxInputParamInputArray = 3;
const int Mat2NlxInputParamExpectedNumRecs = 4;
const int Mat2NlxInputParamFieldList = 5;



class GeneralOperations
{
public:
	GeneralOperations(void);
	virtual ~GeneralOperations(void);

	int GetInputParameters(const mxArray *phs[], int nlhs, CString& filename, BOOL* fieldSelections, int maxFields, BOOL& headerSelected, int& extractionMode, double* &modeParameters, int& numModeParameters);
	int GetInputString(CString& inputStr, const mxArray *prhs[], int prhsIndex);
	int GetFieldSelections(const mxArray *prhs[], int prhsIndex, BOOL* fieldSelections, const int numFields, int& numFieldsSelected);
	int GetModeParameters(const mxArray *prhs[], int prhsIndex, double* &modeParameters, int& numModeParameters);
	int LoadHeader(mxArray *plhs[],	int plhsIndex, char* headerBuffer );


int GetInputParametersMat2Nlx(const mxArray *prhs[], int nrhs, CString& filename, BOOL& appendToFile, int& extractionMode, double* &modeParameters, int& numModeParameters, int& expectedNumRecords, BOOL* fieldSelections, int maxFields);

int GetInputNumericArrayPtr(const mxArray *prhs[], int nrhs, int prhsIndex, double* &inputArray, int expectedM, int expectedN);

//int OpenFileMat2Nlx( CFile &fileHandle, BOOL appendToFile, CString filename, int fileTypeExpected);
int OpenFileMat2Nlx( std::fstream &fileHandle, BOOL appendToFile, CString filename, int fileTypeExpected);

BOOL ValidRecToExtract(int curRecordIndex, unsigned __int64 curRecordTimestamp, int extractionMode, double* modeParameters, int numModeParameters);
BOOL IsInRecordRange(int curRecordIndex, double* modeParameters, int numModeParameters);
BOOL IsInRecordList(int curRecordIndex, double* modeParameters, int numModeParameters);
BOOL IsInTimestampRange(unsigned __int64 curRecordTimestamp, double* modeParameters, int numModeParameters);
BOOL IsInTimestampList(unsigned __int64 curRecordTimestamp, double* modeParameters, int numModeParameters);
int ProcessHeader(const mxArray *prhs[], int nrhs,  int prhsIndex, std::fstream& fileHandle);

//int ProcessHeader2(const mxArray *prhs[], int nrhs,  int prhsIndex, CFile& fileHandle);
};


