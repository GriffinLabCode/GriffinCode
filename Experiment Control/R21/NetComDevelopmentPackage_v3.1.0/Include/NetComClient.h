//********************************************************************************************************************
//  File Name: NetComClient.h
//  Copyright 1998..2014 @ Neuralynx, Inc.
//********************************************************************************************************************

/** \file NetComClient.h
* NetCom Client C++ API
*/

#pragma once
#include <vector>
#include <string>


//These forward declares allow us to only distribute this
//header file, instead of the entire header tree.  The
//necessary header files are included in the cpp file
class NetworkNodeClient;
namespace NlxDataTypes {
	struct SERec;
	struct STRec;
	struct TTRec;
	struct CRRec;
	struct EventRec;
	struct VideoRec;
}

#define DllExport __declspec(dllexport)

/// \summary Namespace for Neuralynx NetCom C++ interface
namespace NlxNetCom {

	/** NetCom Client C++ API */
	class NetComClient
	{
	public:
		/** Constructor for the NetComClient class. Creates a new instance of this class, and initializes variables. No actions are performed after this class is created. It is recommended that each application only have a single instance of a NetComClient. */
		DllExport NetComClient(void);
		/** Destructor for the NetComClient class. Deletes the instance of this class. */
		DllExport virtual ~NetComClient(void);

		/** Attempt to make a network connection with the Server
		* \param [in]	serverName	Either the network name (i.e. "DataAcqSysPC") or a string representing the IP address (i.e. "192.168.1.100" ) of the PC running a NetCom server.
		* \param [in]	attemptRouterConnection		(Default = true) An optional argument that tells the NetComClient to attempt to connect to the Router application prior to attempting a direct connection to the DAS. The DAS only supports a single NetComClient connection, so using the Router is advisable if multiple applications need data from the DAS. This argument defaults to True if not specified. For most applications this value should always be True.
		* \return		Returns True if the connection to serverName was successful. Returns False on a failed connection attempt. If this function is called while currently connected to a NetCom server, it will return False and not close the current connection.
		*/
		DllExport bool ConnectToServer(const wchar_t* const serverName, bool attemptRouterConnection = true);
		/** Disconnects this client to a NetCom server application.
		* \return  Returns True if the disconnection from the currently connected server was successful. Returns False on a failed disconnection attempt. On a failed disconnect, the state of the NetCom client is undetermined. It is advisable that a new NetComClient object be created. If this function is called while not connected to a NetCom server, it will return False.
		*/
		DllExport bool DisconnectFromServer();
		/** Retrieves the version of the client being used.
		* \return  The version of the NetCom client being used.
		*/
		DllExport std::wstring GetClientVersionString()
		{
			std::wstring clientVersionString(L"");
			wchar_t* pClientVersionString = NULL;

			GetClientVersionStringInternal(pClientVersionString);

			clientVersionString = pClientVersionString;

			FreeArray(pClientVersionString);

			return clientVersionString;
		}
		/** Opens a record stream between this client and a NetCom server. Opening a stream will cause the defined callback function corresponding to the object type of objectName to be called after receiving a record for the specified object name.
		* \param [in]	DASObjectName	The name of the object to stream data from. This name is specified in the DAS setup files. A listing of defined object names can be obtained from the GetDASObjectsAndTypes function.
		* \return  Returns True if the the specified object name and type were found in the DAS's object list, and a stream was successfully opened. Returns False on any of the following conditions:
		*	-# The object name specified was not found in the DAS's object list.
		*	-# A network or other error prevented the stream from opening.
		*	.
		*	If this function is called while not connected to a NetCom server, it will return False and the stream will need to be reopened after a connection is established. If this function is called successfully multiple times using the same arguments, it must be closed the same number of times to halt record callbacks. Calling DisconnectFromServer automatically closes all opened streams.
		*/
		DllExport bool OpenStream(const wchar_t* const DASObjectName);
		/** Closes a record stream between this client and a NetCom server. Closing a stream will cause the DAS to cease sending records for the specified object. The callback function will continue to be called until all records for this object, received before calling CloseStream, have been processed.
		* \param [in]	DASObjectName	The name of the object whose stream should be closed. This name is specified in the DAS setup files. A listing of defined object names can be obtained from the GetDASObjectsAndTypes function.
		* \return  Returns True if the the specified object name and type were found in the DAS's object list, and a stream was successfully closed. Returns false on any of the following conditions:
		*	-# The object name specified was not found in the DAS's object list.
		*	-# A stream for this object name and type has not yet been opened.
		*	-# A network or other error prevented the stream from opening.
		*	.
		*	If this function is called while not connected to a NetCom server, it will return False. If OpenStream is called successfully multiple times using the same arguments, it must be closed the same number of times to halt record callbacks. Calling DisconnectFromServer automatically closes all opened streams.
		*/
		DllExport bool CloseStream(const wchar_t* const DASObjectName);
		/** Sends a command to the NetCom server.
		* \param [in]	command		An ASCII command string to send to the server.
		* \param [out]	reply		Returned messaged from the server.
		* \param [out]	numBytesReturned	The number of bytes in the returned message.
		* \return	Returns true if the command was sent successfully and a reply was received, otherwise false.
		*/
		DllExport bool SendCommand(const wchar_t* const command, char*& reply, int& numBytesReturned);
		
