//**********************************************
//	NetComExampleCommandsDlg.h
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
#pragma once
#include "..\..\..\Include\NetComClient.h"
#include "afxwin.h"

class NetComExampleCommandsDlg : public CDialog
{
public:
	NetComExampleCommandsDlg(CWnd* pParent = NULL);	// standard constructor
	enum { IDD = IDD_NETCOMEXAMPLECOMMANDS_DIALOG };

protected:
	void DoDataExchange(CDataExchange* pDX) override;	// DDX/DDV support
	HICON m_hIcon;

	// Generated message map functions
	BOOL OnInitDialog() override;
	afx_msg void OnPaint();
	DECLARE_MESSAGE_MAP()

	//we override this function so that if the user hits the enter key, the program does not exit
	afx_msg void OnOK() {} 
	afx_msg void OnBnClickedConnect();
	afx_msg void OnBnClickedDisconnect();
	afx_msg void OnBnClickedSendCommand();

	//this function will do any initialization for netcom that is necessary
	void InitializeNetCom();
	CString GetNetComLogPathName();

private:
	NlxNetCom::NetComClient mNetComClient;
	CString mServerName;
	CString mCommandString;
};
