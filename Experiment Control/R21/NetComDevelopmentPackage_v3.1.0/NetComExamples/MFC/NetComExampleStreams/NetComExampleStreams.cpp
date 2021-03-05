//**********************************************
//	NetComExampleStreams.cpp
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#include "stdafx.h"
#include "NetComExampleStreams.h"
#include "NetComExampleStreamsDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
BEGIN_MESSAGE_MAP(NetComExampleStreamsApp, CWinApp)
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
NetComExampleStreamsApp::NetComExampleStreamsApp()
{
}

// The one and only NetComExampleStreamsApp object
NetComExampleStreamsApp theApp;

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
BOOL NetComExampleStreamsApp::InitInstance()
{
	CWinApp::InitInstance();
	SetRegistryKey(_T("NetComExampleStreams"));

	NetComExampleStreamsDlg dlg;
	m_pMainWnd = &dlg;
	INT_PTR nResponse = dlg.DoModal();
	if (nResponse == IDOK)	{
		// TODO: Place code here to handle when the dialog is
		//  dismissed with OK
	} else if (nResponse == IDCANCEL) {
		// TODO: Place code here to handle when the dialog is
		//  dismissed with Cancel
	}

	// Since the dialog has been closed, return FALSE so that we exit the
	//  application, rather than start the application's message pump.
	return FALSE;
}
