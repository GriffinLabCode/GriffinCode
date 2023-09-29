//********************************************************************************************************************
//	Nlx2MatSpikeInclude.h
//********************************************************************************************************************

#include "mex.h"
#include <vector>
#include "Nlx_Error.h"
#include "Nlx_DataTypes.h"
#include "Nlx_ObjNames.h"
#include "Nlx_Code.h"

const int NlxHeaderLength = 16384;
const int DATAFILETYPE_MCLUST = 20;

#define ierr int
#define uintd UINT
#define intd int
#define int64 __int64
#define string CString
#define uint32 UINT
#define int16 short
#define uint8 unsigned __int8

const int Nlx2MatError = -1;
const int Nlx2MatOK = 0;

const int MaxFilenameLength = 1000;
const int MaxStringLength = 1000;
const int MaxHeaderLine = 128;
const int NlxHeaderSize = 16384;

const int ExtractionModeAll = 1;
const int ExtractionModeRecordRange = 2;
const int ExtractionModeRecordList = 3;
const int ExtractionModeTsRange = 4;
const int ExtractionModeTsList = 5;

const int InputParamFilename = 0;
const int InputParamFieldList = 1;
const int InputParamExtractHeader = 2;
const int InputParamExtractionMode = 3;
const int InputParamInputArray = 4;

//moved definition of MaxFields to ProcessorXX.h due to conflict
//	const int MaxFields = 6;
//	const int MaxFields = 5;

const int IndexTimestamp = 0;
const int IndexEventId = 1;
const int IndexTtl = 2;
const int IndexExtras = 3;
const int IndexEventString = 4;

//from Nlx2MatCSCInclude.h
const int IndexChannelNumbers = 1;
const int IndexSampleFrequency = 2;
const int IndexNumberValidSamples = 3;
const int IndexSamples = 4;
