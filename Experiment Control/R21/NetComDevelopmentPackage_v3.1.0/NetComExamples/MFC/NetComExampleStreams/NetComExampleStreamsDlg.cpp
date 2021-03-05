//**********************************************
//	NetComExampleStreamsDlg.cpp
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#include "stdafx.h"
#include "NetComExampleStreams.h"
#include "NetComExampleStreamsDlg.h"
#include ".\netcomexamplestreamsdlg.h"

using NlxNetCom::NetComClient;
using NlxDataTypes::SERec;
using NlxDataTypes::STRec;
using NlxDataTypes::TTRec;
using NlxDataTypes::CRRec;
using NlxDataTypes::EventRec;
using NlxDataTypes::VideoRec;

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
NetComExampleStreamsDlg::NetComExampleStreamsDlg(CWnd* pParent /*=NULL*/) : CDialog(NetComExampleStreamsDlg::IDD, pParent)
, mServerName(_T(""))
, mDASObjectType(_T(""))
, mNumDASObjects(0)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
void NetComExampleStreamsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_SERVER_NAME, mServerName);
	DDX_Control(pDX, IDC_CHEETAH_OBJECTS_LIST, mDASObjectsListCtrl);
	DDX_Text(pDX, IDC_OBJECT_TYPE, mDASObjectType);
	DDX_Text(pDX, IDC_NUM_OBJECTS, mNumDASObjects);
	DDX_Control(pDX, IDC_RECORD_LOG_LIST, mRecordLogListCtrl);
}

//*********************************************************************************************************************************************************
//*********************************************************************************************************************************************************
BEGIN_MESSAGE_MAP(NetComExampleStreamsDlg, CDialog)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_BN_CLICKED(IDC_CONNECT, OnBnClickedConnect)
	ON_BN_CLICKED(IDC_DISCONNECT, OnBnClickedDisconnect)
	ON_BN_CLICKED(IDC_GET_CHEETAH_OBJECTS, OnBnClickedGetDASObjects)
	ON_BN_CLICKED(IDC_OPEN_STREAM, OnBnClickedOpenStream)
	ON_BN_CLICKED(IDC_CLOSE_STREAM, OnBnClickedCloseStream)
	ON_CBN_SELCHANGE(IDC_CHEETAH_OBJECTS_LIST, OnCbnSelchangeDASObjectsList)
	ON_BN_CLICKED(IDC_OPEN_ALL_STREAMS, OnBnClickedOpenAllStreams)
	ON_BN_CLICKED(IDC_CLOSE_ALL_STREAMS, OnBnClickedCloseAllStreams)
END_MESSAGE_MAP()

BOOL NetComExampleStreamsDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	InitializeNetCom();

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void NetComExampleStreamsDlg::OnPaint() 
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

void NetComExampleStreamsDlg::InitializeNetCom()
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
	//update that value to the gui
	UpdateData(FALSE);

	//set our callback function pointers inside of netcom so that netcom can pass the appropriate data record to the appropriate function
	mNetComClient.SetCallbackFunctionSE(NetComCallbackSE, this);
	mNetComClient.SetCallbackFunctionST(NetComCallbackST, this);
	mNetComClient.SetCallbackFunctionTT(NetComCallbackTT, this);
	mNetComClient.SetCallbackFunctionCSC(NetComCallbackCSC, this);
	mNetComClient.SetCallbackFunctionEV(NetComCallbackEV, this);
	mNetComClient.SetCallbackFunctionVT(NetComCallbackVT, this);
}

CString NetComExampleStreamsDlg::GetNetComLogPathName()
{
	//get path to this executable
	wchar_t strPathName[_MAX_PATH];
	::GetModuleFileName(AfxGetInstanceHandle(), strPathName, _MAX_PATH);

	//remove exe name so we have dir only
	CString exePathName = strPathName;
	int index = exePathName.ReverseFind('\\');
	CString logPathName = exePathName.Left(index);

	//add the filename we want to the dir string
	logPathName += _T("\\NetCom Streams Example Log File.txt");

	return(logPathName);
}

