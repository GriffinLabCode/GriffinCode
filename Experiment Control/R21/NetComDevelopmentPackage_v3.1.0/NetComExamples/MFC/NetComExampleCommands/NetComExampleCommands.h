//**********************************************
//	NetComExampleCommands.h
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

class NetComExampleCommandsApp : public CWinApp
{
public:
	NetComExampleCommandsApp();
	virtual BOOL InitInstance();
	DECLARE_MESSAGE_MAP()
};

extern NetComExampleCommandsApp theApp;