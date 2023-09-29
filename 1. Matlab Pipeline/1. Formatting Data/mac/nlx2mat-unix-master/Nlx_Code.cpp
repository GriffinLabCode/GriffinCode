//#include <afxwin.h>         // MFC core and standard components
//#include <afxdisp.h>        // MFC Automation classes
#include "Nlx_Error.h"
#include "Nlx_DataTypes.h"
#include "Nlx_Code.h"
#include <fstream>
#include <mex.h>

// Checks for NT Header -- Note: does NOT check for Sun header
BOOL HasHeader(std::fstream& File_In)
{
	//int BytesRead;
	char MajicCookie[19];
	//BytesRead = 
	
	File_In.read((char*) &MajicCookie, 18);
	File_In.seekg(0, std::ios_base::beg);
	MajicCookie[18] = '\0';
	if (CString(MajicCookie) == CString("######## Neuralynx")) {
		return(TRUE);
	}
	return(FALSE);		
}

//same function but with low-level file access (for mmap)
BOOL HasHeader(int fd)
{
	char MajicCookie[19];
	
	read(fd,MajicCookie,18);
	lseek(fd,0,SEEK_SET);

	MajicCookie[18] = '\0';
	if (CString(MajicCookie) == CString("######## Neuralynx")) {
		return(TRUE);
	}
	return(FALSE);		
}

int Amb(const char* ErrMsg, __int64 ErrCode, bool BreakPoint)
{
	char temp[20];
	char buf[500];
	//_i64toa(ErrCode, temp, 10);
	//strncpy(buf, ErrMsg, 479);
	//buf[479] = '\0';
	//if (ErrCode != 0) {
	//	strcat(buf, temp);
	//}

	mexPrintf("%s %d\n", ErrMsg, ErrCode);
	
	//#ifdef _DEBUG
	//	if (BreakPoint) { __asm { int 3 }; }
	//#endif

	return 0;
}

/*
long memtovarcpy(VARIANT* Dest, void* Src, UINT DataSizeBytes)
{
	SAFEARRAY* NewVariant; 
	SAFEARRAYBOUND VariantBounds[1]; //1 for 1-D

	//Now Alloc Space for data
	VariantBounds[0].lLbound = 0; //zero-based arrays.
	VariantBounds[0].cElements = DataSizeBytes;
	NewVariant = SafeArrayCreate(VT_I1, 1, VariantBounds);  //this is where memory is actually alloc'd
	if (NewVariant == NULL) {
		return(-1);
	}

	//put waveform into variant
	memcpy(NewVariant->pvData, Src, DataSizeBytes);

	//Now set our Variant variable to reference location of our data
	Dest->vt = VT_ARRAY | VT_I1;
	Dest->parray = NewVariant;

	return(0);
}

long vartomemcpy(void* Dest, VARIANT* Src, UINT& DataSizeBytes)
{
	UINT DataSizeIn;

	if (Src == NULL) { return(-1); }
	if ( (Src->parray) == NULL) { return(-2); }
	if ( (Src->vt) != (VT_ARRAY | VT_I1) ) { return(-3); }
	if ( (Src->parray->rgsabound) == NULL) { return(-4); }
	if ( (Src->parray->pvData) == NULL) { return(-5); }
		
	//How much data to cpy?
	DataSizeIn = DataSizeBytes;
	DataSizeBytes = min(Src->parray->rgsabound[0].cElements, DataSizeIn);

	//do the copy
	memcpy(Dest, Src->parray->pvData, DataSizeBytes);

	//was there a full copy?
	if (DataSizeBytes != DataSizeIn) { return(-6); }

	return(0);
}

void* GetArrayFromVariantSafe(VARIANT* Data, int& DataSizeBytes)
{
	DataSizeBytes = 0;

	if (Data == NULL) { return(NULL); }
	if (Data->vt != (VT_ARRAY | VT_I1)) { return(NULL); }
	if (Data->parray == NULL) { return(NULL); }
	if (Data->parray->rgsabound == NULL) { return(NULL); }
	if (Data->parray->pvData == NULL) { return(NULL); }

	DataSizeBytes = Data->parray->rgsabound[0].cElements;
	return(Data->parray->pvData);
}

*/