		/** Sets the callback function for relaying logged NetCom status messages.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when a message is logged.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionMessage( void (*myFunctionPtr)(void* myClassPtr, int messageType, wchar_t* message), void* myClassPtr);
		/** Sets the callback function for notifying the user that a connection loss was detected.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when a connection loss is detected.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionConnectionLost( void (*myFunctionPtr)(void* myClassPtr), void* myClassPtr);

		/** Sets the callback function for single electrode records.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when any \ref NlxDataTypes::SERec "SERec" record is received by this client. This function will be called as long as any single electrode object has an open stream. This function ceases to be called when all single electrode streams have been closed.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionSE( void (*myFunctionPtr)(void* myClassPtr, NlxDataTypes::SERec* records, int numRecords, const wchar_t* const objectName), void* myClassPtr);
		/** Sets the callback function for stereotrode records.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when any \ref NlxDataTypes::STRec "STRec" record is received by this client. This function will be called as long as any stereotrode object has an open stream. This function ceases to be called when all stereotrode streams have been closed.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionST( void (*myFunctionPtr)(void* myClassPtr, NlxDataTypes::STRec* records, int numRecords, const wchar_t* const objectName), void* myClassPtr);
		/** Sets the callback function for tetrode records.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when any \ref NlxDataTypes::TTRec "TTRec" record is received by this client. This function will be called as long as any tetrode object has an open stream. This function ceases to be called when all tetrode streams have been closed.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionTT( void (*myFunctionPtr)(void* myClassPtr, NlxDataTypes::TTRec* records, int numRecords, const wchar_t* const objectName), void* myClassPtr);
		/** Sets the callback function for continuously sampled records.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when any \ref NlxDataTypes::CRRec "CRRec" record is received by this client. This function will be called as long as any continuously sampled object has an open stream. This function ceases to be called when all continuously sampled streams have been closed.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionCSC( void (*myFunctionPtr)(void* myClassPtr,NlxDataTypes::CRRec* records, int numRecords, const wchar_t objectName []), void* myClassPtr);
		/** Sets the callback function for event records.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when any \ref NlxDataTypes::EventRec "EventRec" record is received by this client. This function will be called as long as any event object has an open stream. This function ceases to be called when all event streams have been closed.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionEV( void (*myFunctionPtr)(void* myClassPtr, NlxDataTypes::EventRec* records, int numRecords, const wchar_t* const objectName), void* myClassPtr);
		/** Sets the callback function for video tracker records.
		* \param [in]	myFunctionPtr	A delegate to the function that will be called when any \ref NlxDataTypes::VideoRec "VideoRec" record is received by this client. This function will be called as long as any video tracker object has an open stream. This function ceases to be called when all video tracker streams have been closed.
		* \param [in]	myClassPtr		The object that will be referenced within the call back function.
		*/
		DllExport void SetCallbackFunctionVT( void (*myFunctionPtr)(void* myClassPtr, NlxDataTypes::VideoRec* records, int numRecords, const wchar_t* const objectName), void* myClassPtr);
		//setter functions
		/** Sets a name to identify your application to the NetCom server. The server application will use this name to show information about the connection to your application.
		* \param [in]	myApplicationName	This name is used to identify all traffic on this connection NetCom server logs. This name is also displayed in the Router's connection list or in the DAS's NetCom connection display.
		* \return	Returns True if the application name was set in the server's connection list. Returns false on a failed attempt to update the server's connection list. If this function is called while not connected to a NetCom server, it will return False and the application name will need to be reset after a connection is established.
		*/
		DllExport bool SetApplicationName(const wchar_t* const myApplicationName);
		/** Sets the logfile name for this client. If this command is not called, no logfile will be created.
		* \param [in]	filename	The completely qualified file name for the logfile. All NetCom communications will be logged to fileName.
		* \return	 Returns True if this successfully sets the logfile name and opens the logfile. Returns false if the logfile could not be opened. This function can be called while not connected to a NetCom server.
		*/
		DllExport bool SetLogFileName(const wchar_t* const filename);

