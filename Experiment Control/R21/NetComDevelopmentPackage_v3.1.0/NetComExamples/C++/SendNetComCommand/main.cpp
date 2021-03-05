//******************************************************************************************************************************************************************************************
// SendNetComCommand
//
// This is an example showing how to create a simple command line NetCom program that can
// send commands to and receive information from Cheetah. It is intended for instructional
// purposes only.
//
// Copyright 1998..2016 @ Neuralynx, Inc.
//******************************************************************************************************************************************************************************************
#include "..\..\..\Include\NetComClient.h"
#include <iostream>
#include <string>

//global variable declarations
NlxNetCom::NetComClient gNetComClient; //the one and only instance of the NetComClient
const std::wstring NETCOM_APP_ID(L"SendNetComCommand Example"); //id string displayed in Cheetah when connected

int wmain(int argc, const wchar_t* argv[]) {

	if(argc == 3) { //the first argv is always the exe name, and two additional arguments are required
		//the first argument after the exe is the host name
		const std::wstring hostName(argv[1]);
		//second argument after the exe is the command to send
		const std::wstring command(argv[2]);

		//first connect to the specified server
		if(gNetComClient.ConnectToServer(hostName.c_str())) {

			//identify this program to Cheetah
			gNetComClient.SetApplicationName(NETCOM_APP_ID.c_str());

			//now send the specified command and get Cheetah's reply
			std::wstring reply(L"");
			if(gNetComClient.SendCommand(command.c_str(), reply)) {
				//display the reply
				std::wcout << L"Reply: " << reply << std::endl;
				//disconnect from the server
				if(gNetComClient.DisconnectFromServer() == false) {
					std::wcout << L"Failed to disconnect from the host." << std::endl;
					return -1;
				}
			} else {
				std::wcout << L"Failed to send command \"" << command << L"\" to Cheetah" << std::endl;
				return -1;
			}
		} else {
			std::wcout << L"Failed to connect to the host " << hostName << std::endl;
			return -1;
		}
	} else {
		//no arguments or incorrect command line syntax shows help information
		std::wcout << L"Command syntax:" << std::endl
			<< L"SendNetComCommand host_name_or_ip \"cheetah command and arguments\"" << std::endl
			<< std::endl
			<< L"Example:" << std::endl
			<< L"SendNetComCommand localhost \"-PostEvent \\\"test event\\\" 11 12\"" << std::endl
			<< L"Connects to Cheetah running on localhost and posts an event." << std::endl
			<< std::endl
			<< L"NOTE: Any command argument that contains spaces must be surrounded by" << std::endl
			<< L"escaped quotes ( \\\" ) in order to be processed correctly." << std::endl;
	}
	return 0;
}