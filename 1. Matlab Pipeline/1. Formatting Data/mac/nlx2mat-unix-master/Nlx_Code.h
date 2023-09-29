#ifndef _NLX_CODE_H_69696913
#define _NLX_CODE_H_69696913

//#pragma pack(push, before_nlx_code)
//#pragma pack(1)

#include "compatibility.h"
#include "Nlx_DataTypes.h"

//returns whether already opened CFile contains a nlx header (aka '########')
BOOL HasHeader(std::fstream & File_In);
BOOL HasHeader(int fd);

//Displays a messagebox with optional error code, and if _DEBUG defined, can optionaly force a break.
int Amb(const char* ErrMsg, __int64 ErrCode = 0, bool BreakPoint = FALSE);

//alloc's a SAFEARRAY and places Src into it, up to DataSizeBytes, setting ArrayDest to point to safearray
//rtn: 0 is ok, -1 is malloc error
//long memtovarcpy(VARIANT* Dest, void* Src, UINT DataSizeBytes);

//takes data out of SAFEARRAY contained in Src.  Input is max size of destination in DataSizeBytes, out is total bytes copied
//rtn: 0 is ok, -1 is null variant, -2 is null array, -3 is wrong variant type, -4 is null datasize, -5 is null data, -6 is incomplete cpy due to size discrepancy
//long vartomemcpy(void* Dest, VARIANT* Src, UINT& DataSizeBytes);

//Takes a variant which presumably has a SAFEARRAY of bytes in it.
//Checks for all NULL's so as not to cause acess violation.
//Only returns pointer if a good pointer is found.
//void* GetArrayFromVariantSafe(VARIANT* Data, int& DataSizeBytes);

// FileTypes: 1=single electrode, 2=stereotrode, 3=timestamp, 4=tetrode
//				5 = CSC, 6 = Events, 7 = Video
// returns NlxError code from NlxErrors.h - 0 is a-ok
// algorithm is now pretty bulletproof with addition of Thane's code for checking ts's
int NlxFileType(int& FileType, std::string filename);

// FileTypes: 1=single electrode, 2=stereotrode, 3=timestamp, 4=tetrode
//				5 = CSC, 6 = Events, 7 = Video
//returns NlxError code from NlxErrors.h - 0 is a-ok
// Similar to NlxFileType() but looks for 100 consecutive timestamps
//int NlxFileTypeTS(std::fstream& cfo);

// Called by NlxFileTypeTS()
//bool TimeStampsInSequence_NT(std::fstream& cfo, int recsize, int offset, int startpos );


//used to take any arbitrary string and remove anything that would prevent it from being a valid
//will automatically shorten your string, so save it if you want to keep the origonal...
//removes "\"
int RemoveFileWildCards(char* FileName);

//used to take any arbitrary string and remove anything that would prevent it from being a valid
//will automatically shorten your string, so save it if you want to keep the origonal...
//leaves "\"
int RemoveDirWildCards(char* DirName);

//int CreateMultiSubDirs(char* DirName);

//Used to remove quotes from around a string.  if no quotes, does nothing.
//Only looks for leading quote, assumes trailing.
CString RemoveSurroundingQuotes(const CString StringIn);

int GetTrackerPosAndColorFromPoint(const unsigned __int32 Point, unsigned int& x, unsigned int& y, BOOL& pr, BOOL& rr, BOOL& pg, BOOL& rg, BOOL& pb, BOOL& rb, BOOL& lu);

//used for saving a window to a bitmap...
//PBITMAPINFO CreateBitmapInfoStruct(HBITMAP hBmp);
//used for saving a window to a bitmap...
//void CreateBMPFile(LPTSTR pszFile, PBITMAPINFO pbi, HBITMAP hBMP, HDC hDC);


// FileTypes: 0=error, 1=single electrode, 2=stereotrode, 3=timestamp, 4=tetrode,
//				5 = CSC, 6 = Events, 7 = Video

struct ERecSizes {
enum  { kTTRecSize_Sun    = 260,
        kTTRecSize_NT     = 304, 
        kSERecSize_NT     = 112, 
        kSTRecSize_NT     = 176, 
        kTSRecSize        = 1, 
        kCSCRecSize_NT    = 1044, 
        kCRRecSize_Sun    = 0,
        kEventRecSize_NT  = 184, 
        kEventRecSize_Sun = 0, 
        kVideoRecSize_NT  = 1828,
        kVideoRecSize_Sun = 0 } ;
};


struct EDataType {
enum  { kErr, kSE, kST, kTS, kTT, kCSC, kEvent, kVideo } ;
};

struct EDataOS {
enum  { kErr, kSun, kNT, kLinuxIntel } ;
};


//----------------------------------------------------------------------------------------------------
//-----------------------------------NLX BUFFER CLASSES FOLLOW------------------------------------
//----------------------------------------------------------------------------------------------------

const unsigned int MinimumBufferSizeDiskBytes = 1048576;

class NlxBuf  
{

public:

	static NlxBuf* FromFile(std::fstream & File, CString FileName);

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	virtual Nlx_Error GetRec(void** lpRec, const unsigned int AtPos);

