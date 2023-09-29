//********************************************************************************************************************
// EventBuf.cpp: implementation of the EventBuf class.
//********************************************************************************************************************
#include "TimeBuf.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//********************************************************************************************************************
//********************************************************************************************************************
TimeEventBuf::TimeEventBuf()
{
	//EnterCriticalSection(&ThreadSafe);

	EventRec Rec;
	int64 AddrRec;
	int64 AddrTS;
	AddrRec = (int64)(&Rec);
	AddrTS = (int64)(&(Rec.qwTimeStamp));
	TimestampOffsetBytes = (uintd)(AddrTS - AddrRec);
	//TimestampOffsetBytes = ( (__int8*)( &(Buffer[0].qwTimeStamp) ) ) - (Buf);
	RecSizeBytes = sizeof(EventRec);
	DATAFILETYPE = DATAFILETYPE_EVENT;

	//LeaveCriticalSection(&ThreadSafe);
}

//********************************************************************************************************************
//********************************************************************************************************************
TimeEventBuf::~TimeEventBuf()
{
	//EnterCriticalSection(&ThreadSafe);

	//make sure this pointer is null'ed when our buffer 
	//becomes invalid at the time of our destrucition
	Buf = NULL;

	//LeaveCriticalSection(&ThreadSafe);
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr TimeEventBuf::GetRec(EventRec** lpRec, const unsigned int AtPos)
{
	return(TimeBuf::GetRec((void**)lpRec, AtPos));
}
