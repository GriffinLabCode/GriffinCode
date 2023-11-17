//********************************************************************************************************************
// STBuf.cpp: implementation of the STBuf class.
//********************************************************************************************************************
#include "TimeBuf.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//********************************************************************************************************************
//********************************************************************************************************************
TimeSTBuf::TimeSTBuf()
{

	STRec Rec;
	int64 AddrRec;
	int64 AddrTS;
	AddrRec = (int64)(&Rec);
	AddrTS = (int64)(&(Rec.qwTimeStamp));
	TimestampOffsetBytes = (uintd)(AddrTS - AddrRec);
	//TimestampOffsetBytes = ( (__int8*)( &(Buffer[0].qwTimeStamp) ) ) - (Buf);
	RecSizeBytes = sizeof(STRec);
	DATAFILETYPE = DATAFILETYPE_STSPIKE;

}

//********************************************************************************************************************
//********************************************************************************************************************
TimeSTBuf::~TimeSTBuf()
{

	//make sure this pointer is null'ed when our buffer 
	//becomes invalid at the time of our destrucition
	Buf = NULL;

}

//********************************************************************************************************************
//********************************************************************************************************************
ierr TimeSTBuf::GetRec(STRec** lpRec, const unsigned int AtPos)
{
	return(TimeBuf::GetRec((void**)lpRec, AtPos));
}