		//getter functions
		/** Gets the ring buffer size and record count for a specified DAS object.
		* \param [in]	objectName	The name of the DAS object.
		* \param [out]	numRecords	The number of records found in the ring buffer for the DAS object.
		* \param [out]	recordSize	The size of each record found in the ring buffer for the DAS object.
		* \return	 Returns True if this successfully gets the number of records and record size. Returns false if a ring buffer for the DAS object was not found.
		*/
		DllExport bool GetRingBufferSize(const wchar_t* const objectName, int& numRecords, int& recordSize);
		/** Gets the data from a ring buffer of a specified DAS object.
		* \param [in]	objectName	The name of the DAS object.
		* \param [out]	dataBuffer	The data array containing records.
		* \param [in]	numBytes	The number of bytes available in the dataBuffer.
		* \param [out]	numBytesReturned	The number of bytes containing records in the dataBuffer.
		* \return	 Returns True if this successfully gets the records for the DAS object. Returns false if unable to retrieve data from the ring buffer.
		*/
		DllExport bool GetRingBufferData(const wchar_t* const objectName, char* dataBuffer, int numBytes, int& numBytesReturned);

		//getter status functions
		/** Gets the current connection state of the client.
		* \return The name of application that this client is connected to. If the client is not connected, the return value is "Not Connected"
		*/
		DllExport bool AreWeConnected();

		//C++ STL wrappers for C API functions
		//This saves having to worry about memory management and the DLL
		//boundary in an application linking against this library.
		//Since STL/CRT objects cannot pass the DLL boundary (the STL/CRT	
		//versions may differ), these functions must be implemented in
		//the header so that the application that links to this library
		//compiles them using its version of the STL/CRT.

