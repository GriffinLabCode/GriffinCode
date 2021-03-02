//***************************************************
// File Name: Nlx_DataTypes
// Created 1/8/01 Steve Franks
// This file 'works' with no modification under MS Visual C++ 6.0
// Copyright 1998 - 2014 @ Neuralynx, Inc.
//***************************************************
#pragma once

#pragma pack(push, before_nlx_datatypes) //needs matching pop at the end
#pragma pack(1)//This forces all records to be byte-packed for most efficient use of disk space & lack of confusion

#include <climits>
#include <string>
#include <vector>

#pragma region C++98/03 Hacks
//the following defines and code allow this header to be used
//with compilers that do not support C++11. We do automatic
//detection only for visual studio versions. If this code is
//used with other compilers, USE_CPP_98 should be defined using
//other criteria.
#ifndef VS2010_VER
#define VS2010_VER 1600
#endif
#ifndef VS2003_VER
#define VS3003_VER 1310
#endif

#if (_MSC_VER < 1700) //Compiling with Visual Studio version before VS2012
#ifndef USE_CPP_98
#define USE_CPP_98 //need to use C++98 syntax
#endif
#endif

#ifdef USE_CPP_98

//suppress some VC++ warnings for this header to take advantage
//of non-compliant extensions to C++98/03 supported by VS2008
#pragma warning(push)
//visual studio supports referring to the enum values via NlxDataType::<value>
//prior to c++11. This is a non-standard extension and generates C4482 warnings, so we
//disable them here and undo this at the end
#pragma warning(disable : 4480)
//enum class and underlying type specification not supported by C++03, but underlying type
//specification is as a VC++ extension, so we'll disable those warnings for this header
#pragma warning(disable : 4482)
//negative enum values generate an invalid warning in vs2010 and earlier
#pragma warning(disable : 4341)

//defining some std code that is not available in C++98/03
namespace std
{
	//define the int types that we use in this header that would be in cstdint,
	//which is not part of visual studio's c++98 implementation. This uses
	//VC++ specific types
	typedef unsigned __int64 uint64_t;
	typedef __int64 int64_t;
	typedef unsigned __int32 uint32_t;
	typedef __int32 int32_t;
	typedef unsigned __int16 uint16_t;
	typedef __int16 int16_t;
	typedef unsigned char uint8_t;
	typedef char int8_t;

	//non-member begin for containers only since the
	//array form is not used in this header
	template <typename Cont>
	typename Cont::iterator begin(Cont& c)
	{
		return c.begin();
	}
}
#else
#include <cstdint> //only available in VS2012 and newer
#endif

//VS2005 and 2008 define nullptr
//for cli projects, but not for regular C++
#ifndef __cplusplus_cli
#if (_MSC_VER < VS2010_VER)
#define nullptr NULL
#endif
#else
//vs2003 and earlier have no concept of nullptr
#if (_MSC_VER <= VS3003_VER)
#define nullptr NULL
#endif
#endif

#pragma endregion


/// <summary>Namespace for all custom data types supported by Neuralynx.</summary>
namespace NlxDataTypes {


#pragma region Operations for all data types
		/// <summary>Enumeration of all data types defined in this header.</summary>
		/// <description>Enumeration of all data types defined in this header.</summary>
#ifdef USE_CPP_98
	//enum class not supported by C++03
	enum NlxDataType : std::uint8_t {
#else
	enum class NlxDataType : std::uint8_t
	{
#endif
		Invalid = 0, ///< An unknown data type
		SingleElectrode = 1, ///< Single electrode data type
		Stereotrode = 2, ///< Stereotrode data type
		Timestamp = 3, ///< Timestamp data type
		Tetrode = 4, ///< Tetrode data type

		CSC = 5, ///< CSC data type
		Event = 6, ///< Event data type
		VideoTracker = 7, ///< Video Tracker data type
		RawData = 8, ///< Raw data type
		MClustTimestamp = 9, ///< MClust timestamp data type
		CompressedChannel = 10, ///< Compressed Channel data type
		SessionIndex = 11, ///< Session index data type

		Subject = 12, ///< Subject data type
		DataProcessingErrors = 13, ///< Data processing errors data type.

		PersystLay = 14, ///< Persyst Layout data type.
		PersystDat = 15 ///< Persyst Data data type.
	};

		//TODO: Move these to NetCom for the next NetCom release
		//these are used for NetCom, they were also used in cheetah 4 to denote filetype in a data files header
		//currently used strings include (CSC, Spike, Event, Nothing for Video or TS)
#ifdef _UNICODE
		const wchar_t NetComSEDataType [] = L"SEScAcqEnt"; ///< String used for identification in NetCom
		const wchar_t NetComSTDataType [] = L"STScAcqEnt"; ///< String used for identification in NetCom
		const wchar_t NetComTTDataType [] = L"TTScAcqEnt"; ///< String used for identification in NetCom
		const wchar_t NetComCSCDataType [] = L"CscAcqEnt"; ///< String used for identification in NetCom
		const wchar_t NetComEventDataType [] = L"EventAcqEnt"; ///< String used for identification in NetCom
		const wchar_t NetComVTDataType [] = L"VTAcqEnt"; ///< String used for identification in NetCom
		const wchar_t NetComAcqSourceDataType[] = L"AcqSource"; ///< String used for identification in NetCom
#else
		const char NetComSEDataType [] = "SEScAcqEnt"; ///< String used for identification in NetCom
		const char NetComSTDataType [] = "STScAcqEnt"; ///< String used for identification in NetCom
		const char NetComTTDataType [] = "TTScAcqEnt"; ///< String used for identification in NetCom
		const char NetComCSCDataType [] = "CscAcqEnt"; ///< String used for identification in NetCom
		const char NetComEventDataType [] = "EventAcqEnt"; ///< String used for identification in NetCom
		const char NetComVTDataType [] = "VTAcqEnt"; ///< String used for identification in NetCom
		const char NetComAcqSourceDataType[] = "AcqSource"; ///< String used for identification in NetCom
#endif
	namespace {

