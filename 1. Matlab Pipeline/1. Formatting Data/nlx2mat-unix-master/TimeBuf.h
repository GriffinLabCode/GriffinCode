//********************************************************************************************************************
//	TimeBuf.h
//********************************************************************************************************************
#ifndef _Time_TIME
#define _Time_TIME

//#pragma pack(push, before_time)
//#pragma pack(1)
#include "compatibility.h"
#include <fstream>
#include <string>

#include "Nlx2MatEVInclude.h"

//----------------------------------------------------------------------------------------------------
//-----------------------------------Time BUFFER CLASSES FOLLOW------------------------------------
//----------------------------------------------------------------------------------------------------

class TimeBuf  
{
public:

	static TimeBuf* FromFile(std::fstream  &File, CString FileName);

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	virtual ierr GetRec(void** lpRec, const unsigned int AtPos);

	//get the Timestamp at the specified position
	virtual ierr GetTimeStamp(int64& TimeStamp, const unsigned int AtPos);

	//get timestamp from a record passed in - rec must be a valid record of correct type
	virtual int64 TimeStampFromRec(const void* lpRec);
	
	//number of recs in file
	unsigned int GetNumRecs() { return(NumRecsInFile); }
	
	//open a file
	ierr OpenFile(CString FileName);
	
	//what is the name of the open file
	void GetFileName(CString& FileName) { FileName = ThisFileName; }
	
	//call to get the state of wether a file is open
	BOOL IsFileOpen() { return(FileOpen); }

	//call to get the state of wether a file has a header
	BOOL FileHasHeader() { return(FileHeader); }
 
	//get the header - pass in an empty pointer to a character (don't pass a pointer to alloc'd mem).
	void GetHeader(char*& HeaderString) { HeaderString = HeaderBuf; }
	
	//get the value for a particualar string in the header - searches for "MetaString", then returns reast of line.
	ierr GetHeaderMetaData(const CString MetaString, CString& MetaValue);

	//what type of file is this - in case we have a TimeBuf pointer instead of derived class pointer, than can still get type.
	int GetFileType() { return(DATAFILETYPE); }

	//const/dest
	TimeBuf();
	virtual ~TimeBuf();

protected:	//vars

	//The file itself
	std::fstream File;
	
	//file handle for mmap
	int fd;
	long mmapSize;
	
	//the actual buffer where records are read in from disk
	__int8* Buf;
	__int8* BufValueForUnmappingFile;
	//number of records in file...
	unsigned int NumRecsInFile;	
	//the size of each record
	unsigned int RecSizeBytes;
	//the type of the DataFileMap defined in Time_datatypes.h
	int DATAFILETYPE;
	//the file object

	void *DataFileMap;
	
	
	//does the file have a header?
	BOOL FileHeader;
	//is the file open
	BOOL FileOpen;
	//buffer where header data ends up...
	char HeaderBuf[NlxHeaderLength];
	//makes everything thread safe
	//CRITICAL_SECTION ThreadSafe;
	//how far into the record is the timestamp?
	unsigned int TimestampOffsetBytes;
	
	CString ThisFileName;
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeVideoBuf : public TimeBuf  
{
public:
	TimeVideoBuf();
	virtual ~TimeVideoBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(VideoRec** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeTTBuf : public TimeBuf  
{
public:
	TimeTTBuf();
	virtual ~TimeTTBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(TTRec** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeSTBuf : public TimeBuf  
{
public:
	TimeSTBuf();
	virtual ~TimeSTBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(STRec** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeSEBuf : public TimeBuf  
{
public:
	TimeSEBuf();
	virtual ~TimeSEBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(SERec** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeCSCBuf : public TimeBuf  
{
public:
	TimeCSCBuf();
	virtual ~TimeCSCBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(CRRec** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeEventBuf : public TimeBuf  
{
public:
	TimeEventBuf();
	virtual ~TimeEventBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(EventRec** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeTSBuf : public TimeBuf  
{
public:
	TimeTSBuf();
	virtual ~TimeTSBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(int64** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
class TimeMClustTSBuf : public TimeBuf  
{
public:
	TimeMClustTSBuf();
	virtual ~TimeMClustTSBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	ierr GetRec(int64** lpRec, const unsigned int AtPos);
};

//********************************************************************************************************************
//********************************************************************************************************************
//#pragma pack(pop, before_time) // back to old packing scheme

#endif //_Time_TIME
