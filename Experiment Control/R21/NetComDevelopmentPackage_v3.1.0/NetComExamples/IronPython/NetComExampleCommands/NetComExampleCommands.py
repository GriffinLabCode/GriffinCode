#**********************************************
#	NetComExampleCommandsForm.py
#	Copyright 2016 @ Neuralynx, Inc
#**********************************************

import clr

clr.AddReference('IronPython')
clr.AddReference('System')
clr.AddReference('System.Drawing')
clr.AddReference('System.ComponentModel')
clr.AddReference('System.Windows.Forms')

import System, os
import System.Drawing as SysDrawing
import System.ComponentModel as SysComponentModel
import System.Windows.Forms as SysForms
from IPyNetComClient import *

class NetComExampleCommandsForm(SysForms.Form):

    def __init__(self):
        '''Initializer'''
        # DAS object list holders
        self.components = SysComponentModel.Container
        self.components = None
        #
        # IPyNetCom Client
        self.aClient = IPyNetComClient()
        self.InitializeComponent()
        #
        # extra UI setup
        self.btnDisconnect.Enabled = False;
        self.btnSendCommand.Enabled = False;             
        #
        # set the logfile name
        if ((self.aClient.setLogFileName(os.path.dirname(os.path.abspath(__file__)) + "\\NetComExampleStreamsLogfile.txt")) == False):
             SysForms.MessageBox.Show(self, "Call to set the logfile name failed", "NetCom Error",  SysForms.MessageBoxButtons.OK,  SysForms.MessageBoxIcon.Error,  SysForms.MessageBoxDefaultButton.Button1)
        
        return self

    def InitializeComponent(self):
        '''Windows Form Designer generated code'''
        self.lblServerName = SysForms.Label()
        self.lblServerNameComment = SysForms.Label()
        self.txtServerName = SysForms.TextBox()
        self.btnDisconnect = SysForms.Button()
        self.btnConnect = SysForms.Button()
        self.lblCommandString = SysForms.Label()
        self.txtCommand = SysForms.TextBox()
        self.btnSendCommand = SysForms.Button()
        self.lblCommandReply = SysForms.Label()
        self.lblCommandReplyValue = SysForms.Label()
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
		# lblCommandString
		#
        self.lblCommandString.Location = SysDrawing.Point(16, 80)
        self.lblCommandString.Name = "lblCommandName"
        self.lblCommandString.Size = SysDrawing.Size(90, 16)
        self.lblCommandString.TabIndex = 29
        self.lblCommandString.Text = "Command String"
        # 
        # txtCommand
        # 
        self.txtCommand.Location = SysDrawing.Point(110, 80)
        self.txtCommand.Name = "txtCommand"
        self.txtCommand.Size = SysDrawing.Size(280, 20)
        self.txtCommand.TabIndex = 30
        self.txtCommand.Text = "-PostEvent \"Test Event\" 0 0"
        # 
        # btnSendCommand
        # 
        self.btnSendCommand.Location = SysDrawing.Point(400, 80)
        self.btnSendCommand.Name = "btnSendCommand"
        self.btnSendCommand.TabIndex = 31
        self.btnSendCommand.Size = SysDrawing.Size(100, 20)
        self.btnSendCommand.Text = "Send Command"
        self.btnSendCommand.Click += System.EventHandler(self.btnSendCommand_Click)
		# 
		# lblCommandReply
		#
        self.lblCommandReply.Location = SysDrawing.Point(16, 120)
        self.lblCommandReply.Name = "lblCommandReply"
        self.lblCommandReply.Size = SysDrawing.Size(100, 16)
        self.lblCommandReply.TabIndex = 32
        self.lblCommandReply.Text = "Command Reply: "
		# 
		# lblCommandReplyValue
		#
        self.lblCommandReplyValue.Location = SysDrawing.Point(118, 120)
        self.lblCommandReplyValue.Name = "lblCommandReplyValue"
        self.lblCommandReplyValue.Size = SysDrawing.Size(300, 16)
        self.lblCommandReplyValue.TabIndex = 33
        self.lblCommandReplyValue.Text = ""
        # 
        # NetComExampleCommandsForm
        # 
        self.AutoScaleBaseSize = SysDrawing.Size(5, 13)
        self.ClientSize = SysDrawing.Size(552, 150)
        self.Controls.Add(self.lblServerName)
        self.Controls.Add(self.lblServerNameComment)
        self.Controls.Add(self.txtServerName)
        self.Controls.Add(self.btnDisconnect)
        self.Controls.Add(self.btnConnect)
        self.Controls.Add(self.lblCommandString)
        self.Controls.Add(self.txtCommand)
        self.Controls.Add(self.btnSendCommand)
        self.Controls.Add(self.lblCommandReply)
        self.Controls.Add(self.lblCommandReplyValue)
        self.FormBorderStyle = SysForms.FormBorderStyle.FixedDialog
        self.Name = "NetComExampleCommandsForm"
        self.Text = "NetCom Example - Commands"
        self.ResumeLayout(False)


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
                self.btnSendCommand.Enabled = True             
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
                self.btnSendCommand.Enabled = False             
            else:
                SysForms.MessageBox.Show(self, "Disconnection from server failed", "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)

    #**************************************************************
    #**************************************************************   
    def btnSendCommand_Click(self, sender, event):
       
        if (self.aClient.areWeConnected() == True):
            response = self.aClient.sendCommand(self.txtCommand.Text)
            if (response[0] == True):
                self.lblCommandReplyValue.Text = ', '.join(map(str, response[1:]))
            else:
                SysForms.MessageBox.Show(self, "DAS could not process your command", "NetCom Error", SysForms.MessageBoxButtons.OK, SysForms.MessageBoxIcon.Error, SysForms.MessageBoxDefaultButton.Button1)

def Main():
    newApp = NetComExampleCommandsForm()
    SysForms.Application.Run(newApp)

if __name__ == '__main__':
    Main()