		//*******************************************
		/// <summary>Translates an NLX_DATA_TYPE to a human readable string.</summary>
		/// <description>Translates an NLX_DATA_TYPE to a human readable string.</description>
		/// <param name="dataType">The data type enumeration to translate.</param>
		/// <returns>Returns the human readable string for the passed data type or "Invalid" if
		/// an invalid data type was passed.</returns>
		 std::wstring GetDataTypeLabel(const NlxDataType& dataType)
		{
			switch (dataType)
			{
			case NlxDataType::Invalid:
				return(L"Invalid");
			case NlxDataType::SingleElectrode:
				return(L"SingleElectrode");
			case NlxDataType::Stereotrode:
				return(L"Stereotrode");
			case NlxDataType::Timestamp:
				return(L"Timestamp");
			case NlxDataType::Tetrode:
				return(L"Tetrode");
			case NlxDataType::CSC:
				return(L"CSC");
			case NlxDataType::Event:
				return(L"Event");
			case NlxDataType::VideoTracker:
				return(L"Video");
			case NlxDataType::RawData:
				return(L"Raw");
			case NlxDataType::MClustTimestamp:
				return(L"MClustTS");
			case NlxDataType::CompressedChannel:
				return(L"NCC");
			case NlxDataType::SessionIndex:
				return(L"SessionIndex");
			case NlxDataType::Subject:
				return(L"Subject");
			case NlxDataType::DataProcessingErrors:
				return(L"DataProcessingErrors");
			case NlxDataType::PersystLay:
				return(L"PersystLayout");
			case NlxDataType::PersystDat:
				return(L"PersystData");
			}
			return(L"Invalid");
		}
	}
#pragma endregion

#pragma region Errors

		/// <summary>Enumeration of return error codes used by this library.</summary>
		/// <description>All of the possible error codes returned by this library.</description>
		enum NlxRetVal : int 
		{
			NlxOK = 0, ///< No error.
			NlxError = -1, ///< An unspecified error occurred.
		};

		///////////////////////////
		// Data Processing Errors
		///////////////////////////

		//values found in public spec doc for Data Processing Errors File v1.0.0
		const int DPE_ObjectNameLength = 128;

		struct DataProcessingErrorsRec {

			DataProcessingErrorsRec()
				: startTimestamp(0)
				, endTimestamp(0)
				, lostSamples(0)
				, dataType(NlxDataType::Invalid)
			{
				memset(objectName, '\0', sizeof(objectName));
			}

			char objectName[DPE_ObjectNameLength];
			std::uint64_t startTimestamp;
			std::uint64_t endTimestamp;
			std::uint32_t lostSamples;
			NlxDataType dataType; //value matching NLX_DATA_TYPE enum
		};

#pragma endregion

#pragma region Spike Data Types

		//////////////////
		// Spike Datatypes
		//////////////////

		const int TTNumChannels= 4; ///< Number of channels in a tetrode AE.
		const int STNumChannels= 2; ///< Number of channels in a stereotrode AE.
		const int SENumChannels= 1;	///< Number of channels in a single electrode AE.

		// Kevin - setting up const variables for next generation of spike support (Polytrodes)
		const unsigned int MinSpikeChannelCount = 1; ///< Minimum number of channels in a spike AE
		const unsigned int MaxSpikeChannelCount = 16; ///< Maximum number of channels in a spike AE
		const unsigned int MaxSpikeFeatureCount = 8; ///< The maximum number of features that can be calculated for a single spike AE. Used to be MAX_PARAMS.
		const int MinSpikeFeatureValue = SHRT_MIN; ///< Minimum value for a calculated spike feature
		const int MaxSpikeFeatureValue = SHRT_MAX; ///< Maximum value for a calculated spike feature
		const unsigned int MinSpikeWaveformLength = 32; ///< Minimum number of samples per channel for a single spike waveform.
		const unsigned int MaxSpikeWaveformLength = 512; ///< Maximum number of samples per channel for a single spike waveform.
		const unsigned int MaxSpikeClusterCount = 33; ///< Maximum number of separate clusters that can be defined

		const int MAX_NUMELECTRODES = 4; ///<Deprecated see NlxDataTypes::MaxSpikeChannelCount Still required when working on programs that are not polytrode aware.
		const int SPIKE_NUMPOINTS = MinSpikeWaveformLength; ///< Deprecated see NlxDataTypes::MinSpikeWaveformLength

		/// <summary>A record representing the non-waveform portion of a spike record.</summary>
		/// <description>A record representing the non-waveform portion of a spike record.</description>
		struct SCRec	{
			std::uint64_t qwTimeStamp; ///< Timestamp in microseconds
			std::uint32_t dwScNumber; ///< Specifies the order in which this spike AE was created relative to all other spike AE created by the system.
			std::uint32_t dwCellNumber; ///< What cell was this calculated to be? filled in by online cluster analysis
			std::int32_t dnParams[MaxSpikeFeatureCount]; ///< Feature calculations for this record. Which calculations are performed is defined by external application.
		};

		/// <summary>A single point for each channel of a tetrode spike waveform.</summary>
		/// <description>A single point for each channel of a tetrode spike waveform.</description>
		struct TetPoint {
			/// <summary> A single point in the waveform for all channels of a spike record.
			/// These points should be time aligned.</summary>
			std::int16_t snADVal[TTNumChannels];
		};

		/// <summary>A record representing single spike event captured for a tetrode.</summary>
		/// <description>A record representing single spike event captured for a tetrode.</description>
		struct TTRec : SCRec {
			TetPoint snData[SPIKE_NUMPOINTS]; ///< Samples in the waveform for this spike record.
		};


