/////////////////////////////////////////////////
//
//  Name:  Neuralynx Error Constants 
//      
//
//  File Name:  NLX_Error.h
//      
//  
//  Description:
//      This is the file which holds all the error codes from
//      all NLX Classes
//
//  Copyright 1999 @ Neuralynx, Inc.
//
//  Author:     Casey Stengel 
//
//  History:      Creation    1/21/1999
//
//
///////////////////////////////////////////////////
//  cstdiofile
//
//  Pragmas
//
// 
//////////////////////////////////

//  Include Files
//
//
//  Local Defines
//
//  local forward references
//
//////////  Start of Code  ////////////////////////////
#ifndef NLX_ERROR_INCLUDE
#define NLX_ERROR_INCLUDE


#define Nlx_Error			int
const int NLX_OK = 0;	// a-ok
const int NLX_OperationUnimplemented = -999;	//A function has no implementation

// Object Catalog Class Errors
const int NLX_ERR_OC_FULL = -100;
const int NLX_ERR_OC_ENTRY_NOT_FOUND = -101;
const int NLX_ERR_OC_NAME_ALREADY_IN_USE = -102;
const int NLX_ERR_OC_BAD_ADDR_FOR_DELETE = -103;

// Cmd_Table_Prc Errors
const int NLX_ERR_CMD_TABLE_NULL = -200;
const int NLX_ERR_CMD_TABLE_INVALID_SIZE = -201;
const int NLX_ERR_CMD_TABLE_CMD_NOT_FOUND = -202;


// Creator Class Errors
const int NLX_ERR_CANT_OPEN_SETUP_FILE = -301;
const int NLX_ERR_SETUP_FILE_ERROR = -302;
const int NLX_ERR_CANT_CREATE_CLASS = -303;
const int NLX_ERR_BAD_CLASS_TYPE_FOR_CREATE = -304;
const int NLX_ERR_NULL_OBJECT_FOR_SETUP_PRC = -305;
const int NLX_ERR_PRC_SETUP_NO_FILE_NAME = -306;
const int NLX_ERR_CANT_START_THREAD = -307;


//AcqSubSys Errors
const int NLX_ERR_ACQ_RATE_IMPOSSIBLE    = -401;
const int NLX_ERR_DCDCB_CSC_CONFIG_ERROR = -402;
const int NLX_ERR_ACQ_SYSTEM_NOT_CONFIGURED_YET = -403;

// ArgcArgvProcessor Class Errors
const int NLX_ERR_ARGCV_STRING_TOO_LONG = -503;

//Gui Errors
const int NLX_NULL = -601;	//  A required pointer is uninitialized
const int NLX_ZERO = -602;	// A variable is illegally zero
const int NLX_RANGE = -603;	// Index out of range
const int NLX_DRAW = -604;	//a draw operation was unable to complete
const int NLX_CLIP = -605;	//a draw operation experienced clipping
const int NLX_NOTDONE = -606;	//a buffer or object still has data in it - may continue retrieving data
const int NLX_ZOOMED = -607;	//already zoomed
const int NLX_INVALID_DERIVED = -608;	//A derived class is invalid (missing members)
const int NLX_MALLOC = -609;	//Memory unavalilble


//Script Interface Errors
const int NLX_WRONGOBJTYPE = -701;	//the creator pointer is not init'd - should *never* happen

//Clustering Class errors
const int NLX_TOOFEWSPIKES = -801;


//General Class Errors
const int NLX_NoMainWindow = -901;
const int NLX_NoMicrosoftInit = -902;
const int NLX_SetupFileFailure = -903;

//AcqEnt Errors
		//!!!!!THIS ERROR CODE (BELOW) ABSOLUTELY CANNOT CHANGE!!!!!
const int NLX_ACQENT_NO_EXT_DATA_READY = -1001;	//scripts are going to rely on this value: it should be considered 'set in stone'
		//!!!!!END - THIS ERROR CODE (ABOVE) ABSOLUTELY CANNOT CHANGE!!!!!
const int NLX_ACQENT_Null_RB_Address = -1002;
const int NLX_ACQENT_IncompatibleBuffSize = -1003;
const int NLX_ACQENT_RB_BadSetup = -1004;
const int NLX_ACQENT_EXT_DATA_READY = 0;