// FileTypes: 1=single electrode, 2=stereotrode, 3=timestamp, 4=tetrode,
//				5 = CSC, 6 = Events, 7 = Video
// returns NlxError code from NlxErrors.h - 0 is a-ok
// assumes valid file handle
// returns -1 for unknown file type (otherwise returns number of electrodes (1,2,4)
// algorithm is now pretty bulletproof with addition of Thane's code for checking ts's
int NlxFileType(int& FileType, std::string filename)
{
	enum {Err, SE, ST, TS, TT, CSC, Event, Video, Dat};
	long HeaderSize = 0;
	int ExtensionType;
	ULONGLONG FileSizeBytes;
	CString Extension;
	int IsTT, IsST, IsSE, IsTS, IsCS, IsEV, IsVT;
	IsTT = 0;
	IsST = 0;
	IsSE = 0;
	IsTS = 0;
	IsCS = 0;
	IsEV = 0;
	IsVT = 0;


	// (1) attempt to use the extension since this is the surest way... (unless the user has changed it)

	// get the file extension and make lower case
	
	//FileInAlreadyOpen.rdbuf().
	//Extension = FileInAlreadyOpen.GetFileName();
	
	Extension = filename.c_str();
	Extension.MakeLower();

	// initialize ExtensionType and look for a match
	ExtensionType = Err;
	
	if ( Extension.Right(3) == CString("ntt") ) 		{ ExtensionType = TT; }
	if ( Extension.Right(3) == CString("nst") ) 		{ ExtensionType = ST; }
	if ( Extension.Right(3) == CString("nse") ) 		{ ExtensionType = SE; }
	if ( Extension.Right(3) == CString("nts") ) 		{ ExtensionType = TS; }
	if ( Extension.Right(3) == CString("ncs") ) 		{ ExtensionType = CSC; }
	if ( Extension.Right(3) == CString("nev") ) 		{ ExtensionType = Event; }
	if ( Extension.Right(3) == CString("nvt") ) 		{ ExtensionType = Video; }

	//did we find one? just return..
	if (ExtensionType != Err) {
		FileType = ExtensionType;
		return 0;
	}

	/*
	if ( Extension.Right(3) == CString("dat") ) 		{ ExtensionType = Dat; }


	// (2) do modulo on the file size: if only one fits and it matches ExtensionType then return
		
	//get file length and adjust for header
	FileSizeBytes = FileInAlreadyOpen.GetLength();
	if(HasHeader(FileInAlreadyOpen)) {
		HeaderSize = 16384;
		FileSizeBytes -= 16384;
	}

	//see if some of this record type fit in file exactly, if so, must be the filetype.
	if (   (FileSizeBytes % sizeof(TTRec))   == 0  ) 		{ IsTT = 1; }
	if (   (FileSizeBytes % sizeof(STRec))   == 0  ) 		{ IsST = 1; }
	if (   (FileSizeBytes % sizeof(SERec))   == 0  ) 		{ IsSE = 1; }
	if (   (FileSizeBytes % sizeof(VideoRec))== 0  ) 		{ IsVT = 1; }
	if (   (FileSizeBytes % sizeof(EventRec))== 0  ) 		{ IsEV = 1; }
	if (   (FileSizeBytes % sizeof(CRRec))   == 0  ) 		{ IsCS = 1; }
	if (   (FileSizeBytes % sizeof(__int64)) == 0  ) 		{ IsTS = 1; }

	//now look for a match between extension and filetype
	//did we find just one? just return..
	if ( (IsTT + IsST + IsSE + IsTS + IsVT + IsEV + IsCS) == 1 ) {
		if (IsTT) { FileType = TT; }
		if (IsST) { FileType = ST; }
		if (IsSE) { FileType = SE; }
		if (IsTS) { FileType = TS; }
		if (IsCS) { FileType = CSC; }
		if (IsEV) { FileType = Event; }
		if (IsVT) { FileType = Video; }		
		return 0;
	}

	// (3) last ditch is to look for 100 consecutive timestamps

  	FileInAlreadyOpen.Seek( HeaderSize, CFile::begin );     // seek to past header
	FileType = NlxFileTypeTS(FileInAlreadyOpen);            //  and call routine
	if (FileType != 0) {
		return 0;
	}
	*/
	//file type is zero, i.e. not recognized...
	return(-1);
}



