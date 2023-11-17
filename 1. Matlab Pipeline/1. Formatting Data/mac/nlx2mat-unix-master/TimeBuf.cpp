//********************************************************************************************************************
//	TimeBuf.cpp: implementation of the SpikeBuf claTime.
//********************************************************************************************************************
#include "TimeBuf.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//********************************************************************************************************************
//********************************************************************************************************************
TimeBuf::TimeBuf()
{
//	InitializeCriticalSection(&ThreadSafe);
//	EnterCriticalSection(&ThreadSafe);
	
	Buf = NULL;
	BufValueForUnmappingFile = NULL;
	NumRecsInFile = 0;
	RecSizeBytes = 0;
	DATAFILETYPE = -1;
	FileHeader = FALSE;
	FileOpen = FALSE;
	TimestampOffsetBytes = 0;
	memset(HeaderBuf, 0, NlxHeaderLength * sizeof(char));

//	LeaveCriticalSection(&ThreadSafe);
}

//********************************************************************************************************************
//********************************************************************************************************************
TimeBuf::~TimeBuf()
{
	if( FileOpen ) {
		munmap(BufValueForUnmappingFile, mmapSize);
		close(fd);
	}
}

//********************************************************************************************************************
//********************************************************************************************************************
TimeBuf* TimeBuf::FromFile(std::fstream& File, CString FileName)
{
	TimeBuf* Obj = NULL;
	int FileType;
	int err;

	//must check to see if we have a .t file, b/c otherwise, nlxFileType will think its a .nts file and thats bad
	char buf[100];
	File.read( buf, 100 );
	CString str = buf;

	File.seekg(0, std::ios_base::beg);
	if( str.Find("%%BEGINHEADER") != -1 ) {
		//now close it, so we can reopen in Objfer
		File.close();

		Obj = new TimeMClustTSBuf;
		if (NULL == Obj) { return(NULL); }

		//now reopen into TimeObj
		err = Obj->OpenFile(FileName);
		if (0 != err) {
			return(NULL);
		}
		return(Obj);
	}

	err = NlxFileType(FileType, FileName);
	if (0 != err) {
		return(NULL);
	}

	switch (FileType) {
		case 1: {
			Obj = new TimeSEBuf;
			break;
		}
		case 2: {
			Obj = new TimeSTBuf;
			break;
		}
		case 3: {
			Obj = new TimeTSBuf;
			break;
		}
		case 4: {
			Obj = new TimeTTBuf;
			break;
		}
		case 5: {
			Obj = new TimeCSCBuf;
			break;
		}
		case 6: {
			Obj = new TimeEventBuf;
			break;
		}
		case 7: {
			Obj = new TimeVideoBuf;
			break;
		}
	}

	if (NULL == Obj) {
		Amb("Error allocating memory for Time Buffer Object, Pointer is equal to Null, cannot proceed");
		return(NULL); 
	}

	//now close it, so we can reopen in Objfer
	File.close();
	//now reopen into TimeObj
	err = Obj->OpenFile(FileName);
	if (0 != err) {
		return(NULL);
	}

	return(Obj);
}

//********************************************************************************************************************
//********************************************************************************************************************
//
//in the GCC/UNIX version of this function file access is done with low-level POSIX functions and not std::fstream because
//mmap needs the raw file handle which is not available when using std::fstream.
//
ierr TimeBuf::OpenFile(CString FileName)
{
	ierr Ret;
	ULONGLONG FileSizeBytes;
	//CFileException e;
	int FileType;
	uintd BytesRead;
	struct stat statbuf;
		
	//open file
	fd=0;
	fd = open( FileName, O_RDONLY);
	
	if ( fd == 0  ) { // opens file fname_buf.
		Amb("Error opening file; Is the file/path name correct? Win Err:");
		return(0);
	}

	FileOpen = TRUE;
	ThisFileName = FileName;

	//get file size
 	fstat (fd,&statbuf);
	FileSizeBytes = statbuf.st_size; //File.GetLength();    // size of file in bytes

	//must check to see if we have a .t file, b/c otherwise, nlxFileType will think its a .nts file and thats bad
	char buf[100];
	CString str;
	int ret = -1;
	int position = 0;
	ULONGLONG newPosition = 0;

	read(fd,buf,100);
	str = buf;
	if( str.Find("%%BEGINHEADER") != -1 ) {
		//now close it, so we can reopen in Objfer

		ret = str.Find("%%ENDHEADER");
		while(  ret == -1 ) {

			memcpy( buf, &buf[80], sizeof(char)*20 );
			read(fd,&buf[20], 80 );

			str = buf;
			position += 80;
			ret = str.Find("%%ENDHEADER");
		}

		position += ret;
		position += 12;

		newPosition=lseek(fd,position,SEEK_SET);		
		FileSizeBytes -= newPosition;

	} else {
		lseek(fd,0,SEEK_SET);
		Ret = NlxFileType(FileType,FileName);
		if (Ret == NLX_OK) {
			if (FileType != DATAFILETYPE) {
				FileOpen = FALSE;
				close(fd);
				Amb("Invalid FileType found, cannot proceed");
				return(NLX_WRONGFILETYPE);
			}
		} else {
			Amb("Unable to calculate file type: Error Code - ", Ret);
		}

		lseek(fd,0,SEEK_SET);
		FileHeader = HasHeader(fd);
		if (FileHeader) {
			//do the actual read
			lseek(fd,0,SEEK_SET);
			BytesRead = read(fd,HeaderBuf,NlxHeaderLength);
			
			//err check
			if (BytesRead != NlxHeaderLength ) {
				Amb("Insufficient read length.  Likely corrupt header or invalid file.  Bytes read:", BytesRead);
				//LeaveCriticalSection(&ThreadSafe);
				return(NLX_RANGE);
			}

			FileSizeBytes -= NlxHeaderLength;
		} 

	}

	NumRecsInFile = (unsigned int)(FileSizeBytes / ((ULONGLONG)RecSizeBytes));  // count of total records in file

	if (FileSizeBytes % RecSizeBytes) {
		Amb("FileSizeBytes=", FileSizeBytes);
		Amb("Corrupt file - incomplete record encountered: Record size in bytes :", RecSizeBytes);
	}
	
	/*DataFileMap = CreateFileMapping(File.m_hFile, NULL, PAGE_READONLY | SEC_COMMIT, 0, 0, NULL);
	if (DataFileMap == NULL) {
			Ret = GetLastError();
			Amb("Error Creating File Mapping, GetLastError = ", Ret);
			FileOpen = FALSE;
			File.Close();
			//LeaveCriticalSection(&ThreadSafe);
			return(Ret);
	}
	
	
	Buf = (char*)( MapViewOfFileEx(DataFileMap, FILE_MAP_READ, 0, 0, 0, NULL) );
	BufValueForUnmappingFile = Buf;
	if (Buf == NULL) {
			Ret = GetLastError();
			Amb("Error Mapping View Of File, GetLastError = ", Ret);
			FileOpen = FALSE;
			CloseHandle(DataFileMap);
			File.close();
			//LeaveCriticalSection(&ThreadSafe);
			return(Ret);
	}
	*/
		
	mmapSize=statbuf.st_size;
	Buf = (char*) mmap (0, mmapSize, PROT_READ, MAP_SHARED, fd, 0);
	BufValueForUnmappingFile = Buf;
	
	if( position != 0 ) {
		Buf += position;
	}

	//adjust for header
	if (FileHeader) {
		Buf += NlxHeaderLength;
	}
	
	return(0);
}

