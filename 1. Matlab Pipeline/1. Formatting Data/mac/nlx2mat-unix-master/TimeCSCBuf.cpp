//********************************************************************************************************************
// CSCBuf.cpp: implementation of the CSCBuf class.
//********************************************************************************************************************
#include "TimeBuf.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//********************************************************************************************************************
//********************************************************************************************************************
TimeCSCBuf::TimeCSCBuf()
{

	CRRec Rec;
	int64 AddrRec;
	int64 AddrTS;
	AddrRec = (int64)(&Rec);
	AddrTS = (int64)(&(Rec.qwTimeStamp));
	TimestampOffsetBytes = (uintd)(AddrTS - AddrRec);
	//TimestampOffsetBytes = ( (__int8*)( &(Buffer[0].qwTimeStamp) ) ) - (Buf);
	RecSizeBytes = sizeof(CRRec);
	DATAFILETYPE = DATAFILETYPE_CSC;
	
}

//********************************************************************************************************************
//********************************************************************************************************************
TimeCSCBuf::~TimeCSCBuf()
{

	//make sure this pointer is null'ed when our buffer 
	//becomes invalid at the time of our destrucition
	Buf = NULL;

}

//********************************************************************************************************************
//********************************************************************************************************************
ierr TimeCSCBuf::GetRec(CRRec** lpRec, const unsigned int AtPos)
{
	return(TimeBuf::GetRec((void**)lpRec, AtPos));
}