//___________________________________________________________________________
/*int NlxFileTypeTS(std::fstream& cfo)
{
  // Returns the Cheetah data type from open CFile& cfo
  // Return values: 0=Err, 1=SE, 2=ST, 3=TS, 4=TT, 5=CSC, 6=Event, 7=VT
  // Calling routine MUST skip header if it exists

  long fpos;

  // assume caller has skipped past header if it exists
  fpos = (long)(cfo.GetPosition());
  if(TimeStampsInSequence_NT(cfo, ERecSizes::kTTRecSize_NT, 0, fpos )) return EDataType::kTT;
  if(TimeStampsInSequence_NT(cfo, ERecSizes::kSTRecSize_NT, 0, fpos )) return EDataType::kST;
  if(TimeStampsInSequence_NT(cfo, ERecSizes::kSERecSize_NT, 0, fpos )) return EDataType::kSE;
  if(TimeStampsInSequence_NT(cfo, ERecSizes::kCSCRecSize_NT, 0, fpos )) return EDataType::kCSC;
  if(TimeStampsInSequence_NT(cfo, ERecSizes::kEventRecSize_NT, 6, fpos )) return EDataType::kEvent;
  if(TimeStampsInSequence_NT(cfo, ERecSizes::kVideoRecSize_NT, 6, fpos )) return EDataType::kVideo;
  if(TimeStampsInSequence_NT(cfo, ERecSizes::kTSRecSize, 0, fpos )) return EDataType::kTS;

  // reset file ptr
  cfo.SeekToBegin();
  return 0;
}
*/

//___________________________________________________________________________
/*bool TimeStampsInSequence_NT(std::fstream& cfo, int recsize, int offset, int startpos )
{
// Used by GetDataType() to check for 100 sequential NT timestamps
// Returns true if 100 timestamps are found of increasing value

  int i;
  UINT nBytesRead;
  __int64 t0,t1;

  // get 1st timestamp
  cfo.seekg(startpos+offset, std::ios::beg);
  nBytesRead = cfo.read(&t0, sizeof(__int64));
  
  if(nBytesRead != sizeof(__int64)) { 
    // file is empty 
    return false;
  }

  // compare the next 99 timestamps
  for (i=0; i<99; i++) {
    cfo.Seek(recsize-sizeof(__int64), CFile::current);  // set the file ptr
    nBytesRead = cfo.Read(&t1, sizeof(__int64));        // try to read a TS
    if(nBytesRead == sizeof(__int64)) {                 // got a TS
      if((t1-t0) <= 0)                                  // compare timestamps
        return false;
      t0 = t1;                                          // set next TS for compare
    } else {
      if (i <= 4){
        return false;                                   // Cannot tell with fewer than 5 timestamps
      }
      // Warning: file has more than 4 and less than 100 consecutive timestamps! 
      // Autodetect may not be reliable 
      break;
    }
  }
  
  cfo.SeekToBegin();   // rewind
  return true;
}
*/


//used to take any arbitrary string and remove anything that would prevent it from being a valid
//will automatically shorten your string, so save it if you want to keep the origonal...
//removes "\"
int RemoveFileWildCards(char* FileName)
{
	const int NUM_WILD = 9;
	const char WildCards[NUM_WILD+1] = "/\\:*?\"<>|";
	int wildpos;
	int pos;
	int copypos;
	int filelen;

	filelen = strlen(FileName);

	for (pos = 0; pos < filelen; pos++) {

		for(wildpos = 0; wildpos < NUM_WILD; wildpos++) {

			if(FileName[pos] == WildCards[wildpos]) {

				//reset to first wildcard
				wildpos = -1;

				//copy filename down over, using pos+1 will copy trailing zero also
				for(copypos = pos; copypos < filelen; copypos++) {
					FileName[copypos] = FileName[copypos+1];
				}

				//shrink string
				filelen--;

				//move back in case we copied another wilcard down
				pos--;
			}
		}
	}

	return(0);
}





