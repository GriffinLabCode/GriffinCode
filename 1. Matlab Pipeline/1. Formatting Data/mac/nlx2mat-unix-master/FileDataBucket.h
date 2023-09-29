//********************************************************************************************************************
//	FileDataBucket.h
//********************************************************************************************************************
//#pragma once
#include "TimeBuf.h"

const uintd MaxDataSources = 256;
const uintd MaxHandlers = 10;

struct BukHash {
	int64*	TS;
	uintd*	Index;
};

class FileDataBucket
{
public:
	FileDataBucket(void);
	virtual ~FileDataBucket(void);

//	void AddEventHandler(const DataBucketEventHandlerInterface& Handler);
	ierr  GetData(const unsigned __int64 TimeStamp, const uintd DataSourceIndex, void** Data);
	ierr  GetData(const int DataIndex, const uintd DataSourceIndex, void** Data);

	ierr  GetDataSourceIndex(const string& SourceName, uintd& SourceIndex);
	ierr  GetDataSourceName(const uintd SourceIndex, string& SourceName);
	ierr  GetDataSourceType(const uintd SourceIndex, uintd& Type);
	virtual int GetDataSourceNumRecs(const int sourceIndex);
	virtual ierr GetDataSourceHeader(const int sourceIndex, char* &header );

	void GetGlobalTimeRange(__int64& TimeStartAll, __int64& TimeEndAll);
	uintd GetNumOpenDataSources();

	ierr Open(string& Name);
	ierr Close(const uintd SourceIndex);
//*	ierr  ReadConfigFile(CFile& fileHandle);
	void ShowProperties();
//*	ierr  WriteConfigFile(CFile& fileHandle);
	ierr GetHeaderMetaData(const uintd SourceIndex, const string MetaString, string& MetaValue); //get the value for a particualar string in the header - searches for "MetaString", then returns reast of line.

private:
	ierr GenerateTSHashTable();	//this makes a quick table of approximate locations in each open file for where to find a given timestamp - should take no more than 1 second to complete on 1 GHz machine

public:
	TimeBuf* DataSources[MaxDataSources];
	string	DataSourceNames[MaxDataSources];
	uintd	NumFileDataBucketSources;

	BukHash	TSIdxHash[MaxDataSources];
	uintd	NumHashes[MaxDataSources];

//	DataBucketEventHandlerInterface* HandlerList[MaxHandlers];
	uintd NumHandlers;
};
