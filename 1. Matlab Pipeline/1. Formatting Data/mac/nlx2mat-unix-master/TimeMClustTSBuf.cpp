//********************************************************************************************************************
// TimeMClustTSBuf.cpp: implementation of the TimeMClustTSBuf class.
//********************************************************************************************************************
#include "TimeBuf.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//********************************************************************************************************************
//********************************************************************************************************************
TimeMClustTSBuf::TimeMClustTSBuf()
{

	TimestampOffsetBytes = 696969;
	RecSizeBytes = sizeof(unsigned __int32);
	DATAFILETYPE = DATAFILETYPE_MCLUST;

}

//********************************************************************************************************************
//********************************************************************************************************************
TimeMClustTSBuf::~TimeMClustTSBuf()
{

	//make sure this pointer is null'ed when our buffer 
	//becomes invalid at the time of our destrucition
	Buf = NULL;

}

//********************************************************************************************************************
//********************************************************************************************************************
ierr TimeMClustTSBuf::GetRec(int64** lpRec, const unsigned int AtPos)
{
	return(TimeBuf::GetRec((void**)lpRec, AtPos));
}
