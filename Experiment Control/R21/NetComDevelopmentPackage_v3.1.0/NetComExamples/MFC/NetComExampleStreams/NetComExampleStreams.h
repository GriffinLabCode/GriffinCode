//**********************************************
//	NetComExampleStreams.h
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#pragma once

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

class NetComExampleStreamsApp : public CWinApp
{
public:
	NetComExampleStreamsApp();
	virtual BOOL InitInstance();
	DECLARE_MESSAGE_MAP()
};

extern NetComExampleStreamsApp theApp;