//RingBuffer Errors
const int NLX_RB_Configuring_nonnull_RB = -1101;
const int NLX_RB_Bad_Config_Parameters  = -1102;
const int NLX_RB_Configure_Failure      = -1103;
const int NLX_RB_No_New_Entries_Ready   = 0;    // NOTE THIS RETURN VALUE
const int NLX_RB_Got_RB_Data            = 1;    // Note this return value						
const int NLX_RB_Bad_Ret_Index          = -1105;
const int NLX_RB_Invalid_RB_Buffer      = -1106;
const int NLX_RB_Bad_Section_Size       = -1107;
const int NLX_RB_Ret_Index_In_Use       = -1108;
const int NLX_RB_Not_In_Sectioned_Mode  = -1109;
const int NLX_RB_PriorityPrevNotCaughtUp= -1110;
const int NLX_RB_PrevRetIndexCaughtUpOkay= 1;
const int NLX_RB_Invalid_Number_Of_Records_Requested = - 1111;


// NLX Base Errors
const int  NLXB_VALUE_OUT_OF_RANGE  = -1201;
																																	

// Licensing Errors
const int NLX_NoKeyTag = -1301;
const int NLX_KeyTagInitError = -1302;
const int NLX_DateError = -1303;
const int NLX_DateHashError = -1304;
const int NLX_ProgramNotRegistered = -1305;																												
const int NLX_VersionError = -1306;
const int NLX_LicenseFileOpenError = -1307;
const int NLX_LicenseSerialError = -1308;
const int NLX_LicenseThreadError = -1309;

const int NLX_License_NoServer = -1310;
const int NLX_License_NoLicenseFile = -1311;
const int NLX_License_NotRegistered = -1312;
const int NLX_License_ExceededChannelCount = -1313;
const int NLX_License_ExceededLicensedCount = -1314;
const int NLX_License_Expired = -1315;
const int NLX_License_Invalid = -1316;
const int NLX_License_VerifyFailed = -1317;
const int NLX_License_VersionError = -1318;
const int NLX_License_Unknown = -1399;

// ADAcqEnt Errors
const int NLX_ADAcqEnt_Bad_Subsampling_Value = -1401;

// CGL Setup Errors
const int NLX_CglSetupConfig_Cant_Do_Setup_ADFS_Too_Low  = -1501;   // returned from GofigureConfiguration
const int NLX_CglSetupConfig_CGL_Header_Entry    = -1502;
const int NLX_CglSetupConfig_CGL_Trailer_Entry  = -1503;
const int NLX_CglSetupConfig_CGL_NULL_Entry = -1504;
const int NLX_CglSetupConfig_CGL_Invalid_Rec_Num = -1505;
const int NLX_CglSetupConfig_CGL_Invalid_Entry_Num = -1506;										
const int NLX_CglSetupConfig_Cant_Do_Setup_CGL_Too_Small = -1507;
const int NLX_CglSetupConfig_Scan_Freq_Too_Low = -1508;
const int NLX_CglSetupConfig_Scan_Freq_Too_High = -1509;
const int NLX_CglSetupConfig_Cgl_Size_Way_Too_Small = -1510;
const int NLX_CglSetupConfig_AD_Sample_Rate_Too_Low = -1511;
const int NLX_CglSetupConfig_No_Valid_Channels = -1512;
const int NLX_CglSetupConfig_Invalid_Interleave_for_NumCglRecs =-1513;
const int NLX_CglSetupConfig_Too_Many_Channels  =  -1514;
const int NLX_CglSetupConfig_Channel_Already_In_Array = -1515;
const int NLX_CglSetupConfig_Rec_Entry_Interleave_Not_Good  = -1516;
const int NLX_CglSetupConfig_Cant_Fit_Channel_Into_Configuration = -1517;
const int NLX_CglSetupConfig_Invalid_GCL_Record_Num = -1518;
const int NLX_CglSetupConfig_Invalid_GCL_Record_Entry_Num = -1519;
const int NLX_CglSetupConfig_CGL_Header = -1520;
const int NLX_CglSetupConfig_CGL_Trailer = -1521;
const int NLX_CglSetupConfig_CGL_NULL_Inbetween = -1522;
const int NLX_CglSetupConfig_Unused_CGL_Entry = -1523;
const int NLX_CglSetupConfig_Internal_Error_ADChannel_Not_Found = -1524;