		/// <summary>A single point for each channel of a stereotrode spike waveform.</summary>
		/// <description>A single point for each channel of a stereotrode spike waveform.</description>
		struct StereoPoint {
			/// <summary> A single point in the waveform for all channels of a spike record.
			/// These points should be time aligned.</summary>
			std::int16_t snADVal[STNumChannels];
		};

		/// <summary>A record representing single spike event captured for a stereotrode.</summary>
		/// <description>A record representing single spike event captured for a stereotrode.</description>
		struct STRec : SCRec {
			StereoPoint snData[SPIKE_NUMPOINTS]; ///< Samples in the waveform for this spike record.
		};

		/// <summary>A single point for single electrode spike waveform.</summary>
		/// <description>A single point for single electrode spike waveform.</description>
		struct SinglePoint {
			std::int16_t snADVal[SENumChannels]; ///< A single point in the waveform for a spike record.
		};

		/// <summary>A record representing single spike event captured for a stereotrode.</summary>
		/// <description>A record representing single spike event captured for a stereotrode.</description>
		struct SERec : SCRec {
			SinglePoint	snData[SPIKE_NUMPOINTS];  ///< Samples in the waveform for this spike record.
		};

#pragma endregion

#pragma region CSC

		////////////////////////////////
		// Continuous Sampling Datatypes
		////////////////////////////////

		const int MAX_CSC_SAMPLES = 512; ///< Maximum number of samples to store in a single CSC record
		const int CSC_NUMELECTRODES = 1; ///<  Number of electrodes associated with a single CSC AE.

		/// <summary>A record representing portion of a continuously sampled channel (CSC).</summary>
		/// <description>A record representing portion of a continuously sampled channel (CSC).</description>
		struct CRRec	{
			std::uint64_t qwTimeStamp; ///< Timestamp in microseconds
			std::uint32_t dwChannelNum; ///< AD channel number assigned to this csc AE
			std::uint32_t dwSampleFreq; ///< Sampling rate for this csc AE in Hz.
			std::uint32_t dwNumValidSamples;///< Number of sequential values in CRRec::snSamples that contain valid data
			std::int16_t snSamples[MAX_CSC_SAMPLES];///< Waveform samples for this record.
		};

#pragma endregion

#pragma region Event

		//////////////////
		// Event Datatypes
		//////////////////

		const int EventNumExtras = 8; ///< Number of extra fields added to an event record for future use
		const int EventRecStringSize = 128; ///< Size allocated for the event string portion of an event record.


		///<summary>Enumeration of possible ID values used in an event record</summary>
		///<description>This enum is used to determine the source of the event and
		/// replaces all of the const ints declared in various locations.
		/// Since the event string for TTL records describes the source
		/// in more detail, this value is no longer necessary.  However,
		/// we are going to keep it around for backward compatability.
		/// The following event IDs are not used in Cheetah, and
		/// since this file was probably the only place these values were
		/// used, I'll keep them around in case some other program needs 
		/// to look up the old values for some reason.  These values are
		/// skipped in the enumeration in case they need to be added back in.<br>
		/// CUBE_EVENTID = 0x69<br>
		/// OPTIONAL_DIGITALINPUT_EVENTID = 10<br>
		/// CONFIGFILE_DEFAULT_EVENTID = 5<br>
		/// VIDEOEVENTGEN_EVENTID = 6<br>
		/// ERID_HAWK = 18</description>
		enum EventRecID : short
		{ //not a class because we need implicit conversion to int
			Unknown = -1, ///< Event is of unknown origin
			DigitalLynx = 0, ///< Event generated by Digital Lynx hardware.
			DT3010Board1 = 1, ///< Event generated by DT3010 board #1, replaces DT3010_BOARD1_EVENTID
			DT3010Board2 = 2, ///< Event generated by DT3010 board #2, replaces DT3010_BOARD2_EVENTID 
			RawDataFile = 3, ///< Event generated from a raw data file during playback.
			ManualEventEntry = 4, ///< Any event generated by the user at the keyboard gets this id, replaces KEYBOARD_EVENTID
			DT3010Board1DACOutputStarted = 7, ///< Event generated when DT3010 board #1 begins DAC output. TTL value will be the wave buffer #, replaces DT3010_BOARD1_DAC_OUTPUT_STARTED
			DT3010Board2DACOutputStarted = 8, ///< Event generated when DT3010 board #2 begins DAC output. TTL value will be the wave buffer #, replaces DT3010_BOARD2_DAC_OUTPUT_STARTED
			LynxSX = 11, ///< Event generated by the Digital Lynx SX hardware.
			DT3010Board1ADCACQStarted = 12, ///< Event generated when DT3010 board #1 starts acquisition, replaces DT3010_BOARD1_ADC_ACQ_STARTED
			DT3010Board2ADCACQStarted = 14, ///< Event generated when DT3010 board #2 starts acquisition, replaces DT3010_BOARD2_ADC_ACQ_STARTED
			Falcon = 15, ///< Event generated by the Falcon hardware.
			Sparrow = 16, ///< Event generated by the Sparrow hardware
			AdditionalDigitalIO = 17, ///< Event generated from an addon DIO board, replaces ADDONDIGITALINPUT_EVENTID
			DataAcquisitionSoftware = 19, ///< Event generated by the Data Acquisition Software.
			Atlas = 20, ///< Event generated by the Atlas hardware.

			Cheetah160 = 119 ///< Event generated by the Cheetah160 hardware, replaces DCDCB_EVENTID
		};