void NetComExampleStreamsDlg::OnBnClickedConnect()
{
	UpdateData(TRUE);

	if( !mNetComClient.AreWeConnected() ) {
		if( mNetComClient.ConnectToServer(mServerName.GetString()) ) {
			mNetComClient.SetApplicationName(_T("NetCom Stream Example"));
			CWnd::MessageBox(_T("Connection to server was successful"));
		} else { 
			CWnd::MessageBox(_T("Connection to server failed"));
		}
	} else {
		CWnd::MessageBox(_T("Unable to connect to server, we have already established a connection"));
	}
}

void NetComExampleStreamsDlg::OnBnClickedDisconnect()
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

void NetComExampleStreamsDlg::OnBnClickedGetDASObjects()
{
	UpdateData(TRUE);

	if( mNetComClient.AreWeConnected() ) {

		std::vector<std::wstring> dasObjects;
		std::vector<std::wstring> dasTypes;

		mDASObjects.clear();
		mDASTypes.clear();

		if(mNetComClient.GetDASObjectsAndTypes(dasObjects, dasTypes) ) {
			CWnd::MessageBox(_T("Retrieval of DAS objects and types from server was successful"));
			mNumDASObjects = static_cast<int>(mDASObjects.size());

			//Cheetah v5.7.0 and Pegasus v2.0.0 introduced the AcqSource object type. Since
			//data can not be streamed for that type, we will not add them to the list.
			for (size_t objectIndex = 0; objectIndex < dasTypes.size(); ++objectIndex) {
				if (dasTypes[objectIndex].compare(NlxDataTypes::NetComAcqSourceDataType) != 0) {
					mDASObjects.push_back(dasObjects[objectIndex]);
					mDASTypes.push_back(dasTypes[objectIndex]);
				}
			}
            UpdateDASObjectsList();	
		} else {
			CWnd::MessageBox(_T("Retrieval of DAS objects and types from server was NOT successful"));
		}

	} else {
		CWnd::MessageBox(_T("Unable to get DAS objects and types from server, a connection has not yet been established"));
	}

	UpdateData(FALSE);
}

void NetComExampleStreamsDlg::UpdateDASObjectsList()
{
	if( mDASObjects.empty()) { 
		return; 
	}

	mDASObjectsListCtrl.ResetContent();

	for (size_t objectIndex = 0; objectIndex < mDASObjects.size(); ++objectIndex) {
		mDASObjectsListCtrl.AddString(mDASObjects[objectIndex].c_str());
	}
	mDASObjectsListCtrl.SetCurSel(0);

	mDASObjectType = mDASTypes.front().c_str();
}

void NetComExampleStreamsDlg::OnCbnSelchangeDASObjectsList()
{
	UpdateData(TRUE);

	int curSel = mDASObjectsListCtrl.GetCurSel();

	mDASObjectType = mDASTypes[curSel].c_str();

	UpdateData(FALSE);
}

void NetComExampleStreamsDlg::OnBnClickedOpenStream()
{
	UpdateData(TRUE);

	if( mNetComClient.AreWeConnected() ) {

		int curSel = mDASObjectsListCtrl.GetCurSel();

		CString dasObject(_T(""));
		if(curSel == -1) {
			mDASObjectsListCtrl.GetWindowText(dasObject);
		} else {
			dasObject = mDASObjects[curSel].c_str();
		}


		if( mNetComClient.OpenStream(dasObject.GetString()) ) {
			CWnd::MessageBox(_T("Stream opened successfully"));
		} else {
			CWnd::MessageBox(_T("Stream failed to open"));
		}

	} else {
		CWnd::MessageBox(_T("Unable to get DAS objects and types from server, a connection has not yet been established"));
	}

	UpdateData(FALSE);
}

void NetComExampleStreamsDlg::OnBnClickedCloseStream()
{
	UpdateData(TRUE);

	if( mNetComClient.AreWeConnected() ) {

		int curSel = mDASObjectsListCtrl.GetCurSel();

		CString dasObject(_T(""));
		if(curSel == -1) {
			mDASObjectsListCtrl.GetWindowText(dasObject);
		} else {
			dasObject = mDASObjects[curSel].c_str();
		}

		mNetComClient.CloseStream(dasObject.GetString());

	} else {
		CWnd::MessageBox(_T("Unable to get DAS objects and types from server, a connection has not yet been established"));
	}

	UpdateData(FALSE);
}



/////////////////////////////////// CALLBACK FUNCTIONS FOR NETCOM ONLINE STREAM DATA  /////////////////////////////////// 

