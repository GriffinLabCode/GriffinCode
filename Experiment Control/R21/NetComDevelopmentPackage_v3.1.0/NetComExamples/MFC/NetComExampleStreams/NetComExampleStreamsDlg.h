//**********************************************
//	NetComExampleStreamsDlg.h
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#pragma once
#include "..\..\..\Include\NetComClient.h"
#include "..\..\..\Include\Nlx_DataTypes.h"
#include "afxwin.h"
#include <string>
#include <vector>

class NetComExampleStreamsDlg : public CDialog
{
public:
	NetComExampleStreamsDlg(CWnd* pParent = NULL);	// standard constructor
	enum { IDD = IDD_NETCOMEXAMPLESTREAMS_DIALOG };

	//these are the callback functions for our real time data records
	static void NetComCallbackSE( void* myClass, NlxDataTypes::SERec* records, int numRecords, const wchar_t objectName[] );
	static void NetComCallbackST( void* myClass, NlxDataTypes::STRec* records, int numRecords, const wchar_t objectName[] );
	static void NetComCallbackTT( void* myClass, NlxDataTypes::TTRec* records, int numRecords, const wchar_t objectName[] );
	static void NetComCallbackCSC( void* myClass,NlxDataTypes::CRRec* records, int numRecords, const wchar_t objectName[] );
	static void NetComCallbackEV( void* myClass, NlxDataTypes::EventRec* records, int numRecords, const wchar_t objectName[] );
	static void NetComCallbackVT( void* myClass, NlxDataTypes::VideoRec* records, int numRecords, const wchar_t objectName[] );

protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	DECLARE_MESSAGE_MAP()

	//we override this function so that if the user hits the enter key, the program does not exit
	afx_msg void OnOK() {} 
	afx_msg void OnBnClickedConnect();
	afx_msg void OnBnClickedDisconnect();
	afx_msg void OnBnClickedGetDASObjects();
	afx_msg void OnCbnSelchangeDASObjectsList();
	afx_msg void OnBnClickedOpenStream();
	afx_msg void OnBnClickedCloseStream();

	//this function will do any initialization for netcom that is necessary
	void InitializeNetCom();
	CString GetNetComLogPathName();
	void UpdateDASObjectsList();

private:
	NlxNetCom::NetComClient mNetComClient;
	CString mServerName;
	CComboBox mDASObjectsListCtrl;
	CString mDASObjectType;
	int mNumDASObjects;
	std::vector<std::wstring> mDASObjects;
	std::vector<std::wstring> mDASTypes;

public:
	CListBox mRecordLogListCtrl;
	afx_msg void OnBnClickedOpenAllStreams();
	afx_msg void OnBnClickedCloseAllStreams();
};