		/// <summary>A record representing a single event.</summary>
		/// <description>A record representing a single event.</description>
		struct EventRec	{
			short nstx;///< Value is always 800
			short npkt_id; ///< ID for the originating system of this packet
			short npkt_data_size;///< Value is always 2.
			std::uint64_t qwTimeStamp; ///< Timestamp in microseconds
			EventRecID nevent_id; ///< The source of this event
			short nttl;///< Decimal TTL value associated with the event source.
			short ncrc;///< CRC check for the event record if hardware generated. Otherwise 0.
			short ndummy1;///< just a place holder
			short ndummy2;///< just a place holder
			std::int32_t dnExtra[EventNumExtras]; ///< Extra bit values that can be filled by hardware.

			/// <summary>Event string describing the event that generated this record.
			/// This string consists of NlxDataTypes::EventRecStringSize 
			/// characters including the required null termination character.If the string is less
			/// than that length, the remainder of the characters will be null.
			/// < / summary>
			char EventString[EventRecStringSize];
		};

#pragma endregion

#pragma region Video Tracker

		//////////////////////////
		// Video Tracker Datatypes
		//////////////////////////

		const int VTRecNumTransitionBitfields = 400; ///< Number of VT bitfield transitions stored in the VideoRec::dwPoints array
		const int VTRecNumTargets = 50; ///< Number of VT bitfield transitions stored in the VideoRec::dntargets array
		const std::uint16_t VTRecSWST = 0x800; ///< Value always used for VideoRec::swstx

		// bit masks for isolating data from bitfields contained in 'dwPoints' and 'dntargets'
		const unsigned int VREC_COLOR_MASK = 0x7000F000;  	// logical OR of all the colors
		const unsigned int VREC_IN_MASK = 0x8000;		// intensity mask
		const unsigned int VREC_RR_MASK = 0x4000;		// pure & raw RGB masks
		const unsigned int VREC_RG_MASK = 0x2000;
		const unsigned int VREC_RB_MASK = 0x1000;
		const unsigned int VREC_PR_MASK = 0x40000000;
		const unsigned int VREC_PG_MASK = 0x20000000;
		const unsigned int VREC_PB_MASK = 0x10000000;
		const unsigned int VREC_RS_MASK = 0x80000000;		// reserved bit mask
		const unsigned int VREC_X_MASK = 0x00000FFF;		// x value mask
		const unsigned int VREC_Y_MASK = 0x0FFF0000;		// y val

		///<summary>A decoded version of VT bitfield value.</summary>
		///<description>A decoded version of VT bitfield value.</description>
		struct DecodedVTBitfield {
			bool Intensity; ///< True if the intensity bit is set.
			bool Red; ///< True if the red bit is set.
			bool Green; ///< True if the green bit is set.
			bool Blue; ///< True if the blue bit is set
			std::uint16_t X; ///< The x coordinate.
			std::uint16_t Y; ///< The y coordinate.
		};
	namespace {

		///<summary>Decodes a VT bitfield.</summary>
		///<description>Decodes a VT bitfield.</description>
		///<param name="vtBitfield">The bitfield that is to be decoded.</param>
		///<returns>The decoded version of the passed bitfield.</returns>
		DecodedVTBitfield DecodeVTBitfield(const std::uint32_t vtBitfield)
		{
			DecodedVTBitfield decodedBitfield;
			decodedBitfield.Intensity = (VREC_IN_MASK & vtBitfield) != 0;
			decodedBitfield.Red = (VREC_PR_MASK & vtBitfield) != 0;
			decodedBitfield.Green = (VREC_PG_MASK & vtBitfield) != 0;
			decodedBitfield.Blue = (VREC_PB_MASK & vtBitfield) != 0;
			decodedBitfield.X = static_cast<std::uint16_t>(VREC_X_MASK & vtBitfield);
			decodedBitfield.Y = static_cast<std::uint16_t>((VREC_Y_MASK & vtBitfield) >> 16);
			return decodedBitfield;
		}

		///<summary>Encodes a VT bitfield from a decoded struct.</summary>
		///<description>Encodes a VT bitfield from a decoded struct.</description>
		///<param name="decodedVTBitfield">The decoded bitfield that is to be encoded.</param>
		///<returns>The encoded version of the passed decoded bitfield.</returns>
		std::uint32_t EncodeVTBitfield(const DecodedVTBitfield& decodedVTBitfield)
		{
			std::uint32_t encodedVTBitfield = 0;
			encodedVTBitfield |= (decodedVTBitfield.Intensity ? VREC_IN_MASK : 0);
			encodedVTBitfield |= (decodedVTBitfield.Red ? VREC_PR_MASK : 0);
			encodedVTBitfield |= (decodedVTBitfield.Green ? VREC_PG_MASK : 0);
			encodedVTBitfield |= (decodedVTBitfield.Blue ? VREC_PB_MASK : 0);
			encodedVTBitfield |= static_cast<std::uint32_t>(decodedVTBitfield.X);
			encodedVTBitfield |= (static_cast<std::uint32_t>(decodedVTBitfield.Y) << 16);
			return encodedVTBitfield;
		}
	}
		/// <summary>A record representing a single thresholded video frame.</summary>
		/// <description>A record representing a single thresholded video frame.</description>
		struct VideoRec	{
			std::uint16_t swstx; ///< Value is always NlxDataTypes::NLX_VTREC_SWSTX
			std::uint16_t swid;	///< The ID assigned to the video tracker that created this record
			std::uint16_t swdata_size; ///< The size of the VT record in bytes
			std::uint64_t qwTimeStamp; ///< Timestamp of this record in microseconds
			std::uint32_t dwPoints[VTRecNumTransitionBitfields]; ///< An array of bitfields encoding all threshold crossings in the video frame.
			std::int16_t sncrc; ///< Ignored, relic from Cheetah160VT
			std::int32_t dnextracted_x; ///< Calculated x coordinate from our extraction algorithm
			std::int32_t dnextracted_y;	///< Calculated y coordinate from our extraction algorithm
			std::int32_t dnextracted_angle; ///< Calculated head direction in degrees from the Y axis
			std::int32_t dntargets[VTRecNumTargets]; ///< An array of aggregated transitions in the same bitfield format as VideoRec::dwPoints
		};

#pragma endregion

#pragma region AD Records

