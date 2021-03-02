//**********************************************
//	NetComExampleCommandsDlg.cpp
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#include "stdafx.h"
#include "NetComExampleCommands.h"
#include "NetComExampleCommandsDlg.h"
#include ".\netcomexamplecommandsdlg.h"
#include <string>
#include <sstream>

using namespace std;

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

NetComExampleCommandsDlg::NetComExampleCommandsDlg(CWnd* pParent /*=NULL*/)	: CDialog(NetComExampleCommandsDlg::IDD, pParent)
, mServerName(_T(""))
, mCommandString(_T(""))
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void NetComExampleCommandsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_SERVER_NAME, mServerName);
	DDX_Text(pDX, IDC_COMMAND_STRING, mCommandString);
}

BEGIN_MESSAGE_MAP(NetComExampleCommandsDlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_BN_CLICKED(IDC_CONNECT, OnBnClickedConnect)
	ON_BN_CLICKED(IDC_DISCONNECT, OnBnClickedDisconnect)
	ON_BN_CLICKED(IDC_SEND_COMMAND, OnBnClickedSendCommand)
END_MESSAGE_MAP()

BOOL NetComExampleCommandsDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	InitializeNetCom();

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void NetComExampleCommandsDlg::OnPaint() 
{
	if (IsIconic())	{
		CPaintDC dc(this); // device context for painting
		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);
		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;
		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	} else {
		CDialog::OnPaint();
	}
}


void NetComExampleCommandsDlg::InitializeNetCom()
{
	//create a logfile pathname for netcom to use
	CString logfilePathName = GetNetComLogPathName();
	//set the pathname in netcom
	if( !mNetComClient.SetLogFileName(logfilePathName.GetString()) ) {
		CWnd::MessageBox(_T("Call to set the log file name in NetCom failed"));
	}

	//get the name of our pc
	DWORD size = 128;
	wchar_t buffer[128];
	GetComputerName(buffer, &size);
	//set member variable for our gui with a default value
	mServerName = buffer;


	//For a full list of commands see the Commands section of the Reference Guide.
	//The guide is located under the Help menu in the DAS software.
	//This is just an initial command to get you started.
	this->mCommandString = _T("-PostEvent \"Test Event\" 0 0");


	//update that value to the gui
	UpdateData(FALSE);

	
	
}

CString NetComExampleCommandsDlg::GetNetComLogPathName()
{
	//get path to this executable
	wchar_t strPathName[_MAX_PATH];
	::GetModuleFileName(AfxGetInstanceHandle(), strPathName, _MAX_PATH);

	//remove exe name so we have dir only
	CString exePathName = strPathName;
	int index = exePathName.ReverseFind('\\');
	CString logPathName = exePathName.Left(index);

	//add the filename we want to the dir string
	logPathName += _T("\\NetCom Connect Example Log File.txt");

	return(logPathName);
}

void NetComExampleCommandsDlg::OnBnClickedConnect()
{
	UpdateData(TRUE);

	if( !mNetComClient.AreWeConnected() ) {
		if( mNetComClient.ConnectToServer(mServerName.GetString()) ) {
			mNetComClient.SetApplicationName(_T("NetCom Commands Example"));

			CWnd::MessageBox(_T("Connection to server was successful"));
		} else { 
			CWnd::MessageBox(_T("Connection to server failed"));
		}
	} else {
		CWnd::MessageBox(_T("Unable to connect to server, we have already established a connection"));
	}
}

void NetComExampleCommandsDlg::OnBnClickedDisconnect()
{
	UpdateData(TRUE);

	if( mNetComClient.AreWeConnected() ) {
		if( mNetComClient.DisconnectFromServer() ) {
			CWnd::MessageBox(_T("Disconnection from server was successful"));
		} else {
			CWnd::MessageBox(_T("Disconnection from server failed"));
		}
	} else {
		CWnd::MessageBox(_T("Unable to Disconnect from server, a connection has not yet been established"));
	}
}

void NetComExampleCommandsDlg::OnBnClickedSendCommand()
{
	UpdateData(TRUE);

	if( mNetComClient.AreWeConnected() ) {
		std::vector<std::wstring> replyValues;
		int retVal = -1;
		if(mNetComClient.SendCommand(mCommandString.GetString(), retVal, replyValues)) {
			
			if(retVal == -1) {
				CWnd::MessageBox(_T("Make sure you are sending a valid command to DAS.\r\n\r\nFor a full list of commands"
					"see the Commands section of the DAS Reference Guide. The guide is located under the Help menu in the DAS."),
					_T("Unable to Send Command"), MB_OK|MB_ICONERROR);
			}
			
			//copy the reply values into a single string for display
			std::wstringstream replyString(L"");
			replyString << retVal << L" ";
			for(size_t i = 0; i < replyValues.size(); ++i) {
				replyString << replyValues[i];
				if (i + 1 < replyValues.size()) {
					replyString << L" ";
				}
			}
			CWnd* replyDisplay = GetDlgItem(IDC_COMMAND_REPLY);
			if(replyDisplay != nullptr)
			{
				replyDisplay->SetWindowText(replyString.str().c_str());
			}

		}else {
			CWnd::MessageBox(_T("There was a problem sending the command to the DAS."), _T("Unable to Send Command"), MB_OK|MB_ICONERROR);
		}
	} else {
		CWnd::MessageBox(_T("This program is not connected to a server."), _T("Unable to Send Command"), MB_OK|MB_ICONERROR);
	}
	
	UpdateData(FALSE);
}