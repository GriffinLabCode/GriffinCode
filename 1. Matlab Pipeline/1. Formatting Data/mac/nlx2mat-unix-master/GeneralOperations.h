//******************************************************************************************************************************************************
//	GeneralOperations.h
//	Author: Kevin Iamiceli
//	Modified March 9, 2003
//	Version 3.00
//******************************************************************************************************************************************************
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
};