//used to take any arbitrary string and remove anything that would prevent it from being a valid
//will automatically shorten your string, so save it if you want to keep the origonal...
//leaves "\"
int RemoveDirWildCards(char* DirName)
{
	const int NUM_WILD = 8;
	const char WildCards[NUM_WILD+1] = "/:*?\"<>|";
	int wildpos;
	int pos;
	int copypos;
	int dirlen;

	dirlen = strlen(DirName);

	for (pos = 0; pos < dirlen; pos++) {

		for(wildpos = 0; wildpos < NUM_WILD; wildpos++) {

			if(DirName[pos] == WildCards[wildpos]) {

				//reset to first wildcard
				wildpos = -1;

				//copy filename down over, using pos+1 will copy trailing zero also
				for(copypos = pos; copypos < dirlen; copypos++) {
					DirName[copypos] = DirName[copypos+1];
				}

				//shrink string
				dirlen--;

				//move back in case we copied another wilcard down
				pos--;
			}
		}
	}

	return(0);
}

// This is a general purpose function to create a new directory.  It will also create a 
// series of subdirectories if neccessary.  (i.e. if you attemp to create C:\dir1\dir2 and
// there is no C:\dir1, this function will create C:\dir1 first and then create C:\dir2)
// Returns: TRUE if directory was created, FALSE if not.
/*int CreateMultiSubDirs(char* DirName)
{
	int nRet;
	int nPos;
	CString csDirName;

	nRet = SetCurrentDirectory(DirName);	// a quick check to see if the dir exists
	if(nRet) {
		return(TRUE);						// directory exists, not created
	}

	nRet = CreateDirectory(DirName, NULL);	// attempt to create dir

	if(!nRet) {								// unable to create, we'll try a truncated version
		csDirName = DirName;

		nPos = csDirName.ReverseFind('\\');		// find the last '\' in the dir name 
		if(nPos == -1) {					
			return(FALSE);					// didn't find another '\', invalid name/unable to create
		}
		while(nPos == csDirName.GetLength() - 1) {	// if it's at the end, delete it
			csDirName.Delete(nPos, 1);
			nPos = csDirName.ReverseFind('\\');
		}
		csDirName = csDirName.Mid(0, nPos);		// truncate up to the last '\'

		nRet = CreateMultiSubDirs(csDirName.GetBuffer(csDirName.GetLength()));	// recursive call to function with shorter, parent dir name
		if(!nRet) {
			return(FALSE);					// if the recursive call returns FALSE, we won't be able to create
		}

		nRet = CreateDirectory(DirName, NULL);	// parent dir has been created, so try this one again
		if(!nRet) {
			return(FALSE);					// no reason this should happen, we should have no problem creating the dir now.
		}
	}
	return(TRUE);							// if we've missed the other returns, the dir was created properly.  return TRUE
}

*/



//Used to remove quotes from around a string.  if no quotes, does nothing.  only looks for leading quote, assumes trailing.
CString RemoveSurroundingQuotes(const CString StringIn)
{
	CString temp;
	int len;

	if ( (StringIn.Left(1)) == (CString("\"")) ) {
		len = StringIn.GetLength();
		len -=2;
		temp = StringIn.Mid(1, len);
		return(temp);	
	}

	return(StringIn);
}


