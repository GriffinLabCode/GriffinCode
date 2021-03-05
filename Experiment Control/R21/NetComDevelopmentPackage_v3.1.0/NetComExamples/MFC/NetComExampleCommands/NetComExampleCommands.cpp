//**********************************************
//	NetComExampleCommands.cpp
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#include "stdafx.h"
#include "NetComExampleCommands.h"
#include "NetComExampleCommandsDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
BEGIN_MESSAGE_MAP(NetComExampleCommandsApp, CWinApp)
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
NetComExampleCommandsApp::NetComExampleCommandsApp()
{
}

// The one and only NetComExampleCommandsApp object
NetComExampleCommandsApp theApp;

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
BOOL NetComExampleCommandsApp::InitInstance()
{
	CWinApp::InitInstance();
	SetRegistryKey(_T("NetComExampleCommands"));

	NetComExampleCommandsDlg dlg;
	m_pMainWnd = &dlg;
	INT_PTR nResponse = dlg.DoModal();
	if (nResponse == IDOK)	{
		// TODO: Place code here to handle when the dialog is
		//  dismissed with OK
	} else if (nResponse == IDCANCEL) {
		// TODO: Place code here to handle when the dialog is
		//  dismissed with Cancel
	}
	return FALSE;
}