	//get the Timestamp at the specified position
	virtual Nlx_Error GetTimeStamp(__int64& TimeStamp, const unsigned int AtPos);

	//get timestamp from a record passed in - rec must be a valid record of correct type
	virtual __int64 TimeStampFromRec(const void* lpRec);
	
	//number of recs in file
	unsigned int GetNumRecs();
	
	//open a file
	Nlx_Error OpenFile(const CString FileName);
	
	//what is the name of the open file
	Nlx_Error GetFileName(CString& FileName);
	
	//call to get the state of wether a file is open
	BOOL IsFileOpen();

	//call to get the state of wether a file has a header
	BOOL FileHasHeader();
 
	//get the header - pass in an empty pointer to a character (don't pass a pointer to alloc'd mem).
	Nlx_Error GetHeader(char*& HeaderString);
	
	//get the value for a particualar string in the header - searches for "MetaString", then returns reast of line.
	Nlx_Error GetHeaderMetaData(const CString MetaString, CString& MetaValue);

	//what type of file is this - in case we have a NlxBuf pointer instead of derived class pointer, than can still get type.
	int GetFileType();

	//const/dest
	NlxBuf();
	virtual ~NlxBuf();

protected:	//funcs

	//this grabs a section of the file from disk into the internal buffers...
	Nlx_Error ReadChunk(UINT StartPos);

	//makes sure the correct type of datafile was opened
	Nlx_Error ValidateFileType();
	
protected:	//vars

	//the actual buffer where records are read in from disk
	__int8* Buf;
	//position of the first record in the buffer in the disk file (offset into file).
	unsigned int PosInFileOfBufStart;
	//number of records in file...
	unsigned int NumRecsInFile;	
	//the size of each record
	unsigned int RecSizeBytes;
	//the type of the datafile defined in nlx_datatypes.h
	int DataFileType;
	//the file object
	std::fstream DataFile;
	//does the file have a header?
	BOOL FileHeader;
	//is the file open
	BOOL FileOpen;
	//buffer where header data ends up...
	char HeaderBuf[16384];
	//makes everything thread safe
	//CRITICAL_SECTION ThreadSafe;
	//how far into the record is the timestamp?
	unsigned int TimestampOffsetBytes;
};


/*
//--------------------------------------------
class NlxVideoBuf : public NlxBuf  
{
public:
	NlxVideoBuf();
	virtual ~NlxVideoBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	Nlx_Error GetRec(VideoRec** lpRec, const unsigned int AtPos);
		
private:
	VideoRec Buffer[ ((MinimumBufferSizeDiskBytes / sizeof(VideoRec)) +1) ];
};


//--------------------------------------------
class NlxTTBuf : public NlxBuf  
{
public:
	NlxTTBuf();
	virtual ~NlxTTBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	Nlx_Error GetRec(TTRec** lpRec, const unsigned int AtPos);
		
private:
	TTRec Buffer[ ((MinimumBufferSizeDiskBytes / sizeof(TTRec)) +1) ];
};


//--------------------------------------------
class NlxSTBuf : public NlxBuf  
{
public:
	NlxSTBuf();
	virtual ~NlxSTBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	Nlx_Error GetRec(STRec** lpRec, const unsigned int AtPos);
		
private:
	STRec Buffer[ ((MinimumBufferSizeDiskBytes / sizeof(STRec)) +1) ];
};


//--------------------------------------------
class NlxSEBuf : public NlxBuf  
{
public:
	NlxSEBuf();
	virtual ~NlxSEBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	Nlx_Error GetRec(SERec** lpRec, const unsigned int AtPos);
		
private:
	SERec Buffer[ ((MinimumBufferSizeDiskBytes / sizeof(SERec)) +1) ];
};
*/

//--------------------------------------------
class NlxCSCBuf : public NlxBuf  
{
public:
	NlxCSCBuf();
	virtual ~NlxCSCBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	Nlx_Error GetRec(CRRec** lpRec, const unsigned int AtPos);
		
private:
	CRRec Buffer[ ((MinimumBufferSizeDiskBytes / sizeof(CRRec)) +1) ];
};


//--------------------------------------------
class NlxEventBuf : public NlxBuf  
{
public:
	NlxEventBuf();
	virtual ~NlxEventBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	Nlx_Error GetRec(EventRec** lpRec, const unsigned int AtPos);
		
private:
	EventRec Buffer[ ((MinimumBufferSizeDiskBytes / sizeof(EventRec)) +1) ];
};


/*
//--------------------------------------------
class NlxTSBuf : public NlxBuf  
{
public:
	NlxTSBuf();
	virtual ~NlxTSBuf();

	//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
	Nlx_Error GetRec(__int64** lpRec, const unsigned int AtPos);
		
private:
	__int64 Buffer[ ((MinimumBufferSizeDiskBytes / sizeof(__int64)) +1) ];
};

*/







//----------------------------------------------------------------------------------------------------
//#pragma pack(pop, before_nlx_code) // back to old packing scheme

#endif //_NLX_CODE_H_69696913