		//////////////////
		// AD(Raw) Datatype
		//////////////////
		// This is the on disk format for an NRD record.
		//*****************************************************************************
		//  AD(Raw) Record Format:
		//  STX (or SOP)    2048
		//  Packet ID       1
		//  Size            0x0000002A   hex for (# A/D data wds + #extra wds = N+10)
		//  TimeStamp Hi    1 32 bit word
		//  TimeStamp Low   1 32 bit word
		//  CPU_Status_wd   1 32 bit word
		//  Parallel_in     1 32 bit word
		//  10 extras      10 32 bit words
		//  A/D data       32 or more 32 bit words depending on the number of AD channels in the system
		//  CRC             1 32 bit XOR of the entire packet including STX
		//*****************************************************************************
		const std::uint16_t ADRecordStx = 2048; ///< Start of AD packet identifier
		const std::uint16_t ADRecordID = 1; ///< Value always used for the record ID.
		const int ADRecNumExtras = 10; ///< Number of extra values reserved in an AD packet
	namespace {

		/// <summary>Creates a full timestamp from a low and high portion of a timestamp.</summary>
		/// <description>Creates a full timestamp from a low and high portion of a timestamp.</description>
		/// <param name="timestampLow">The low order 32 bits of the timestamp.</param>
		/// <param name="timestampHigh">The high order 32 bits of the timestamp.</param>
		/// <returns>A full timetamp.</returns>
		std::uint64_t CreateNlxTimestamp(const std::uint32_t timestampLow, const std::uint32_t timestampHigh) {
			std::uint64_t tsTmp = timestampHigh;
			tsTmp <<= 32;
			tsTmp += timestampLow;
			return tsTmp;
		}

		/// <summary>Unpacks a full timestamp into its high and low components.</summary>
		/// <description>Unpacks a full timestamp into its high and low components.</description>
		/// <param name="timestamp">The timestamp to unpack.</param>
		/// <param name="timestampLow">Output value containing the low order 32 bits of the timestamp.</param>
		/// <param name="timestampHigh">Output value containing the high order 32 bits of the timestamp.</param>
		void UnpackNlxTimestamp(const std::uint64_t& timestamp, std::uint32_t& timestampLow, std::uint32_t& timestampHigh) {
			timestampHigh = static_cast<std::uint32_t>(timestamp >> 32);
			timestampLow = static_cast<std::uint32_t>(timestamp & 0x00000000FFFFFFFF);
		}
	}
		/// <summary>A record representing a single sample of raw data from all channels of that system
		/// at a single point in time.</summary>
		/// <description>A record representing a single sample of raw data from all channels of that 
		/// system a single point in time.</description>
		class NRDRec {
		public:
			/// <summary>Constructs a record using default parameters with the sample data set to nullptr.</summary>
			/// <description>Constructs a record using default parameters that the sample data set to nullptr.</description>
			NRDRec() :
				PacketID(ADRecordID),
				qwTimeStamp(0),
				Data(nullptr),
				PacketSize(ADRecNumExtras),
				Status(0),
				ParallelInputPortValue(0),
				CRC(0),
				mNumADChannels(0),
				mOwnedDataPointer(Data)
			{

				memset(Extras, 0, ADRecNumExtras * sizeof(std::uint32_t) );
			};

			/// <summary>Constructs a record by copying the contents from another NRDRec object.</summary>
			/// <description>Constructs a record by copying the contents from another NRDRec object.
			/// Including making a copy of the data pointed to by the Data member.</description>
			/// <param name="rhs">The NRDRec whose contents will initialize a new NRDRec.</param>
			NRDRec(const NRDRec& rhs) :
				PacketID(rhs.PacketID),
				qwTimeStamp(rhs.qwTimeStamp),
				Data(new std::int32_t(rhs.mNumADChannels)),
				PacketSize(rhs.PacketSize),
				Status(rhs.Status),
				ParallelInputPortValue(rhs.ParallelInputPortValue),
				CRC(rhs.CRC),
				mNumADChannels(rhs.mNumADChannels),
				mOwnedDataPointer(Data)
			{
				memcpy(this->Extras, rhs.Extras, ADRecNumExtras * sizeof(std::uint32_t) );
				memcpy(this->Data, rhs.Data, rhs.mNumADChannels * sizeof(std::int32_t) );
			};

			
#ifndef USE_CPP_98

			/// <summary>Constructs a record by moving the contents from another NRDRec object, rendering that other object unusable.</summary>
			/// <description>Constructs a record by moving the contents from another NRDRec object, rendering that other object unusable.</description>
			/// <param name="rhs">The NRDRec whose contents will be moved to a new NRDRec.</param>
			NRDRec(NRDRec && rhs) :
				PacketID(rhs.PacketID),
				qwTimeStamp(rhs.qwTimeStamp),
				Data(rhs.Data),
				PacketSize(rhs.PacketSize),
				Status(rhs.Status),
				ParallelInputPortValue(rhs.ParallelInputPortValue),
				CRC(rhs.CRC),
				mNumADChannels(rhs.mNumADChannels),
				mOwnedDataPointer(Data)
			{
				//TODO: this should take advantage of pointer swapping, but
				//don't know how to do it yet for static arrays
				memcpy(this->Extras, rhs.Extras, ADRecNumExtras * sizeof(std::uint32_t) );

				//reset the old data pointer
				rhs.Data = nullptr;
			}
#endif
			/// <summary>Releases any resources owned by this object.</summary>
			/// <description>Releases any resources owned by this object.</description>
			~NRDRec()
			{
				if (mOwnedDataPointer != nullptr) {
					delete [] mOwnedDataPointer;
				}
			};

