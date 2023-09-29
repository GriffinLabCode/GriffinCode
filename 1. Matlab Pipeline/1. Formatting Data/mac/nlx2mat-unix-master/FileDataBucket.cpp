//********************************************************************************************************************
//	FileDataBucket.cpp
//********************************************************************************************************************
#include "FileDataBucket.h"
#include <algorithm>

//********************************************************************************************************************
//********************************************************************************************************************
FileDataBucket::FileDataBucket(void)
{
	NumFileDataBucketSources = 0;
	memset(DataSources, 0, MaxDataSources*sizeof(NlxBuf*));
	memset(TSIdxHash, 0, MaxDataSources * sizeof(BukHash));
	memset(NumHashes, 0, MaxDataSources * sizeof(uintd));
//	memset(HandlerList, 0, MaxHandlers * sizeof(DataBucketEventHandlerInterface*));
	NumHandlers = 0;
}

//********************************************************************************************************************
//********************************************************************************************************************
FileDataBucket::~FileDataBucket(void)
{
	for(uintd i = 0; i < NumFileDataBucketSources; i++) {
		delete DataSources[i];
		DataSources[i] = NULL;
		DataSourceNames[i] = "";
		delete [] TSIdxHash[i].TS;
		TSIdxHash[i].TS = NULL;
		delete [] TSIdxHash[i].Index;
		TSIdxHash[i].Index = NULL;
		NumHashes[i] = 0;
	}
}