		//*******************************************************************
		/** Retrieves all objects defined in the DAS's object list, along with their corresponding types.
		* \param [out]	DASObjects	This ArrayList will be filled with String objects for each object in the DAS's object list. This argument will be modified during this function's execution, and its contents should not be considered valid if this function call fails.
		* \param [out]	DASTypes	This ArrayList will be filled with String objects for each object's type in the DAS's object list.  The type specified will have a one-to-one mapping with the DASObjectList (i.e. DASObjectList.Item(1) will be of type DASTypesList.Item(1) ).  This argument will be modified during this function's execution, and its contents should not be considered valid if this function call fails.
		*	\n\n The following is a listing of the type strings corresponding to each data type:\n\n
		*	<table>
		*	<tr><th>NetCom Type String</th><th>NetCom Data Type</th></tr>
		*	<tr><td>\ref NlxDataTypes::NetComSEDataType "SEScAcqEnt"</td><td>\ref NlxDataTypes::NlxDataType::SingleElectrode "SingleElectrode"</td></tr>
		*	<tr><td>\ref NlxDataTypes::NetComSTDataType "STScAcqEnt"</td><td>\ref NlxDataTypes::NlxDataType::Stereotrode "Stereotrode"</td></tr>
		*	<tr><td>\ref NlxDataTypes::NetComTTDataType "TTScAcqEnt"</td><td>\ref NlxDataTypes::NlxDataType::Tetrode "Tetrode"</td></tr>
		*	<tr><td>\ref NlxDataTypes::NetComCSCDataType "CscAcqEnt"</td><td>\ref NlxDataTypes::NlxDataType::CSC "CSC"</td></tr>
		*	<tr><td>\ref NlxDataTypes::NetComEventDataType "EventAcqEnt"</td><td>\ref NlxDataTypes::NlxDataType::Event "Event"</td></tr>
		*	<tr><td>\ref NlxDataTypes::NetComVTDataType "VTAcqEnt"</td><td>\ref NlxDataTypes::NlxDataType::VideoTracker "VideoTracker"</td></tr>
		*	</table>
		* \return		Returns True if this client successfully received all of the DAS's object list. Returns False on a failed attempt to receive the DAS's object list. If this function is called while not connected to a NetCom server, it will return False and the object and types lists will need to be refreshed after a connection is established.
		*/
		bool GetDASObjectsAndTypes(std::vector<std::wstring>& DASObjects, std::vector<std::wstring>& DASTypes)
		{
			DASObjects.clear();
			DASTypes.clear();

			wchar_t** pDASObjects = NULL;
			wchar_t** pDASTypes = NULL;
			int numObjectsReturned = -1;

			if(GetDASObjectsAndTypesInternal(pDASObjects, pDASTypes, numObjectsReturned)) {
				for(int i = 0; i < numObjectsReturned; ++i) {
					DASObjects.push_back(std::wstring(pDASObjects[i]));
					FreeArray((void*)(pDASObjects[i]));
					DASTypes.push_back(std::wstring(pDASTypes[i]));
					FreeArray((void*)(pDASTypes[i]));
				}

				FreeArray(pDASObjects);
				FreeArray(pDASTypes);
				return true;
			} else {
				return false;
			}
		}

		//*******************************************************************
		/** Sends a generic command to the DAS for processing. This is a synchronous command that will wait until the NetCom server sends a response before returning. For a complete list of DAS commands, see the Commands section of the DAS Reference Guide (available under the Help menu in the DAS).
		* \param [in]	command		The formatted command string that the DAS is to process. Command strings are identical to configuration file commands.
		* \param [out]	reply		The reply received from the NetCom server will be stored in this argument. This argument will be modified during this function's execution, and its contents should not be considered valid if this function call fails.
		* \return		Returns True if this successfully sends a command and receives a response to/from a NetCom server. Returns false on a failed attempt to send a command, or receive a response from a NetCom server.  If this function is called while not connected to a NetCom server, it will return False and the command will be discarded.
		*/
		bool SendCommand(const wchar_t command [], std::wstring& reply)
		{
			wchar_t* pReply = NULL;
			reply = L"";

			if(SendCommandInternal(command, pReply) == true) {
				reply = pReply;
				FreeArray(pReply);
				return true;
			} else {
				return false;
			}
		}

