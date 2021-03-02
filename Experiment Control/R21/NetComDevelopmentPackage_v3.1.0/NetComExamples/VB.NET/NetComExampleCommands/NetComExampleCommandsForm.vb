Public Class NetComExampleCommands
    Inherits System.Windows.Forms.Form
#Region "Private Members"
    Private mNetComClient As MNetCom.MNetComClient
#End Region

#Region "Constructor"
    Public Sub New()
        MyBase.New()

        'initialize class vars
        mNetComClient = New MNetCom.MNetComClient


        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

        'extra UI setup
        cmbCommandList.SelectedIndex = 0
        btnDisconnect.Enabled = False
        pnlCommands.Enabled = False

        'Set the logfile name
        If Not mNetComClient.SetLogFileName(Application.StartupPath.ToString() & "\NetComExampleCommandsLogfile.txt") Then
            MessageBox.Show(Me, "Call to set the logfile name failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
        End If

    End Sub
#End Region

#Region " Windows Form Designer generated code "



    'Form overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents lblServerName As System.Windows.Forms.Label
    Friend WithEvents btnConnect As System.Windows.Forms.Button
    Friend WithEvents btnDisconnect As System.Windows.Forms.Button
    Friend WithEvents txtServerName As System.Windows.Forms.TextBox
    Friend WithEvents lblServerNameComment As System.Windows.Forms.Label
    Friend WithEvents pnlCommands As System.Windows.Forms.Panel
    Friend WithEvents lblCommandListLabel As System.Windows.Forms.Label
    Friend WithEvents btnSendCommand As System.Windows.Forms.Button
    Friend WithEvents lblReplyStringValue As System.Windows.Forms.Label
    Friend WithEvents lblReplyStringLabel As System.Windows.Forms.Label
    Friend WithEvents cmbCommandList As System.Windows.Forms.ComboBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        lblServerName = New System.Windows.Forms.Label
        btnConnect = New System.Windows.Forms.Button
        btnDisconnect = New System.Windows.Forms.Button
        txtServerName = New System.Windows.Forms.TextBox
        lblServerNameComment = New System.Windows.Forms.Label
        pnlCommands = New System.Windows.Forms.Panel
        lblCommandListLabel = New System.Windows.Forms.Label
        btnSendCommand = New System.Windows.Forms.Button
        cmbCommandList = New System.Windows.Forms.ComboBox
        lblReplyStringLabel = New System.Windows.Forms.Label
        lblReplyStringValue = New System.Windows.Forms.Label
        pnlCommands.SuspendLayout()
        SuspendLayout()
        '
        'lblServerName
        '
        lblServerName.Location = New System.Drawing.Point(16, 11)
        lblServerName.Name = "lblServerName"
        lblServerName.Size = New System.Drawing.Size(72, 16)
        lblServerName.TabIndex = 0
        lblServerName.Text = "Server Name"
        '
        'btnConnect
        '
        btnConnect.Location = New System.Drawing.Point(344, 8)
        btnConnect.Name = "btnConnect"
        btnConnect.Size = New System.Drawing.Size(75, 23)
        btnConnect.TabIndex = 1
        btnConnect.Text = "Connect"
        '
        'btnDisconnect
        '
        btnDisconnect.Location = New System.Drawing.Point(432, 8)
        btnDisconnect.Name = "btnDisconnect"
        btnDisconnect.Size = New System.Drawing.Size(75, 23)
        btnDisconnect.TabIndex = 2
        btnDisconnect.Text = "Disconnect"
        '
        'txtServerName
        '
        txtServerName.Location = New System.Drawing.Point(96, 9)
        txtServerName.Name = "txtServerName"
        txtServerName.Size = New System.Drawing.Size(232, 20)
        txtServerName.TabIndex = 3
        '
        'lblServerNameComment
        '
        lblServerNameComment.Location = New System.Drawing.Point(108, 32)
        lblServerNameComment.Name = "lblServerNameComment"
        lblServerNameComment.Size = New System.Drawing.Size(208, 16)
        lblServerNameComment.TabIndex = 5
        lblServerNameComment.Text = "(User may enter pc name or IP address)"
        '
        'pnlCommands
        '
        pnlCommands.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
                    Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        pnlCommands.Controls.Add(lblReplyStringValue)
        pnlCommands.Controls.Add(lblReplyStringLabel)
        pnlCommands.Controls.Add(lblCommandListLabel)
        pnlCommands.Controls.Add(btnSendCommand)
        pnlCommands.Controls.Add(cmbCommandList)
        pnlCommands.Location = New System.Drawing.Point(16, 57)
        pnlCommands.Name = "pnlCommands"
        pnlCommands.Size = New System.Drawing.Size(488, 70)
        pnlCommands.TabIndex = 6
        '
        'lblCommandListLabel
        '
        lblCommandListLabel.Location = New System.Drawing.Point(13, 17)
        lblCommandListLabel.Name = "lblCommandListLabel"
        lblCommandListLabel.Size = New System.Drawing.Size(77, 20)
        lblCommandListLabel.TabIndex = 24
        lblCommandListLabel.Text = "Command List"
        lblCommandListLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        '
        'btnSendCommand
        '
        btnSendCommand.Location = New System.Drawing.Point(392, 17)
        btnSendCommand.Name = "btnSendCommand"
        btnSendCommand.Size = New System.Drawing.Size(96, 23)
        btnSendCommand.TabIndex = 23
        btnSendCommand.Text = "Send Command"
        '
        'cmbCommandList
        '
        cmbCommandList.Items.AddRange(New Object() {"-PostEvent ""Test Event"" 0 0", "-StartAcquisition"})
        cmbCommandList.Location = New System.Drawing.Point(96, 17)
        cmbCommandList.Name = "cmbCommandList"
        cmbCommandList.Size = New System.Drawing.Size(288, 21)
        cmbCommandList.TabIndex = 22
        '
        'lblReplyStringLabel
        '
        lblReplyStringLabel.AutoSize = True
        lblReplyStringLabel.Location = New System.Drawing.Point(26, 47)
        lblReplyStringLabel.Name = "lblReplyStringLabel"
        lblReplyStringLabel.Size = New System.Drawing.Size(64, 13)
        lblReplyStringLabel.TabIndex = 25
        lblReplyStringLabel.Text = "Reply String"
        '
        'lblReplyStringValue
        '
        lblReplyStringValue.AutoSize = True
        lblReplyStringValue.Location = New System.Drawing.Point(95, 47)
        lblReplyStringValue.Name = "lblReplyStringValue"
        lblReplyStringValue.Size = New System.Drawing.Size(0, 13)
        lblReplyStringValue.TabIndex = 26
        lblReplyStringValue.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'NetComExampleCommands
        '
        AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        ClientSize = New System.Drawing.Size(520, 139)
        Controls.Add(pnlCommands)
        Controls.Add(lblServerNameComment)
        Controls.Add(txtServerName)
        Controls.Add(btnDisconnect)
        Controls.Add(btnConnect)
        Controls.Add(lblServerName)
        FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Name = "NetComExampleCommands"
        Text = "NetCom Example - Commands"
        pnlCommands.ResumeLayout(False)
        pnlCommands.PerformLayout()
        ResumeLayout(False)
        PerformLayout()

    End Sub

#End Region


#Region "UI Event Handlers"

    '****************************************************************************************************************
    '****************************************************************************************************************
    Private Sub btnConnect_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnConnect.Click
        If Not mNetComClient.AreWeConnected Then
            If mNetComClient.ConnectToServer(txtServerName.Text) Then
                mNetComClient.SetApplicationName("NetCom Commands Example")

                'change ui to show connected status
                txtServerName.Enabled = False
                btnConnect.Enabled = False
                btnDisconnect.Enabled = True
                pnlCommands.Enabled = True

            Else
                MessageBox.Show(Me, "Connection to server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
            End If
        End If
    End Sub

    '****************************************************************************************************************
    '****************************************************************************************************************
    Private Sub btnDisconnect_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDisconnect.Click
        If mNetComClient.AreWeConnected Then
            If mNetComClient.DisconnectFromServer Then
                'change ui to show disconnected status
                txtServerName.Enabled = True
                btnConnect.Enabled = True
                btnDisconnect.Enabled = False
                pnlCommands.Enabled = False
            Else
                MessageBox.Show(Me, "Disconnection from server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
            End If
        End If
    End Sub

    '****************************************************************************************************************
    '****************************************************************************************************************
    Private Sub btnSendCommand_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSendCommand.Click
        Dim reply As String = ""
        Dim cmd As String = cmbCommandList.Text
        If Not mNetComClient.SendCommand(cmbCommandList.Text, reply) Then
            MessageBox.Show(Me, "Send command to server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
        Else
            Dim parsedReplyString As String() = Strings.Split(reply, " ")
            If (0 < parsedReplyString.GetLength(0)) Then
                If parsedReplyString(0) = "-1" Then
                    MessageBox.Show(Me, "The DAS could not process your command.", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
                End If

                lblReplyStringValue.Text = reply

            End If

        End If
    End Sub

#End Region

End Class