void NetComExampleStreamsDlg::NetComCallbackSE( void* myClass, SERec* records, int numRecords, const wchar_t objectName[] )
{
	NetComExampleStreamsDlg* thisClass = static_cast<NetComExampleStreamsDlg*>(myClass);
	CString message = _T("");
	message.Format(_T("Records Received: ObjectName: %s, NumRecords: %d"), objectName, numRecords);
	thisClass->mRecordLogListCtrl.AddString(message);
	thisClass->mRecordLogListCtrl.SetCaretIndex(thisClass->mRecordLogListCtrl.GetCount()-1);
}

void NetComExampleStreamsDlg::NetComCallbackST( void* myClass, STRec* records, int numRecords, const wchar_t objectName[] )
{
	NetComExampleStreamsDlg* thisClass = static_cast<NetComExampleStreamsDlg*>(myClass);
	CString message = _T("");
	message.Format(_T("Records Received: ObjectName: %s, NumRecords: %d"), objectName, numRecords);
	thisClass->mRecordLogListCtrl.AddString(message);
	thisClass->mRecordLogListCtrl.SetCaretIndex(thisClass->mRecordLogListCtrl.GetCount()-1);
}

void NetComExampleStreamsDlg::NetComCallbackTT( void* myClass, TTRec* records, int numRecords, const wchar_t objectName[] )
{
	NetComExampleStreamsDlg* thisClass = static_cast<NetComExampleStreamsDlg*>(myClass);
	CString message = _T("");
	message.Format(_T("Records Received: ObjectName: %s, NumRecords: %d"), objectName, numRecords);
	thisClass->mRecordLogListCtrl.AddString(message);
	thisClass->mRecordLogListCtrl.SetCaretIndex(thisClass->mRecordLogListCtrl.GetCount()-1);
}
	
void NetComExampleStreamsDlg::NetComCallbackCSC( void* myClass, CRRec* records, int numRecords, const wchar_t objectName[] )
{
	NetComExampleStreamsDlg* thisClass = static_cast<NetComExampleStreamsDlg*>(myClass);
	CString message = _T("");
	message.Format(_T("Records Received: ObjectName: %s, NumRecords: %d"), objectName, numRecords);
	thisClass->mRecordLogListCtrl.AddString(message);
	thisClass->mRecordLogListCtrl.SetCaretIndex(thisClass->mRecordLogListCtrl.GetCount()-1);
}

void NetComExampleStreamsDlg::NetComCallbackEV( void* myClass, EventRec* records, int numRecords, const wchar_t objectName[] )
{
	NetComExampleStreamsDlg* thisClass = static_cast<NetComExampleStreamsDlg*>(myClass);
	CString message = _T("");
	message.Format(_T("Records Received: ObjectName: %s, NumRecords: %d"), objectName, numRecords);
	thisClass->mRecordLogListCtrl.AddString(message);
	thisClass->mRecordLogListCtrl.SetCaretIndex(thisClass->mRecordLogListCtrl.GetCount()-1);
}

void NetComExampleStreamsDlg::NetComCallbackVT( void* myClass, VideoRec* records, int numRecords, const wchar_t objectName[] )
{
	NetComExampleStreamsDlg* thisClass = static_cast<NetComExampleStreamsDlg*>(myClass);
	CString message = _T("");
	message.Format(_T("Records Received: ObjectName: %s, NumRecords: %d"), objectName, numRecords);
	thisClass->mRecordLogListCtrl.AddString(message);
	thisClass->mRecordLogListCtrl.SetCaretIndex(thisClass->mRecordLogListCtrl.GetCount()-1);
}

void NetComExampleStreamsDlg::OnBnClickedOpenAllStreams()
{
	if( mNetComClient.AreWeConnected() ) {
		for( size_t objectIndex = 0; objectIndex < mDASObjects.size(); objectIndex++ ) {
			mNetComClient.OpenStream(mDASObjects[objectIndex].c_str());
		}
	} else {
		CWnd::MessageBox(_T("Unable to get DAS objects and types from server, a connection has not yet been established"));
	}

}

void NetComExampleStreamsDlg::OnBnClickedCloseAllStreams()
{
	if( mNetComClient.AreWeConnected() ) {
		for( size_t objectIndex = 0; objectIndex < mDASObjects.size(); ++objectIndex ) {
			mNetComClient.CloseStream(mDASObjects[objectIndex].c_str());
		}
	}
}