int GetTrackerPosAndColorFromPoint(const unsigned __int32 Point, unsigned int& x, unsigned int& y, BOOL& pr, BOOL& rr, BOOL& pg, BOOL& rg, BOOL& pb, BOOL& rb, BOOL& lu)
{
	x = Point & VREC_X_MASK;
	y = (Point & VREC_Y_MASK) >> 16;

	lu = FALSE;
	rr = FALSE;
	pr = FALSE;
	rg = FALSE;
	pg = FALSE;
	rb = FALSE;
	pb = FALSE;

	//put in the color for the luminance
	if ( (Point & VREC_LU_MASK) != 0)	{ lu = TRUE; }	
	//put in the color for the raw red
	if ( (Point & VREC_RR_MASK) != 0)	{ rr = TRUE; }	
	//put in the color for the raw green
	if ( (Point & VREC_RG_MASK) != 0)	{ rg = TRUE; }	
	//put in the color for the raw blue
	if ( (Point & VREC_RB_MASK) != 0)	{ rb = TRUE; }	
	//put in the color for the pure red
	if ( (Point & VREC_PR_MASK) != 0)	{ pr = TRUE; }	
	//put in the color for the pure green
	if ( (Point & VREC_PG_MASK) != 0)	{ pg = TRUE; }	
	//put in the color for the pure blue
	if ( (Point & VREC_PB_MASK) != 0)	{ pb = TRUE; }	
	
	return(0);
}