		//*****************************************************************************
		/** Sends a generic command to the DAS for processing. This is a synchronous command that will wait until the NetCom server sends a response before returning. For a complete list of DAS commands, see the Commands section of the DAS Reference Guide (available under the Help menu in the DAS).
		* \param [in]	command				The formatted command string that the DAS is to process. Command strings are identical to configuration file commands.
		* \param [out]	commandSucceeded	Value indicating success (0) or failure (-1).
		* \param [out]	replyValues			The reply received from the NetCom server will be stored in this argument. This argument will be modified during this function's execution, and its contents should not be considered valid if this function call fails.
		* \return		Returns True if this successfully sends a command and receives a response to/from a NetCom server. Returns false on a failed attempt to send a command, or receive a response from a NetCom server.  If this function is called while not connected to a NetCom server, it will return False and the command will be discarded.
		*/
		bool SendCommand (const wchar_t* const command, int& commandSucceeded, std::vector<std::wstring>& replyValues)
		{
			wchar_t** pReply = NULL;
			int numReplyStringsReturned = 0;
			commandSucceeded = -1;
			replyValues.clear();

			if(SendCommandInternal(command, commandSucceeded, pReply, numReplyStringsReturned)) {
				for(int i = 0; i < numReplyStringsReturned; ++i) {
					replyValues.push_back(std::wstring(pReply[i]));
					FreeArray((void*)(pReply[i]));
				}

				FreeArray(pReply);
				return true;
			} else {
				return false;
			}

		}

		//*******************************************************************
		/** Retrieves the name of the PC running the NetCom server that this client is connected to.
		* \return The name of the PC running the NetCom server that this client is connected to. If the client is not connected, the return value is "Not Connected"
		*/
		std::wstring GetServerPCName(void)
		{
			std::wstring pcName(L"");
			wchar_t* pPCName = NULL;

			GetServerPCNameInternal(pPCName);

			pcName = pPCName;

			FreeArray(pPCName);

			return pcName;
		}

		//*******************************************************************
		/** Retrieves the IP address of the PC running the NetCom server that this client is connected to.
		* \return The IP of the PC running the NetCom server that this client is connected to. If the client is not connected, the return value is "0.0.0.0"
		*/
		std::wstring GetServerIPAddress(void)
		{
			std::wstring ipAddress(L"");
			wchar_t* pIPAddress = NULL;

			GetServerIPAddressInternal(pIPAddress);

			ipAddress = pIPAddress;

			FreeArray(pIPAddress);

			return ipAddress;
		}

		//*******************************************************************
		/** Retrieves the name of the application that this client is connected to.
		* \return  The version of the NetCom client being used.
		*/
		std::wstring GetServerApplicationName(void)
		{
			std::wstring appName(L"");
			wchar_t* pAppName = NULL;

			GetServerApplicationNameInternal(pAppName);

			appName = pAppName;

			FreeArray(pAppName);

			return appName;
		}

	private:

		bool SetComputerNameOnServer();

		//C API general functions
		__declspec(dllexport) void GetClientVersionStringInternal(wchar_t*& clientVersionString);

		//C API DAS AE functions
		__declspec(dllexport) bool GetDASObjectsAndTypesInternal(wchar_t**& DASObjects, wchar_t**& DASTypes, int& numObjectsReturned);

		//C Command functions
		__declspec(dllexport) bool SendCommandInternal(const wchar_t command [], wchar_t*& reply);
		__declspec(dllexport) bool SendCommandInternal(const wchar_t* const command, int& commandSucceeded, wchar_t**& pReplyStrings, int& numReplyStringsReturned);

		//C API server information functions
		__declspec(dllexport) void GetServerApplicationNameInternal(wchar_t*& appName);
		__declspec(dllexport) void GetServerPCNameInternal(wchar_t*& pcName);
		__declspec(dllexport) void GetServerIPAddressInternal(wchar_t*& ipAddress);

		//C API helper functions
		__declspec(dllexport) void FreeArray(void* arrayPtr);


		NetworkNodeClient* mNetworkConnection; //implementation object
		std::wstring mPrevServerIPAddress;
	};

	//NetComClient factory methods so that we can allocate and deallocate
	//pointers to NetComClient objects on the DLL's heap. If a NetComClient*
	//is newed in some application, the memory for the NetComClient is in
	//the heap of that other application. However, anything newed by NetComClient
	//is in the heap of this DLL. So when ~NetComClient is called from the other
	//application, we get a heap corruption because we can't delete things in
	//this DLL's heap from the other application.
	//TODO: it might be a good idea to make the NetComClient class a factory with
	//private constructor.
	__declspec(dllexport) NetComClient* GetNewNetComClient(void);
	__declspec(dllexport) void DeleteNetComClient(NetComClient*);
}