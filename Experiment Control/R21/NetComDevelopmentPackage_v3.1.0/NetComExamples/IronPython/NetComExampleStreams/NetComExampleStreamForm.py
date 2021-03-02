#**********************************************
#	IPyNetComExampleStreamsForm.py
#	Copyright 2016 @ Neuralynx, Inc
#**********************************************

import clr

clr.AddReference('IronPython')
clr.AddReference('System')
clr.AddReference('System.Drawing')
clr.AddReference('System.Collections')
clr.AddReference('System.ComponentModel')
clr.AddReference('System.Windows.Forms')
clr.AddReference('System.Data')

import System, os, sys
import System.Drawing as SysDrawing
import System.Collections as SysCollection
import System.Collections.Generic as SysGeneric
import System.ComponentModel as SysComponentModel
import System.Windows.Forms as SysForms
import System.Data as SysData
from IPyNetComClient import *
from IronPython.Compiler import CallTarget0

class NetComExampleStreamsForm(SysForms.Form):

    def __init__(self):
        '''Initializer'''
        # DAS object list holders
        self.ObjectsList = []
        self.TypesList = []
        self.components = SysComponentModel.Container
        self.components = None
        #
        # IPyNetCom Client
        self.aClient = IPyNetComClient()
        self.InitializeComponent()
        #
        # extra UI setup
        self.btnDisconnect.Enabled = False;
        self.grpRecordLog.Enabled = False;
        self.grpStreamProps.Enabled = False;
        #
        # set the logfile name
        if ((self.aClient.setLogFileName(os.path.dirname(os.path.abspath(__file__)) + "\\NetComExampleStreamsLogfile.txt")) == False):
             SysForms.MessageBox.Show(self, "Call to set the logfile name failed", "NetCom Error",  SysForms.MessageBoxButtons.OK,  SysForms.MessageBoxIcon.Error,  SysForms.MessageBoxDefaultButton.Button1)
        
        # register the callBack functions
        self.setNetComCallBacks()
        return self

    def setNetComCallBacks(self):
        '''register the callback functions'''
        ipymNetcomSECallback = self.aClient.MNC_SECallback(self.NetComCallbackSE);
        self.aClient.setCallbackFunctionSE(ipymNetcomSECallback);
        ipymNetcomSTCallback =self.aClient.MNC_STCallback(self.NetComCallbackST);
        self.aClient.setCallbackFunctionST(ipymNetcomSTCallback);
        ipymNetcomTTCallback =  self.aClient.MNC_TTCallback(self.NetComCallbackTT);
        self.aClient.setCallbackFunctionTT(ipymNetcomTTCallback);
        ipymNetcomCSCCallback = self.aClient.MNC_CSCCallback(self.NetComCallbackCSC);
        self.aClient.setCallbackFunctionCSC(ipymNetcomCSCCallback);
        ipymNetcomEVCallback = self.aClient.MNC_EVCallback(self.NetComCallbackEV);
        self.aClient.setCallbackFunctionEV(ipymNetcomEVCallback);
        ipymNetcomVTCallback =  self.aClient.MNC_VTCallback(self.NetComCallbackVT);
        self.aClient.setCallbackFunctionVT(ipymNetcomVTCallback);

    def InitializeComponent(self):
        '''Windows Form Designer generated code'''
        self.lblServerName = SysForms.Label()
        self.grpStreamProps = SysForms.GroupBox()
        self.btnCloseStream = SysForms.Button()
        self.btnOpenStream = SysForms.Button()
        self.btnObjectRefresh = SysForms.Button()
        self.lblObjectCountNum = SysForms.Label()
        self.lblObjectCount = SysForms.Label()
        self.lblObjectTypeString = SysForms.Label()
        self.lblObjectType = SysForms.Label()
        self.cmbDASObjects = SysForms.ComboBox()
        self.lblDASObjects = SysForms.Label()
        self.lblServerNameComment = SysForms.Label()
        self.txtServerName = SysForms.TextBox()
        self.btnDisconnect = SysForms.Button()
        self.btnConnect = SysForms.Button()
        self.grpRecordLog = SysForms.GroupBox()
        self.lbRecordLog = SysForms.ListBox()
        self.grpStreamProps.SuspendLayout()
        self.grpRecordLog.SuspendLayout()
        self.SuspendLayout()
		# 
		# lblServerName
		#
        self.lblServerName.Location = SysDrawing.Point(16, 8)
        self.lblServerName.Name = "lblServerName"
        self.lblServerName.Size = SysDrawing.Size(72, 16)
        self.lblServerName.TabIndex = 24
        self.lblServerName.Text = "Server Name"
		# 
		# grpStreamProps
		# 
        self.grpStreamProps.Controls.Add(self.btnCloseStream)
        self.grpStreamProps.Controls.Add(self.btnOpenStream)
        self.grpStreamProps.Controls.Add(self.btnObjectRefresh)
        self.grpStreamProps.Controls.Add(self.lblObjectCountNum)
        self.grpStreamProps.Controls.Add(self.lblObjectCount)
        self.grpStreamProps.Controls.Add(self.lblObjectTypeString)
        self.grpStreamProps.Controls.Add(self.lblObjectType)
        self.grpStreamProps.Controls.Add(self.cmbDASObjects)
        self.grpStreamProps.Controls.Add(self.lblDASObjects)
        self.grpStreamProps.Location = SysDrawing.Point(16, 64)
        self.grpStreamProps.Name = "grpStreamProps"
        self.grpStreamProps.Size =  SysDrawing.Size(520, 88)
        self.grpStreamProps.TabIndex = 29
        self.grpStreamProps.TabStop = False
        self.grpStreamProps.Text = "Stream Properties"
		# 
		# btnCloseStream
		# 
        self.btnCloseStream.Location = SysDrawing.Point(192, 56)
        self.btnCloseStream.Name = "btnCloseStream"
        self.btnCloseStream.Size =SysDrawing.Size(88, 23)
        self.btnCloseStream.TabIndex = 8
        self.btnCloseStream.Text = "Close Stream"
        self.btnCloseStream.Click += System.EventHandler(self.btnCloseStream_Click)
		# 
		# btnOpenStream
		# 
        self.btnOpenStream.Location = SysDrawing.Point(104, 56)
        self.btnOpenStream.Name = "btnOpenStream"
        self.btnOpenStream.Size = SysDrawing.Size(80, 23)
        self.btnOpenStream.TabIndex = 7
        self.btnOpenStream.Text = "Open Stream"
        self.btnOpenStream.Click += System.EventHandler(self.btnOpenStream_Click)
		# 
		# btnObjectRefresh
		# 
        self.btnObjectRefresh.Location = SysDrawing.Point(16, 56)
        self.btnObjectRefresh.Name = "btnObjectRefresh"
        self.btnObjectRefresh.Size = SysDrawing.Size(80, 23)
        self.btnObjectRefresh.TabIndex = 6
        self.btnObjectRefresh.Text = "Refresh List"
        self.btnObjectRefresh.Click += System.EventHandler(self.btnObjectRefresh_Click)
		# 
		# lblObjectCountNum
		# 
        self.lblObjectCountNum.BorderStyle = SysForms.BorderStyle.Fixed3D
        self.lblObjectCountNum.Location = SysDrawing.Point(472, 29)
        self.lblObjectCountNum.Name = "lblObjectCountNum"
        self.lblObjectCountNum.Size = SysDrawing.Size(32, 23)
        self.lblObjectCountNum.TabIndex = 5
		#
		# lblObjectCount
		# 
        self.lblObjectCount.Location = SysDrawing.Point(400, 32)
        self.lblObjectCount.Name = "lblObjectCount"
        self.lblObjectCount.Size = SysDrawing.Size(72, 16)
        self.lblObjectCount.TabIndex = 4
        self.lblObjectCount.Text = "Object Count"
        # 
        # lblObjectTypeString
        # 
        self.lblObjectTypeString.BorderStyle = SysForms.BorderStyle.Fixed3D
        self.lblObjectTypeString.Location = SysDrawing.Point(296, 29)
        self.lblObjectTypeString.Name = "lblObjectTypeString"
        self.lblObjectTypeString.Size = SysDrawing.Size(88, 23)
        self.lblObjectTypeString.TabIndex = 3
        # 
        # lblObjectType
        # 
        self.lblObjectType.Location = SysDrawing.Point(224, 32)
        self.lblObjectType.Name = "lblObjectType"
        self.lblObjectType.Size = SysDrawing.Size(72, 16)
        self.lblObjectType.TabIndex = 2
        self.lblObjectType.Text = "Object Type"
        # 
        # cmbDASObjects
        # 
        self.cmbDASObjects.DropDownStyle = SysForms.ComboBoxStyle.DropDownList
        self.cmbDASObjects.Location = SysDrawing.Point(104, 30)
        self.cmbDASObjects.Name = "cmbDASObjects"
        self.cmbDASObjects.Size = SysDrawing.Size(112, 21)
        self.cmbDASObjects.TabIndex = 1
        self.cmbDASObjects.SelectedIndexChanged += System.EventHandler(self.cmbDASObjects_SelectedIndexChanged)
        # 
        # lblDASObjects
        # 
        self.lblDASObjects.Location = SysDrawing.Point(16, 32)
        self.lblDASObjects.Name = "lblDASObjects"
        self.lblDASObjects.Size = SysDrawing.Size(88, 16)
        self.lblDASObjects.TabIndex = 0
        self.lblDASObjects.Text = "DAS Objects"
        # 
        # lblServerNameComment
        # 
        self.lblServerNameComment.Location = SysDrawing.Point(136, 32)
        self.lblServerNameComment.Name = "lblServerNameComment"
        self.lblServerNameComment.Size = SysDrawing.Size(208, 16)
        self.lblServerNameComment.TabIndex = 28
        self.lblServerNameComment.Text = "(User may enter pc name or IP address)"
        # 
        # txtServerName
        # 
        self.txtServerName.Location = SysDrawing.Point(96, 8)
        self.txtServerName.Name = "txtServerName"
        self.txtServerName.Size = SysDrawing.Size(280, 20)
        self.txtServerName.TabIndex = 27
        self.txtServerName.Text = ""
        # 
        # btnDisconnect
        # 
        self.btnDisconnect.Location = SysDrawing.Point(464, 8)
        self.btnDisconnect.Name = "btnDisconnect"
        self.btnDisconnect.TabIndex = 26
        self.btnDisconnect.Text = "Disconnect"
        self.btnDisconnect.Click += System.EventHandler(self.btnDisconnect_Click)
        # 
        # btnConnect
        # 
        self.btnConnect.Location = SysDrawing.Point(384, 8)
        self.btnConnect.Name = "btnConnect"
        self.btnConnect.TabIndex = 25
        self.btnConnect.Text = "Connect"
        self.btnConnect.Click += System.EventHandler(self.btnConnect_Click)
        # 
        # grpRecordLog
        # 
        self.grpRecordLog.Controls.Add(self.lbRecordLog)
        self.grpRecordLog.Location = SysDrawing.Point(16, 168)
        self.grpRecordLog.Name = "grpRecordLog"
        self.grpRecordLog.Size = SysDrawing.Size(520, 240)
        self.grpRecordLog.TabIndex = 30
        self.grpRecordLog.TabStop = False
        self.grpRecordLog.Text = "Record Log"
        # 
        # lbRecordLog
        # 
        self.lbRecordLog.Location = SysDrawing.Point(8, 16)
        self.lbRecordLog.Name = "lbRecordLog"
        self.lbRecordLog.Size = SysDrawing.Size(504, 212)
        self.lbRecordLog.TabIndex = 0
        # 
        # NetComExampleStreamsForm
        # 
        self.AutoScaleBaseSize = SysDrawing.Size(5, 13)
        self.ClientSize = SysDrawing.Size(552, 422)
        self.Controls.Add(self.lblServerName)
        self.Controls.Add(self.grpStreamProps)
        self.Controls.Add(self.lblServerNameComment)
        self.Controls.Add(self.txtServerName)
        self.Controls.Add(self.btnDisconnect)
        self.Controls.Add(self.btnConnect)
        self.Controls.Add(self.grpRecordLog)
        self.FormBorderStyle = SysForms.FormBorderStyle.FixedDialog
        self.Name = "NetComExampleStreamsForm"
        self.Text = "NetCom Example - Streams"
        self.grpStreamProps.ResumeLayout(False)
        self.grpRecordLog.ResumeLayout(False)
        self.ResumeLayout(False)

    # Async UI Update
    #**************************************************************
    #************************************************************** 

    def RecordLogUpdate(self,updateText):
        '''Async UI Update'''
        self.lbRecordLog.Items.Add(updateText)
        self.lbRecordLog.SelectedItem = updateText

    #UI Event Handlers
    #**************************************************************
    #**************************************************************   
         
    def btnConnect_Click(self, sender, event):
       
        if (self.aClient.areWeConnected() == False):
            if (self.aClient.connectToServer(self.txtServerName.Text)):
                self.aClient.setAppName("NetCom Streams Example")
                # change ui to show connected status
                self.txtServerName.Enabled = False
                self.btnConnect.Enabled = False
                self.btnDisconnect.Enabled = True
                self.grpRecordLog.Enabled = True
                self.grpStreamProps.Enabled = True
                
                # reset the array lists
                self.ObjectsList = []
                self.TypesList = []
                temp = self.aClient.getDASObjectsTypes()
                if (temp[0]):
                        self.ObjectsList = temp[1]
                        self.TypesList = temp[2]
                        #load all object names into the combo box
                        for i in range(len(self.ObjectsList)):
                            self.cmbDASObjects.Items.Add(self.ObjectsList[i])

						# select the first object in the combo box, and update the ui
                        if(self.ObjectsList.Count > 0):
                            self.cmbDASObjects.SelectedIndex = 0
                            self.lblObjectTypeString.Text = str(self.TypesList[0])
                            self.lblObjectCountNum.Text = self.ObjectsList.Count.ToString()
                        else:
                            SysForms.MessageBox.Show(self, "Retrieval of DAS objects and types failed.  List must be refreshed.", "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)
            else:
                SysForms.MessageBox.Show(self, "Connection to server failed", "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)
    
    #**************************************************************
    #**************************************************************    


    def btnDisconnect_Click(self,sender, event):
        if (self.aClient.areWeConnected()):
            if (self.aClient.disconnectFromServer()):
                #change ui to show disconnected status
                self.txtServerName.Enabled = True
                self.btnConnect.Enabled = True
                self.btnDisconnect.Enabled = False
                self.cmbDASObjects.Items.Clear()
                self.lbRecordLog.Items.Clear()
                self.lblObjectCountNum.Text = ""
                self.lblObjectTypeString.Text = ""
                self.grpRecordLog.Enabled = False
                self.grpStreamProps.Enabled = False

            else:
                SysForms.MessageBox.Show(self, "Disconnection from server failed", "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)

    #**************************************************************
    #************************************************************** 
            
    def btnObjectRefresh_Click(self,sender, event):
        #reset the DAS lists
        self.cmbDASObjects.Items.Clear()
        self.ObjectList = []
        self.TypesList = []
        temp = self.aClient.getDASObjectsTypes()
        if (temp[0]):
                self.ObjectsList = temp[1]
                self.TypesList = temp[2]
                #load all object names into the combo box
                for i in range(len(self.ObjectsList)):
                    self.cmbDASObjects.Items.Add(self.ObjectsList[i])

                # select the first object in the combo box, and update the ui
                if(self.ObjectsList.Count > 0):
                    self.cmbDASObjects.SelectedIndex = 0
                    self.lblObjectTypeString.Text = str(self.TypesList[0])
                    self.lblObjectCountNum.Text = self.ObjectsList.Count.ToString()
                else:
                    SysForms.MessageBox.Show(self, "Retrieval of DAS objects and types failed.  List must be refreshed.", "NetCom Error", SysForms.MessageBox.Buttons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)	
    
    #**************************************************************
    #**************************************************************    

    def btnOpenStream_Click(self,sender, event):
        curIndex = self.cmbDASObjects.SelectedIndex
        #ensure something is selected to open
        if (curIndex == -1):
            SysForms.MessageBox.Show(self, "No object selected for stream open", "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)
            return
        #get the strings from the object list
        curDASObject = str(self.ObjectsList[curIndex])
        if ((self.aClient.openStream(curDASObject)) == False ):
            SysForms.MessageBox.Show(self, "Could not open stream for ObjectName: " + curDASObject, "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)

    #**************************************************************
    #************************************************************** 

    def btnCloseStream_Click(self, sender, event):
        curIndex = self.cmbDASObjects.SelectedIndex
        #ensure something is selected to close
        if (curIndex == -1):
            SysForms.MessageBox.Show(self, "No object selected for stream close", "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)
            return
        #get the strings from the object list
        curDASObject = str(self.ObjectsList[curIndex])
        if ((self.aClient.closeStream(curDASObject)) == False):
            SysForms.MessageBox.Show(self, "Could not close stream for ObjectName: " + curDASObject, "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)

    #**************************************************************
    #************************************************************** 

    def cmbDASObjects_SelectedIndexChanged(self, sender, event):
        curIndex = self.cmbDASObjects.SelectedIndex
        if (curIndex == -1):
            return
        else:	
            self.lblObjectTypeString.Text = str(self.TypesList[curIndex])


    # NetCom Callback Functions
    #**************************************************************
    #************************************************************** 

    def NetComCallbackSE(self, sender, records, numRecords, objectName):
        thisClass = sender
        msgString = "Received SE Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();
        RecordLogUpdateDelegate = CallTarget0(lambda: self.RecordLogUpdate(msgString))
        self.lbRecordLog.BeginInvoke(RecordLogUpdateDelegate)

    #**************************************************************
    #************************************************************** 

    def NetComCallbackST(self, sender, records, numRecords, objectName):
        thisClass = sender
        msgString = "Received ST Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();
        RecordLogUpdateDelegate = CallTarget0(lambda: self.RecordLogUpdate(msgString))
        self.lbRecordLog.BeginInvoke(RecordLogUpdateDelegate)

    #**************************************************************
    #************************************************************** 

    def NetComCallbackTT(self, sender, records, numRecords, objectName):
        thisClass = sender
        msgString = "Received TT Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();
        RecordLogUpdateDelegate = CallTarget0(lambda: self.RecordLogUpdate(msgString))
        self.lbRecordLog.BeginInvoke(RecordLogUpdateDelegate)

    #**************************************************************
    #************************************************************** 

    def NetComCallbackCSC(self, sender, records, numRecords, objectName):
        thisClass = sender
        msgString = "Received CSC Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();
        RecordLogUpdateDelegate = CallTarget0(lambda: self.RecordLogUpdate(msgString))
        self.lbRecordLog.BeginInvoke(RecordLogUpdateDelegate)

    #**************************************************************
    #************************************************************** 

    def NetComCallbackEV(self, sender, records, numRecords, objectName):
        thisClass = sender
        msgString = "Received Event Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString() + " with string: " + records.EventString;
        RecordLogUpdateDelegate = CallTarget0(lambda: self.RecordLogUpdate(msgString))
        self.lbRecordLog.BeginInvoke(RecordLogUpdateDelegate)

    #**************************************************************
    #************************************************************** 

    def NetComCallbackVT(self, sender,  records, numRecords,  objectName):
        thisClass = sender
        msgString = "Received Video Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();
        RecordLogUpdateDelegate = CallTarget0(lambda: self.RecordLogUpdate(msgString))
        self.lbRecordLog.BeginInvoke(RecordLogUpdateDelegate)


def Main():
    newApp = NetComExampleStreamsForm()
    SysForms.Application.Run(newApp)

if __name__ == '__main__':
    Main()