/*
//used for saving a window to a bitmap...
PBITMAPINFO CreateBitmapInfoStruct(HBITMAP hBmp)
{ 
    BITMAP bmp; 
    PBITMAPINFO pbmi; 
    WORD    cClrBits; 

    // Retrieve the bitmap's color format, width, and height. 
    if (!GetObject(hBmp, sizeof(BITMAP), (LPSTR)&bmp)) {
        AfxMessageBox("Unable to get object from bitmap");
		return(NULL);
	}

    // Convert the color format to a count of bits. 
    cClrBits = (WORD)(bmp.bmPlanes * bmp.bmBitsPixel); 
    if (cClrBits == 1) 
        cClrBits = 1; 
    else if (cClrBits <= 4) 
        cClrBits = 4; 
    else if (cClrBits <= 8) 
        cClrBits = 8; 
    else if (cClrBits <= 16) 
        cClrBits = 16; 
    else if (cClrBits <= 24) 
        cClrBits = 24; 
    else cClrBits = 32; 

    // Allocate memory for the BITMAPINFO structure. (This structure 
    // contains a BITMAPINFOHEADER structure and an array of RGBQUAD 
    // data structures.) 

     if (cClrBits != 24) 
         pbmi = (PBITMAPINFO) LocalAlloc(LPTR, 
                    sizeof(BITMAPINFOHEADER) + 
                    sizeof(RGBQUAD) * (1<< cClrBits)); 

     // There is no RGBQUAD array for the 24-bit-per-pixel format. 

     else 
         pbmi = (PBITMAPINFO) LocalAlloc(LPTR, 
                    sizeof(BITMAPINFOHEADER)); 

    // Initialize the fields in the BITMAPINFO structure. 

    pbmi->bmiHeader.biSize = sizeof(BITMAPINFOHEADER); 
    pbmi->bmiHeader.biWidth = bmp.bmWidth; 
    pbmi->bmiHeader.biHeight = bmp.bmHeight; 
    pbmi->bmiHeader.biPlanes = bmp.bmPlanes; 
    pbmi->bmiHeader.biBitCount = bmp.bmBitsPixel; 
    if (cClrBits < 24) 
        pbmi->bmiHeader.biClrUsed = (1<<cClrBits); 

    // If the bitmap is not compressed, set the BI_RGB flag. 
    pbmi->bmiHeader.biCompression = BI_RGB; 

    // Compute the number of bytes in the array of color 
    // indices and store the result in biSizeImage. 
    // For Windows NT/2000, the width must be DWORD aligned unless 
    // the bitmap is RLE compressed. This example shows this. 
    // For Windows 95/98, the width must be WORD aligned unless the 
    // bitmap is RLE compressed.
    pbmi->bmiHeader.biSizeImage = ((pbmi->bmiHeader.biWidth * cClrBits +31) & ~31) /8
                                  * pbmi->bmiHeader.biHeight; 
    // Set biClrImportant to 0, indicating that all of the 
    // device colors are important. 
     pbmi->bmiHeader.biClrImportant = 0; 
     return pbmi; 
} 




//used for saving a window to a bitmap...
void CreateBMPFile(LPTSTR pszFile, PBITMAPINFO pbi, HBITMAP hBMP, HDC hDC) 
 { 
     HANDLE hf;                 // file handle 
    BITMAPFILEHEADER hdr;       // bitmap file-header 
    PBITMAPINFOHEADER pbih;     // bitmap info-header 
    LPBYTE lpBits;              // memory pointer 
    DWORD dwTotal;              // total count of bytes 
    DWORD cb;                   // incremental count of bytes 
    BYTE *hp;                   // byte pointer 
    DWORD dwTmp; 

    pbih = (PBITMAPINFOHEADER) pbi; 
    lpBits = (LPBYTE) GlobalAlloc(GMEM_FIXED, pbih->biSizeImage);

    if (!lpBits) {
         AfxMessageBox("No memory availible on globalalloc for bitmap file.");
		 return;
	}

    // Retrieve the color table (RGBQUAD array) and the bits 
    // (array of palette indices) from the DIB. 
    if (!GetDIBits(hDC, hBMP, 0, (WORD) pbih->biHeight, lpBits, pbi, 
        DIB_RGB_COLORS)) 
    {
        AfxMessageBox("Error on GetDIBits(), cannot save bitmap.");
		return;
    }

    // Create the .BMP file. 
    hf = CreateFile(pszFile, 
                   GENERIC_READ | GENERIC_WRITE, 
                   (DWORD) 0, 
                    NULL, 
                   CREATE_ALWAYS, 
                   FILE_ATTRIBUTE_NORMAL, 
                   (HANDLE) NULL); 
    if (hf == INVALID_HANDLE_VALUE) { 
        AfxMessageBox("Unable to create() file to save .bmp...");
		return;
	}
    hdr.bfType = 0x4d42;        // 0x42 = "B" 0x4d = "M" 
    // Compute the size of the entire file. 
    hdr.bfSize = (DWORD) (sizeof(BITMAPFILEHEADER) + 
                 pbih->biSize + pbih->biClrUsed 
                 * sizeof(RGBQUAD) + pbih->biSizeImage); 
    hdr.bfReserved1 = 0; 
    hdr.bfReserved2 = 0; 

    // Compute the offset to the array of color indices. 
    hdr.bfOffBits = (DWORD) sizeof(BITMAPFILEHEADER) + 
                    pbih->biSize + pbih->biClrUsed 
                    * sizeof (RGBQUAD); 

    // Copy the BITMAPFILEHEADER into the .BMP file. 
    if (!WriteFile(hf, (LPVOID) &hdr, sizeof(BITMAPFILEHEADER), 
        (LPDWORD) &dwTmp,  NULL)) 
    {
       AfxMessageBox("Unable to write .bmp file.");
	   return;
    }

    // Copy the BITMAPINFOHEADER and RGBQUAD array into the file. 
    if (!WriteFile(hf, (LPVOID) pbih, sizeof(BITMAPINFOHEADER) 
                  + pbih->biClrUsed * sizeof (RGBQUAD), 
                  (LPDWORD) &dwTmp, (NULL)) ) 
	{
		AfxMessageBox("Unable to write .bmp file.");
		return;    
	}

    // Copy the array of color indices into the .BMP file. 
    dwTotal = cb = pbih->biSizeImage; 
    hp = lpBits; 
    if (!WriteFile(hf, (LPSTR) hp, (int) cb, (LPDWORD) &dwTmp,NULL)) {
		AfxMessageBox("Unable to write .bmp file.");
		return;
	}

    // Close the .BMP file. 
    if (!CloseHandle(hf)) {
		AfxMessageBox("Unable to write .bmp file.");
	    return;
	}

    // Free memory. 
    GlobalFree((HGLOBAL)lpBits);
}
*/