			/// <summary>Releases any resources owned by this object.</summary>
			/// <description>Sets the number of channels that this object will store. If the number
			/// of channels is changed, this function will
			/// create a local array of sample data that will be deleted when this object is 
			/// deleted. It will not delete data not owned by this record. Subsequent calls to
			/// this function on this object will create a new array and copy over any data contained
			/// in the sample data array up to the new channel count.</description>
			/// <param name="numADChannels">The number of channels that this NRDRec will store.</param>
			void SetNumADChannels(const std::uint32_t numADChannels)
			{
				//check for no change
				if (numADChannels == mNumADChannels) {
					return;
				}
				//resize the internal data array and
				//copy the old data into the new array
				std::int32_t* oldOwnedDataPointer = this->mOwnedDataPointer;
				this->mOwnedDataPointer = new std::int32_t[numADChannels];
				if (mNumADChannels > numADChannels) {
					memcpy(this->mOwnedDataPointer, oldOwnedDataPointer, numADChannels * sizeof(std::int32_t) );
				}
				else if (numADChannels > mNumADChannels) {
					memcpy(this->mOwnedDataPointer, oldOwnedDataPointer, mNumADChannels * sizeof(std::int32_t) );
					memset(&this->mOwnedDataPointer[mNumADChannels], 0, (numADChannels - mNumADChannels) * sizeof(std::int32_t) );
				}

				if (oldOwnedDataPointer != nullptr) {
					delete [] oldOwnedDataPointer;
					oldOwnedDataPointer = nullptr;
				}
				mNumADChannels = numADChannels;
				Data = mOwnedDataPointer;

				//adjust the packet size so that it uses
				//the new number of AD channels
				this->PacketSize = mNumADChannels + ADRecNumExtras;
			}
	
			//public members since we want to treat this as a struct
			static const std::int32_t STX = ADRecordStx; ///< Start of packet constant
			std::int32_t PacketID; ///< The ID of the packet that contained all of the samples in this record.
			std::int32_t PacketSize; ///< The size of the packet that contained all of the samples in this record.
			std::uint64_t qwTimeStamp; ///< The timestamp in microseconds that corresponds to the sample stored for each channel.
			std::int32_t Status; ///< TODO: figure out what this value is
			std::uint32_t ParallelInputPortValue; ///< TTL value read from an acquisition system TTL port
			std::int32_t Extras[ADRecNumExtras]; ///< Extra values reserved for future use

			/// <summary>Pointer to a sample for each channel with the array index representing the AD channel number.
			/// If some external location is storing the data for this record, set the Data pointer to point to the
			/// first sample of the external data. If NRDRec::SetNumADChannels is called, this pointer becomes a pointer
			/// to an array owned by this object and does not change the data previously pointed to by the Data pointer.
			/// </summary>
			std::int32_t* Data; 

			std::int32_t CRC; ///< CRC generated by hardware

			//private members
		private:
			std::uint32_t mNumADChannels; ///< Number of AD channels in this record

			/// <summary>Used to determine if the Data pointer has
			/// changed where it points to to see if we
			/// are responsible for deleting the data or not.</summary>
			std::int32_t* mOwnedDataPointer;
		};


#pragma endregion

#pragma region NCC

		////////////
		// Neuralynx Compressed Channel
		////////////

		//values found in public spec doc for NCC v1.0.0
		const int NCC_DefaultBlockLength = 298;
		const int NCC_RangeEncodingModelLength = 256;

		struct NCCRec {
			NCCRec()
				: startIndicator(43981)
				, lengthInBytes(NCC_DefaultBlockLength)
				, startTimestamp(0)
				, endTimestamp(0)
				, sampleCount(0)
				, minUncompressedValue(0)
				, maxUncompressedValue(0)
				, differenceEncodedValuesCount(0)
				, compressedData(nullptr)
				, crc(0)
			{
				memset(rangeEncodingModel, 0, sizeof(rangeEncodingModel));
			}

			std::uint16_t			startIndicator;
			std::uint32_t			lengthInBytes;
			std::uint64_t			startTimestamp;
			std::uint64_t			endTimestamp;
			std::uint32_t			sampleCount;
			std::int32_t			minUncompressedValue;
			std::int32_t			maxUncompressedValue;
			std::uint32_t			differenceEncodedValuesCount;
			std::uint8_t			rangeEncodingModel[NCC_RangeEncodingModelLength];
			std::uint8_t*			compressedData;
			std::uint32_t			crc;

		};

#pragma endregion

#pragma region Session Index

		////////////
		// SessionIndex
		////////////

		//values found in public spec doc for Session Index File v1.0.0
		const size_t SI_FilePathLength = 8000;
		const int SI_UUIDLength = 16;
		const std::uint64_t SI_InvalidTimestamp = 0xFFFFFFFFFFFFFFFF;
		const std::uint8_t SI_RecordState_Complete = 0;
		const std::uint8_t SI_RecordState_Incomplete = 1;
		const std::uint16_t SI_StartRecordIndicator = 43981;

		struct SessionIndexRec {
			SessionIndexRec()
				: startIndicator(SI_StartRecordIndicator)
				, sessionFileRecordState(SI_RecordState_Incomplete) //default to incomplete file status
				, startTimestamp(SI_InvalidTimestamp)
				, endTimestamp(SI_InvalidTimestamp)
				, normalizedTimestamp(0) //default no offset
				, crc(0)
			{
				memset(filePath, 0, sizeof(filePath));
				memset(fileUUID, 0, sizeof(fileUUID));
				memset(fileHash, 0, sizeof(fileHash));
			}