ierr FileDataBucket::Open(string& Name)
{
	ierr err;
	//CFileException eerr;
	//CFile DataFile;
	std::fstream DataFile;
	BOOL Open;
	//try {
		//Open = DataFile.Open(Name, CFile::modeRead | CFile::shareDenyNone | CFile::osSequentialScan, &eerr);
		DataFile.open( Name, std::ios_base::in);
	//} catch (CFileException* e) {
	//	err = e->m_lOsError;
	//	Amb("Exception opening file; microsoft error code:", e->m_lOsError);
	//	e->Delete();
	//	return(err);
	//}
	
	if ( !DataFile.is_open() )
	{
		Amb("Error opening file; ");
		return(0);
	}

	DataSourceNames[NumFileDataBucketSources] = Name;
	
	DataSources[NumFileDataBucketSources] = TimeBuf::FromFile(DataFile, Name);
	if (NULL == DataSources[NumFileDataBucketSources]) {
//		Amb("Unable to locate Neuralynx data in file.  Are you sure this is a neuralynx file?");
		return(-601);
	}

	if (0 == GenerateTSHashTable()) {
		NumFileDataBucketSources++;
	} else {
		DataSourceNames[NumFileDataBucketSources] = string("");
		delete DataSources[NumFileDataBucketSources];
		DataSources[NumFileDataBucketSources] = NULL;
	}
/*
	for( uintd i = 0; i < NumHandlers; i++ ) {
		if( NULL != HandlerList[i] ) {
			HandlerList[i]->DataChanged();
		}
	}
*/	return(0);
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr FileDataBucket::Close(const uintd SourceIndex)
{
	if (SourceIndex >= NumFileDataBucketSources) { return(NLX_RANGE); }

	//now dealloc requested datasource
	DataSourceNames[SourceIndex] = string("");
	delete DataSources[SourceIndex];
	DataSources[SourceIndex] = NULL;
	delete [] TSIdxHash[SourceIndex].TS;
	delete [] TSIdxHash[SourceIndex].Index;
	TSIdxHash[SourceIndex].TS = NULL;
	TSIdxHash[SourceIndex].Index = NULL;
	NumHashes[SourceIndex] = 0;
	
	//now compact list
	if (SourceIndex < (NumFileDataBucketSources - 1) ) {
		DataSourceNames[SourceIndex] = DataSourceNames[NumFileDataBucketSources-1];
		DataSources[SourceIndex] = DataSources[NumFileDataBucketSources-1];
		NumHashes[SourceIndex] = NumHashes[NumFileDataBucketSources-1];
		TSIdxHash[SourceIndex].TS = TSIdxHash[NumFileDataBucketSources-1].TS;
		TSIdxHash[SourceIndex].Index = TSIdxHash[NumFileDataBucketSources-1].Index;	
	}

	//now we officially have one less
	NumFileDataBucketSources--;

/*	//tell everyone about it.
	for( uintd i = 0; i < NumHandlers; i++ ) {
		if( NULL != HandlerList[i] ) {
			HandlerList[i]->DataChanged();
		}
	}
*/	return(0);
}

//********************************************************************************************************************
//********************************************************************************************************************
uintd FileDataBucket::GetNumOpenDataSources() 
{ 
	return(NumFileDataBucketSources);
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr FileDataBucket::GetDataSourceType(const uintd SourceIndex, uintd& Type)
{
	if (SourceIndex >= NumFileDataBucketSources) {	return(-2); }
	if (NULL == DataSources[SourceIndex]) { return(-1); }
	Type = DataSources[SourceIndex]->GetFileType();	
	return(0);
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr FileDataBucket::GetDataSourceIndex(const string& SourceName, uintd& SourceIndex)
{
	for(uintd i = 0; i < NumFileDataBucketSources; i++) {
		if (SourceName == DataSourceNames[i]) {
			SourceIndex = i;
			return(0);
		}
	}
	SourceIndex = (uintd)(-1);
	return(-1);
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr FileDataBucket::GetDataSourceName(const uintd SourceIndex, string& SourceName)
{
	if (SourceIndex >= NumFileDataBucketSources) { return(-2); }
	SourceName = DataSourceNames[SourceIndex];
	return(0);
}

//********************************************************************************************************************
//********************************************************************************************************************
// Get the next record either equal to or before the requested timestamp
ierr FileDataBucket::GetData(const unsigned __int64 TimeStamp, const uintd DataSourceIndex, void** Data)
{
	ierr err;
	uintd i, j;
	int64 DataTS;

	if (DataSourceIndex >= NumFileDataBucketSources) {
		Amb("Attempting to display invalid data source; Data source index = ", DataSourceIndex);
		return(NLX_RANGE);
	}

	//are we before the start? Just return the first one.
	if ((int64)TimeStamp <= TSIdxHash[DataSourceIndex].TS[0]) {
//		err = DataSources[DataSourceIndex]->GetRec(Data, 0);
		err = 0;
		return(err);
	}

	//after the end? return the last.
	if ((int64)TimeStamp >= TSIdxHash[DataSourceIndex].TS[NumHashes[DataSourceIndex]-1]) {
		err = DataSources[DataSourceIndex]->GetRec(Data, (DataSources[DataSourceIndex]->GetNumRecs())-1);
		return(err);
	} 

	//now let's attempt to find what portion of the file that timestamp happens to be located in...
	for (i = 1; i < (NumHashes[DataSourceIndex]-1); i++) {
		//when if statement clears we know timestamp is before the given record number, i
		if ((int64)TimeStamp < TSIdxHash[DataSourceIndex].TS[i]) { break; }
	}

	//now we know we are between i and i-1
	for (j = TSIdxHash[DataSourceIndex].Index[i-1]; j <= TSIdxHash[DataSourceIndex].Index[i]; j++) {
		err = DataSources[DataSourceIndex]->GetRec(Data, j);
		if (0 != err) { return(err); }
		DataTS = DataSources[DataSourceIndex]->TimeStampFromRec(*Data);
		if (DataTS > (int64)TimeStamp) { break; }
	}

	//now the correct record should be the last one...
	err = DataSources[DataSourceIndex]->GetRec(Data, j-1);
	return(err);
}

ierr FileDataBucket::GetData(const int DataIndex, const uintd DataSourceIndex, void** Data)
{
	if (DataSourceIndex >= NumFileDataBucketSources) {
		Amb("Attempting to display invalid data source; Data source index = ", DataSourceIndex);
		return(NLX_RANGE);
	}

	uintd NumRecs = DataSources[DataSourceIndex]->GetNumRecs();
	if (DataIndex >= (int)NumRecs) { 
		Amb("Attempting to request record past end of file; record index = ", DataIndex);
		return(NLX_RANGE); 
	}

	ierr err = DataSources[DataSourceIndex]->GetRec(Data, DataIndex);
	return(err);

	return(0);
}

//********************************************************************************************************************
//********************************************************************************************************************
void FileDataBucket::ShowProperties() 
{
//	DataPropertiesDlg PropertiesSheet;
//	PropertiesSheet.SetFileDataBucketPtr(this);
//	PropertiesSheet.DoModal();
}
/*
//********************************************************************************************************************
//for X2 only - fill in later
//********************************************************************************************************************
void FileDataBucket::AddEventHandler(const DataBucketEventHandlerInterface& Handler)
{
	HandlerList[NumHandlers] = const_cast<DataBucketEventHandlerInterface*>(&Handler);
	NumHandlers++;
}

//********************************************************************************************************************
//for X2 only - fill in later
//********************************************************************************************************************
void FileDataBucket::RemoveEventHandler(const DataBucketEventHandlerInterface& Handler) 
{
}
*/
//********************************************************************************************************************
//only for private use by onopen function - operates on the newly created, but not validated data source - DataSource[NumFileDataBucketSources].
//makes approximate lookup between timestamp & record #'s, so seeking is faster...
//********************************************************************************************************************
ierr FileDataBucket::GenerateTSHashTable()
{
	void* Rec = 0;
	int64 Time;
	ierr err;

	//pick a reasonable number of hashes to do
	NumHashes[NumFileDataBucketSources] = ( std::min((unsigned int)10000, ( DataSources[NumFileDataBucketSources]->GetNumRecs() ) / 100 )) + 1;
	//bounds check; need at least 2
	if (NumHashes[NumFileDataBucketSources] < 2) { NumHashes[NumFileDataBucketSources] = 2; }

	//now alloc our actual table
	TSIdxHash[NumFileDataBucketSources].TS = new int64[NumHashes[NumFileDataBucketSources]];
	TSIdxHash[NumFileDataBucketSources].Index = new uintd[NumHashes[NumFileDataBucketSources]];
	
	if ( (NULL == TSIdxHash[NumFileDataBucketSources].TS) || (NULL == TSIdxHash[NumFileDataBucketSources].Index) ) {
		return(NLX_NULL);
	}

	for (uintd i = 0; i < (NumHashes[NumFileDataBucketSources]-1); i++) {
		TSIdxHash[NumFileDataBucketSources].Index[i] = ( (DataSources[NumFileDataBucketSources]->GetNumRecs()) / (NumHashes[NumFileDataBucketSources]-1) ) * i;

		err = DataSources[NumFileDataBucketSources]->GetRec(&Rec, TSIdxHash[NumFileDataBucketSources].Index[i]);
		Time = DataSources[NumFileDataBucketSources]->TimeStampFromRec(Rec);
		if (0 != err) { return(err); }
		
		TSIdxHash[NumFileDataBucketSources].TS[i] = Time;
	}

	//do final hash
	TSIdxHash[NumFileDataBucketSources].Index[(NumHashes[NumFileDataBucketSources]-1)] = ( DataSources[NumFileDataBucketSources]->GetNumRecs() ) -1;
	err = DataSources[NumFileDataBucketSources]->GetRec(&Rec, TSIdxHash[NumFileDataBucketSources].Index[(NumHashes[NumFileDataBucketSources]-1)]);
	if (0 != err) { return(err); }
	Time = DataSources[NumFileDataBucketSources]->TimeStampFromRec(Rec);
	TSIdxHash[NumFileDataBucketSources].TS[(NumHashes[NumFileDataBucketSources]-1)] = Time;

	return(0);
}

//********************************************************************************************************************
//********************************************************************************************************************
void FileDataBucket::GetGlobalTimeRange(int64& TimeStartAll, int64& TimeEndAll)
{
	uintd i;
	TimeStartAll = 0x7FFFFFFF;
	TimeEndAll = 0;
	
	if (NumFileDataBucketSources < 1) { 
		TimeStartAll = 0; 
		TimeEndAll = 1; 
		return; 
	}

	for(i = 0; i < NumFileDataBucketSources; i++) {
		TimeStartAll = std::min(TimeStartAll, TSIdxHash[i].TS[0]);
		TimeEndAll = std::max(TimeEndAll, TSIdxHash[i].TS[NumHashes[i]-1]);
	}

	TimeStartAll -= 1000000;
	if( TimeStartAll < 0 ) { TimeStartAll = 0; }
	TimeEndAll += 1000000;
}

//********************************************************************************************************************
//********************************************************************************************************************
/*
ierr FileDataBucket::ReadConfigFile(CFile& fileHandle)
{
	char temp[MAX_PATH];
	ierr Err;
			CFile DataFile;
		BOOL Open;
		CFileException eerr;
		uintd TempNumFileDataBucketSources;
	
	try {
	
		fileHandle.Read(&TempNumFileDataBucketSources, sizeof(uintd));
	
	} catch(CFileException* e) {
	
		Err = e->m_lOsError;
		Amb("Unable to read data source information from configuration file", Err);
		e->Delete();
		return(Err);
	}
	
	if (TempNumFileDataBucketSources > MaxDataSources) {
		Amb("Invalid Number of data sources listed in configuration file, number was:", NumFileDataBucketSources);
		TempNumFileDataBucketSources = MaxDataSources;
	}
	
	for(uintd i = 0; i < TempNumFileDataBucketSources; i++) {

		try {

			fileHandle.Read(temp, MAX_PATH*sizeof(char));

		} catch(CFileException* e) {

			Err = e->m_lOsError;
			Amb("Unable to read data source information from configuration file", Err);
			e->Delete();
			return(Err);
		}	

		temp[MAX_PATH-1] = '\0';
		DataSourceNames[i] =  CString(temp);

		//now we've got the relevant info back from the file, try to actually open the files...
		

		try {
			//Open = DataFile.Open(FileDlg.m_ofn.lpstrFile, CFile::modeRead | CFile::shareDenyNone | CFile::osSequentialScan, &eerr);
			Open = DataFile.Open(DataSourceNames[i], CFile::modeRead | CFile::shareDenyNone | CFile::osSequentialScan, &eerr);
		} catch (CFileException* e) {
			Err = e->m_lOsError;
			Amb("Exception opening file; microsoft error code:", e->m_lOsError);
			e->Delete();
			return(Err);
		}
		if (!Open) {
			Err = eerr.m_lOsError;
			Amb("Error opening file; microsoft error code:", eerr.m_lOsError);
			return(Err);
		}

		DataSources[i] = TimeBuf::FromFile(DataFile, DataSourceNames[i]);

		if (NULL == DataSources[i]) {
			Amb("Unable to locate Neuralynx data in file.  Are you sure this is a neuralynx file?");
		}

		//this need set bcuz getneratetshash always indexes current file as numFileDataBucketsources.
		NumFileDataBucketSources = i;
		if (0 == GenerateTSHashTable()) {
		} else {
			DataSourceNames[i] = string("");
			delete DataSources[i];
			DataSources[i] = NULL;
		}

		NumFileDataBucketSources++;
	}
	return(0);
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr FileDataBucket::WriteConfigFile(CFile& fileHandle)
{
	char temp[MAX_PATH];
	ierr Err;
	
	try {
	
		fileHandle.Write(&NumFileDataBucketSources, sizeof(uintd));
	
	} catch(CFileException* e) {
	
		Err = e->m_lOsError;
		Amb("Unable to write data source information to configuration file", Err);
		e->Delete();
		return(Err);
	}
	
	for(uintd i = 0; i < NumFileDataBucketSources; i++) {
		
		strncpy(temp, DataSourceNames[i].GetBuffer(), MAX_PATH-1);
		temp[MAX_PATH-1] = '\0';
		try {
	
			fileHandle.Write(temp, MAX_PATH*sizeof(char));
	
		} catch(CFileException* e) {
	
			Err = e->m_lOsError;
			Amb("Unable to write data source information to configuration file", Err);
			e->Delete();
			return(Err);
		}	
	}
	
	return(0);
}
*/

//********************************************************************************************************************
//********************************************************************************************************************
//get the value for a particualar string in the header - searches for "MetaString", then returns reast of line.
ierr FileDataBucket::GetHeaderMetaData(const uintd SourceIndex, const string MetaString, string& MetaValue)
{
	ierr Err;
	
	if (SourceIndex >= NumFileDataBucketSources) { return(NLX_RANGE); }
	
	Err = DataSources[SourceIndex]->GetHeaderMetaData(MetaString, MetaValue);
	
	return(Err);
}


//********************************************************************************************************************
//********************************************************************************************************************
int FileDataBucket::GetDataSourceNumRecs(const int sourceIndex)
{
	if(sourceIndex >= (int)NumFileDataBucketSources) { return(NLX_RANGE); }
	return(DataSources[sourceIndex]->GetNumRecs());
}

//********************************************************************************************************************
//********************************************************************************************************************
ierr FileDataBucket::GetDataSourceHeader(const int sourceIndex, char* &header )
{
	if(sourceIndex >= (int)NumFileDataBucketSources) { return(NLX_RANGE); }
	DataSources[sourceIndex]->GetHeader(header);
	return(0);
}