//********************************************************************************************************************
//get the record at the specified position - pass in an empty pointer to a record (don't pass a pointer to alloc'd mem).
//********************************************************************************************************************
ierr TimeBuf::GetRec(void** lpRec, unsigned int AtPos)
{
	int Ret;

	//EnterCriticalSection(&ThreadSafe);

	Ret = NLX_OK;

	if (!FileOpen) {
		Amb("Please open a file before attempting to get records.");
		//LeaveCriticalSection(&ThreadSafe);
		return(NLX_FILENOTOPEN);
	}

	if (NumRecsInFile == 0) { 
		Amb("Empty File.  NumRecs = 0.");
		//LeaveCriticalSection(&ThreadSafe);
		return(NLX_RANGE); 
	}

	*lpRec = &(Buf[(AtPos*RecSizeBytes)]);

	//LeaveCriticalSection(&ThreadSafe);
	return(Ret);
}

//********************************************************************************************************************
//get the Timestamp at the specified position
//********************************************************************************************************************
ierr TimeBuf::GetTimeStamp(int64& TimeStamp, const unsigned int AtPos)
{
	__int8* lpRec;
	int Ret;

	Ret = GetRec((void**)(&lpRec), AtPos);
	if (Ret != NLX_OK) { return(Ret); }

	TimeStamp = *( (int64*)( &(lpRec[TimestampOffsetBytes]) ) );

	return(NLX_OK);
}

//********************************************************************************************************************
//get timestamp from a record passed in - rec must be a valid record of correct type
//********************************************************************************************************************
int64 TimeBuf::TimeStampFromRec(const void* lpRec)
{
	__int8* Rec = (__int8*)lpRec;
	if (NULL == Rec) { return(-1); }

	//this is a special case for .t mclust files
	if( TimestampOffsetBytes == 696969 ) {
		unsigned __int32 time1 = *((unsigned __int32*)lpRec);

		int64 time2 = (0x000000FF & time1) << 24;
		time2 += (0x0000FF00 & time1) << 8;
		time2 += (0x00FF0000 & time1) >> 8;
		time2 += (0xFF000000 & time1) >> 24;
		time2 *= 100;
		return( time2 );
	}
	return( *( (int64*)(&(Rec[TimestampOffsetBytes])) ) );
}

//********************************************************************************************************************
//get the value for a particualar string in the header - searches for "MetaString", then returns rest of line.
//********************************************************************************************************************
ierr TimeBuf::GetHeaderMetaData(const CString MetaString, CString& MetaValue)
{
	char* Header = NULL;
	int i;
	
	GetHeader(Header);
	Header[NlxHeaderLength-1] = '\0'; //make sure we don't run off end of file
	
	for( i = 0; i < NlxHeaderLength; i++) {
		if ( 0 == strncmp( &(Header[i]), MetaString, MetaString.GetLength() ) ) {
			break;
		}
	}
	
	if (i >= NlxHeaderLength) { return(NLX_RANGE); }
	
	i += MetaString.GetLength();
	
	if (i >= NlxHeaderLength) { return(NLX_NOTDONE); }
	
	MetaValue = CString( &(Header[i]) );
	
	int Eol = MetaValue.FindOneOf("\r\n");
	if (Eol > 0) {
		MetaValue = MetaValue.Left(Eol);
	}
	
	MetaValue.Remove(' ');
	MetaValue.Remove('\t');
	MetaValue.Remove('\r');
	MetaValue.Remove('\n');
	
	return(NLX_OK);
}