			std::uint16_t	startIndicator;
			char			filePath[SI_FilePathLength];
			std::uint8_t	fileUUID[SI_UUIDLength];
			std::uint8_t	sessionFileRecordState;
			std::uint8_t	fileHash[SI_UUIDLength];
			std::uint64_t	startTimestamp;
			std::uint64_t	endTimestamp;
			std::uint64_t	normalizedTimestamp;
			std::uint32_t	crc;

		};

#pragma endregion

#pragma region Subject Data

		////////////
		// Subject File
		////////////

		//values found in public spec doc for Subject File v1.0.0
		const std::uint8_t SUBJECT_RecordType_Comment = 0;
		const std::uint8_t SUBJECT_RecordType_Session = 1;
		const int SUBJECT_FilePathLength = 8000;
		const int SUBJECT_UUIDLength = 16;
		const std::uint16_t SUBJECT_StartRecordIndicator = 43981;
		const size_t SUBJECT_RecordCommentDefaultBytes = 23;  //does not include comment field
		const size_t SUBJECT_RecordSessionLengthBytes = 8023;


		struct SubjectRec {
			SubjectRec()
				: startIndicator(SUBJECT_StartRecordIndicator)
				, recordType(0)
				, crc(0)
			{ }

			std::uint16_t			startIndicator;
			std::uint8_t			recordType;
			std::uint32_t			crc;
		};

		struct SubjectRec_Comment : public SubjectRec {
			SubjectRec_Comment()
				: SubjectRec()
				, timestamp(0)
				, commentLength(0)
				, comment(nullptr)
			{
				this->recordType = SUBJECT_RecordType_Comment;
			}

			SubjectRec_Comment(const SubjectRec_Comment &rhs)
				: SubjectRec()
				, timestamp(rhs.timestamp)
				, commentLength(rhs.commentLength)
				, comment(new char[static_cast<size_t>(rhs.commentLength)])
			{
				memcpy( this->comment, rhs.comment, static_cast<size_t>(rhs.commentLength));
			}
#ifndef USE_CPP_98
			SubjectRec_Comment(SubjectRec_Comment &&rhs)
				: SubjectRec()
				, timestamp(rhs.timestamp)
				, commentLength(rhs.commentLength)
				, comment(rhs.comment)
			{
				rhs.comment = nullptr;
			}
#endif
			~SubjectRec_Comment()
			{
				if( comment != nullptr ) {
					delete[] comment;
				}
			}

			SubjectRec_Comment& operator=(const SubjectRec_Comment &rhs)
			{
				timestamp = rhs.timestamp;
				commentLength = rhs.commentLength;

				if( comment != nullptr ) {
					delete[] comment;
				}
				comment = new char[static_cast<size_t>(rhs.commentLength)];
				memcpy( this->comment, rhs.comment, static_cast<size_t>(rhs.commentLength));

				return *this;
			}

			void InitComment(std::uint64_t inCommentLength)
			{
				commentLength = inCommentLength;
				if( comment != nullptr ) {
					delete[] comment;
				}
				comment = new char[static_cast<size_t>(commentLength)];
			}

			std::uint64_t			timestamp;
			std::uint64_t			commentLength;
			char*					comment;
		};

		struct SubjectRec_Session : public SubjectRec {
			SubjectRec_Session()
				: SubjectRec()
			{
				memset(filePath, L'\0', sizeof(filePath));
				memset(fileUUID, 0, sizeof(fileUUID));
				this->recordType = SUBJECT_RecordType_Session;
			}

			char					filePath[SUBJECT_FilePathLength];
			std::uint8_t			fileUUID[SUBJECT_UUIDLength];
		};
	namespace {

		void SubjectRecordToData(const SubjectRec_Comment* inRecord, std::vector<std::uint8_t>& outData)
		{
			size_t dataLength = SUBJECT_RecordCommentDefaultBytes + static_cast<size_t>(inRecord->commentLength) - sizeof(inRecord->crc);
			outData.resize(dataLength);
			std::vector<std::uint8_t>::iterator nextPos	= std::copy((char*)(&inRecord->startIndicator),
																	(char*)(&inRecord->startIndicator) + sizeof(inRecord->startIndicator),
																	std::begin(outData));
			nextPos = std::copy((char*)(&inRecord->recordType), (char*)(&inRecord->recordType) + sizeof(inRecord->recordType), nextPos);
			nextPos = std::copy((char*)(&inRecord->timestamp), (char*)(&inRecord->timestamp) + sizeof(inRecord->timestamp), nextPos);
			nextPos = std::copy((char*)(&inRecord->commentLength), (char*)(&inRecord->commentLength) + sizeof(inRecord->commentLength), nextPos);
			nextPos = std::copy((char*)(inRecord->comment), (char*)(inRecord->comment) + inRecord->commentLength, nextPos);
		}

		void SubjectRecordToData(const SubjectRec_Session* inRecord, std::vector<std::uint8_t>& outData)
		{

			size_t dataLength = SUBJECT_RecordSessionLengthBytes - sizeof(inRecord->crc);
			outData.resize(dataLength);
			std::vector<std::uint8_t>::iterator	nextPos	= std::copy((char*)(&inRecord->startIndicator),
																	(char*)(&inRecord->startIndicator) + sizeof(inRecord->startIndicator),
																	std::begin(outData));
			nextPos = std::copy((char*)(&inRecord->recordType), (char*)(&inRecord->recordType) + sizeof(inRecord->recordType), nextPos);
			nextPos = std::copy((char*)(&inRecord->filePath), (char*)(&inRecord->filePath) + sizeof(inRecord->filePath), nextPos);
			nextPos = std::copy((char*)(&inRecord->fileUUID), (char*)(&inRecord->fileUUID) + sizeof(inRecord->fileUUID), nextPos);
		} 
	}
#pragma endregion	

#pragma region Persyst types

//Persyst information below is defined in the "Persyst Lay-Dat Format.pdf" document
const size_t Persyst_FilePathLength = 8000;
const size_t Persyst_FileTypeLength = 11;
const size_t Persyst_NameLength = 80;
const size_t Persyst_DateLength = 10;
const size_t Persyst_TimeLength = 12;
const size_t Persyst_InfoLength = 200;
const size_t Persyst_CommentLength = 1023;

struct PersystChannel {
	PersystChannel()
	:	channelName(nullptr)
	,	channelNameLength(0)
	,	channelReference(0)
	{}