// DCDCB PI ARP errors
const int NLX_Dcdcb_ARPPI_BAD_PARENT_ACQSUBSYS_ADRESS = -1601;
const int NLX_Dcdcb_ARPPI_CANNOT_DO_REQUESTED_FUNCTION = -1602;
const int NLX_DT3010_ARPPI_BAD_PARENT_ACQSUBSYS_ADRESS = NLX_Dcdcb_ARPPI_BAD_PARENT_ACQSUBSYS_ADRESS;
const int NLX_DT3010_ARPPI_CANNOT_DO_REQUESTED_FUNCTION = NLX_Dcdcb_ARPPI_CANNOT_DO_REQUESTED_FUNCTION;

// DT3010 Board class errors
const int NLX_DT3010BOARD_BAD_CTR_NUM = -1701;
const int NLX_DT3010BOARD_FAILED_CTR_OPERATION = -1702;
const int NLX_DT3010BOARD_AD_Acq_Ent_Array_Full = -1703;
const int NLX_DT3010BOARD_INTERNAL_CGL_SETUP_ERROR = -1704;
const int NLX_DT3010BOARD_BAD_NUM_DMA_BUFFS = -1705;
const int NLX_DT3010BOARD_BAD_DMA_BUF_SIZE = -1706;
const int NLX_DT3010_BOARD_BAD_RETRIG_COUNT = -1707;
const int NLX_DT3010_BOARD_Retrig_Acq_CGLRecs_NE1 = -1708;
const int NLX_DT3010BOARD_BAD_NUM_DA_DMA_BUFFS = -1709;
const int NLX_DT3010BOARD_BAD_DA_DMA_BUF_SIZE = -1710;
const int NLX_DT3010BOARD_POSS_TIMESTAMP_ROUNDOFF_ERROR = -1711;
const int NLX_DT3010BOARD_DAC_MODE_INCORRECT  = -1712;
const int NLX_DT3010BOARD_No_Idle_DA_Buffs = -1713;
const int NLX_DT3010BOARD_BAD_DAC_DMA_BUF_NUM = -1714;
const int NLX_DT3010BOARD_BAD_BUFD_WAV_NUM  = -1715;
const int NLX_DT3010BOARD_BAD_DAC_FS = -1716;

// DCDCB Video Tracker errors
const int NLX_VT_PRC_BadVideoRecord = -1801;
const int NLX_VT_PRC_VideoRecordOverflow = -1802;

// DCDCB Video Tracker Target processing errors
const int NLX_VTT_NotInTarget =    -1901;
const int NLX_VTT_SetmentArrayOverflow =  -1902;
const int NLX_VTT_NoSegmentsInTarget   =  -1903;
const int NLX_VTT_CantAllocPixArray  =  -1904;
const int NLX_VTT_BadMaxDistValue     = -1905;
const int NLX_VTT_BadSegment          =-1906;

// Audio Local Errors
const int NLX_AUDIO_LOCAL_CAST_ERROR  = -2001;


//Amp Programming Errors
const int NLX_CBDINITFAIL = -2101;
const int NLX_CBDIOFAIL = -2102;
const int NLX_USBIOFAIL = -2103;


// DT3120 Video Errors
const int NLX_DT3120_Err = -2201;
const int NLX_DT3120_Over400Spots = -2202;

// AcqSubSys Errors
const int NLX_ACQ_SUB_SYS_BAD_VT_THRESH = -2301;


//file errors
const int NLX_FILEALREADYOPEN = -2401;
const int NLX_FILENOTOPEN = -2402;
const int NLX_WRONGFILETYPE = -2403;
const int NLX_FILENOHEADER = -2404;

//device not capable of digital input
const int NLX_NOTDIGITALCONF = -2501;

// NLX_DT3010_Board_BufWav errors
const int NLX_DT3010_Board_BufdWav_WaveFileOpenFail  = -2601;
const int NLX_DT3010_Board_BufdWav_WaveFileBadData  = -2602;





#endif