	PersystChannel(std::string& name, int reference)
	:	channelName(nullptr)
	,	channelNameLength(0)
	,	channelReference(0)
	{
		channelNameLength = name.length();
		channelName = new char[channelNameLength];
		memcpy(channelName,	name.c_str(), channelNameLength);
		channelReference = reference;
	}

	PersystChannel(PersystChannel& channel)
	:	channelName(nullptr)
	,	channelNameLength(0)
	,	channelReference(0)
	{
		channelNameLength = channel.channelNameLength;
		channelName = new char[channelNameLength];
		memcpy(channelName,	channel.channelName, channelNameLength);
		channelReference = channel.channelReference;
	}
#ifndef USE_CPP_98
	PersystChannel(PersystChannel&& channel)
	:	channelName(channel.channelName)
	,	channelNameLength(channel.channelNameLength)
	,	channelReference(channel.channelReference)
	{
		channel.channelName = nullptr;
		channel.channelNameLength = 0;
		channel.channelReference = 0;
	}
#endif
	~PersystChannel()
	{
		if( channelName != nullptr ) {
			delete[] channelName;
		}
	}

	char*		channelName;
	size_t		channelNameLength;
	int			channelReference;
};

struct PersystSampleTime {
	PersystSampleTime()
	{}

	PersystSampleTime(int index, double timeInSeconds) {
		sampleIndex = index;
		sampleTime = timeInSeconds;
	}

	int		sampleIndex;
	double	sampleTime;
};

struct PersystComment {
	PersystComment()
	{
		memset(commentText, '\0', sizeof(commentText));
	}

	PersystComment(double inTime, double inDuration, std::string& inComment) {
		time = inTime;
		duration = inDuration;
		size_t commentLength = inComment.length();
		if( commentLength > Persyst_CommentLength ) {
			commentLength = Persyst_CommentLength;
		}
		memset(commentText, '\0', sizeof(commentText));
		memcpy(&commentText, inComment.data(), commentLength);
	}
	double		time;
	double		duration;
	int			unused; //always 0
	int			commentColor; //always 100
	char		commentText[Persyst_CommentLength];
};

struct PersystLayRec {
	PersystLayRec()
	:	samplingRate(0)
	,	headerLength(0)
	,	calibration(0)
	,	waveformCount(0)
	,	dataType(0)
	,	channelMap(nullptr)
	,	numChannels(0)
	,	sampleTimes(nullptr)
	,	numSampleTimes(0)
	,	middleInitial('\0')
	,	sex('\0')
	,	hand('\0')
	,	comments(nullptr)
	,	numComments(0)
	{
		memset(filePath, '\0', sizeof(filePath));
		memcpy(fileType, "Interleaved", Persyst_FileTypeLength);
		memset(firstName, '\0', sizeof(firstName));
		memset(lastName, '\0', sizeof(lastName));
		memset(birthDate, '\0', sizeof(birthDate));
		memset(ID, '\0', sizeof(ID));
		memset(testDate, '\0', sizeof(testDate));
		memset(testTime, '\0', sizeof(testTime));
		memset(physician, '\0', sizeof(physician));
		memset(technician, '\0', sizeof(technician));
		memset(medications, '\0', sizeof(medications));
		memset(history, '\0', sizeof(history));
		memset(comments1, '\0', sizeof(comments1));
		memset(comments2, '\0', sizeof(comments2));
	}

	// [FileInfo]
	char			filePath[Persyst_FilePathLength];
	char			fileType[Persyst_FileTypeLength];
	int				samplingRate;
	int				headerLength;
	double			calibration;
	int				waveformCount;
	int				dataType;

	// [ChannelMap]
	PersystChannel*	channelMap;
	unsigned int	numChannels;

	// [SampleTimes]
	PersystSampleTime*	sampleTimes;
	unsigned int		numSampleTimes;

	// [Patient]
	char			firstName[Persyst_NameLength];
	char			middleInitial;
	char			lastName[Persyst_NameLength];
	char			sex;
	char			hand;
	char			birthDate[Persyst_DateLength]; //format: MM/DD/YYYY
	char			ID[Persyst_InfoLength];
	char			testDate[Persyst_DateLength];
	char			testTime[Persyst_TimeLength]; //format: HH:MM:SS.MMM
	char			physician[Persyst_NameLength];
	char			technician[Persyst_NameLength];
	char			medications[Persyst_InfoLength];
	char			history[Persyst_InfoLength];
	char			comments1[Persyst_InfoLength];
	char			comments2[Persyst_InfoLength];

	// [Comments]
	PersystComment* comments;
	unsigned int	numComments;

};

struct PersystDatRec {
	__int16 *		data;
	unsigned int	numBytes;
};

#pragma endregion

	
}
//cleanup preprocessor
#ifdef VS2010_VER
#undef VS2010_VER
#endif
#ifdef VS2003_VER
#undef VS3003_VER
#endif
#ifdef USE_CPP_98
#undef USE_CPP_98
#pragma warning(pop) //pop the disabling of compiler warnings
#endif
#pragma pack(pop, before_nlx_datatypes) // back to old packing scheme (pops everything pushed on the
//stack after this symbol was pushed)
