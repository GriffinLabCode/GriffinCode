Public Class NetComExampleStreamsForm
    Inherits System.Windows.Forms.Form

#Region "Private Members"
    'netcom client
    Private mNetComClient As MNetCom.MNetComClient

    'callback delegates
    Private mNetcomSECallback As MNetCom.MNC_SECallback
    Private mNetcomSTCallback As MNetCom.MNC_STCallback
    Private mNetcomTTCallback As MNetCom.MNC_TTCallback
    Private mNetcomCSCCallback As MNetCom.MNC_CSCCallback
    Private mNetcomEVCallback As MNetCom.MNC_EVCallback
    Private mNetcomVTCallback As MNetCom.MNC_VTCallback

    'Needed for proper UI updating in a multi-threaded application
    Private Delegate Sub AsyncRecordLogUpdate(ByRef updateText As String)

    'DAS object list holders
    Private mDASObjectList As List(Of String)
    Private mDASTypesList As List(Of String)
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
        btnDisconnect.Enabled = False
        grpRecordLog.Enabled = False
        grpStreamProps.Enabled = False

        'Set the logfile name
        If Not mNetComClient.SetLogFileName(Application.StartupPath.ToString() & "\NetComExampleStreamsLogfile.txt") Then
            MessageBox.Show(Me, "Call to set the logfile name failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
        End If

        'register the callback functions
        mNetcomSECallback = New MNetCom.MNC_SECallback(AddressOf NetComCallbackSE)
        mNetComClient.SetCallbackFunctionSE(mNetcomSECallback, Me)
        mNetcomSTCallback = New MNetCom.MNC_STCallback(AddressOf NetComCallbackST)
        mNetComClient.SetCallbackFunctionST(mNetcomSTCallback, Me)
        mNetcomTTCallback = New MNetCom.MNC_TTCallback(AddressOf NetComCallbackTT)
        mNetComClient.SetCallbackFunctionTT(mNetcomTTCallback, Me)
        mNetcomCSCCallback = New MNetCom.MNC_CSCCallback(AddressOf NetComCallbackCSC)
        mNetComClient.SetCallbackFunctionCSC(mNetcomCSCCallback, Me)
        mNetcomEVCallback = New MNetCom.MNC_EVCallback(AddressOf NetComCallbackEV)
        mNetComClient.SetCallbackFunctionEV(mNetcomEVCallback, Me)
        mNetcomVTCallback = New MNetCom.MNC_VTCallback(AddressOf NetComCallbackVT)
        mNetComClient.SetCallbackFunctionVT(mNetcomVTCallback, Me)

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
    Friend WithEvents lblServerNameComment As System.Windows.Forms.Label
    Friend WithEvents txtServerName As System.Windows.Forms.TextBox
    Friend WithEvents btnDisconnect As System.Windows.Forms.Button
    Friend WithEvents btnConnect As System.Windows.Forms.Button
    Friend WithEvents lblServerName As System.Windows.Forms.Label
    Friend WithEvents grpStreamProps As System.Windows.Forms.GroupBox
    Friend WithEvents lblDASObjects As System.Windows.Forms.Label
    Friend WithEvents cmbDASObjects As System.Windows.Forms.ComboBox
    Friend WithEvents lblObjectType As System.Windows.Forms.Label
    Friend WithEvents lblObjectTypeString As System.Windows.Forms.Label
    Friend WithEvents lblObjectCountNum As System.Windows.Forms.Label
    Friend WithEvents lblObjectCount As System.Windows.Forms.Label
    Friend WithEvents grpRecordLog As System.Windows.Forms.GroupBox
    Friend WithEvents lbRecordLog As System.Windows.Forms.ListBox
    Friend WithEvents btnObjectRefresh As System.Windows.Forms.Button
    Friend WithEvents btnOpenStream As System.Windows.Forms.Button
    Friend WithEvents btnCloseStream As System.Windows.Forms.Button
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        lblServerNameComment = New System.Windows.Forms.Label
        txtServerName = New System.Windows.Forms.TextBox
        btnDisconnect = New System.Windows.Forms.Button
        btnConnect = New System.Windows.Forms.Button
        lblServerName = New System.Windows.Forms.Label
        grpStreamProps = New System.Windows.Forms.GroupBox
        btnCloseStream = New System.Windows.Forms.Button
        btnOpenStream = New System.Windows.Forms.Button
        btnObjectRefresh = New System.Windows.Forms.Button
        lblObjectCountNum = New System.Windows.Forms.Label
        lblObjectCount = New System.Windows.Forms.Label
        lblObjectTypeString = New System.Windows.Forms.Label
        lblObjectType = New System.Windows.Forms.Label
        cmbDASObjects = New System.Windows.Forms.ComboBox
        lblDASObjects = New System.Windows.Forms.Label
        grpRecordLog = New System.Windows.Forms.GroupBox
        lbRecordLog = New System.Windows.Forms.ListBox
        grpStreamProps.SuspendLayout()
        grpRecordLog.SuspendLayout()
        SuspendLayout()
        '
        'lblServerNameComment
        '
        lblServerNameComment.Location = New System.Drawing.Point(136, 32)
        lblServerNameComment.Name = "lblServerNameComment"
        lblServerNameComment.Size = New System.Drawing.Size(208, 16)
        lblServerNameComment.TabIndex = 21
        lblServerNameComment.Text = "(User may enter pc name or IP address)"
        '
        'txtServerName
        '
        txtServerName.Location = New System.Drawing.Point(96, 8)
        txtServerName.Name = "txtServerName"
        txtServerName.Size = New System.Drawing.Size(280, 20)
        txtServerName.TabIndex = 20
        txtServerName.Text = ""
        '
        'btnDisconnect
        '
        btnDisconnect.Location = New System.Drawing.Point(464, 8)
        btnDisconnect.Name = "btnDisconnect"
        btnDisconnect.TabIndex = 19
        btnDisconnect.Text = "Disconnect"
        '
        'btnConnect
        '
        btnConnect.Location = New System.Drawing.Point(384, 8)
        btnConnect.Name = "btnConnect"
        btnConnect.TabIndex = 18
        btnConnect.Text = "Connect"
        '
        'lblServerName
        '
        lblServerName.Location = New System.Drawing.Point(16, 8)
        lblServerName.Name = "lblServerName"
        lblServerName.Size = New System.Drawing.Size(72, 16)
        lblServerName.TabIndex = 17
        lblServerName.Text = "Server Name"
        '
        'grpStreamProps
        '
        grpStreamProps.Controls.Add(btnCloseStream)
        grpStreamProps.Controls.Add(btnOpenStream)
        grpStreamProps.Controls.Add(btnObjectRefresh)
        grpStreamProps.Controls.Add(lblObjectCountNum)
        grpStreamProps.Controls.Add(lblObjectCount)
        grpStreamProps.Controls.Add(lblObjectTypeString)
        grpStreamProps.Controls.Add(lblObjectType)
        grpStreamProps.Controls.Add(cmbDASObjects)
        grpStreamProps.Controls.Add(lblDASObjects)
        grpStreamProps.Location = New System.Drawing.Point(16, 64)
        grpStreamProps.Name = "grpStreamProps"
        grpStreamProps.Size = New System.Drawing.Size(520, 88)
        grpStreamProps.TabIndex = 22
        grpStreamProps.TabStop = False
        grpStreamProps.Text = "Stream Properties"
        '
        'btnCloseStream
        '
        btnCloseStream.Location = New System.Drawing.Point(192, 56)
        btnCloseStream.Name = "btnCloseStream"
        btnCloseStream.Size = New System.Drawing.Size(88, 23)
        btnCloseStream.TabIndex = 8
        btnCloseStream.Text = "Close Stream"
        '
        'btnOpenStream
        '
        btnOpenStream.Location = New System.Drawing.Point(104, 56)
        btnOpenStream.Name = "btnOpenStream"
        btnOpenStream.Size = New System.Drawing.Size(80, 23)
        btnOpenStream.TabIndex = 7
        btnOpenStream.Text = "Open Stream"
        '
        'btnObjectRefresh
        '
        btnObjectRefresh.Location = New System.Drawing.Point(16, 56)
        btnObjectRefresh.Name = "btnObjectRefresh"
        btnObjectRefresh.Size = New System.Drawing.Size(80, 23)
        btnObjectRefresh.TabIndex = 6
        btnObjectRefresh.Text = "Refresh List"
        '
        'lblObjectCountNum
        '
        lblObjectCountNum.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        lblObjectCountNum.Location = New System.Drawing.Point(472, 29)
        lblObjectCountNum.Name = "lblObjectCountNum"
        lblObjectCountNum.Size = New System.Drawing.Size(32, 23)
        lblObjectCountNum.TabIndex = 5
        '
        'lblObjectCount
        '
        lblObjectCount.Location = New System.Drawing.Point(400, 32)
        lblObjectCount.Name = "lblObjectCount"
        lblObjectCount.Size = New System.Drawing.Size(72, 16)
        lblObjectCount.TabIndex = 4
        lblObjectCount.Text = "Object Count"
        '
        'lblObjectTypeString
        '
        lblObjectTypeString.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        lblObjectTypeString.Location = New System.Drawing.Point(296, 29)
        lblObjectTypeString.Name = "lblObjectTypeString"
        lblObjectTypeString.Size = New System.Drawing.Size(88, 23)
        lblObjectTypeString.TabIndex = 3
        '
        'lblObjectType
        '
        lblObjectType.Location = New System.Drawing.Point(224, 32)
        lblObjectType.Name = "lblObjectType"
        lblObjectType.Size = New System.Drawing.Size(72, 16)
        lblObjectType.TabIndex = 2
        lblObjectType.Text = "Object Type"
        '
        'cmbDASObjects
        '
        cmbDASObjects.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        cmbDASObjects.Location = New System.Drawing.Point(104, 30)
        cmbDASObjects.Name = "cmbDASObjects"
        cmbDASObjects.Size = New System.Drawing.Size(112, 21)
        cmbDASObjects.TabIndex = 1
        '
        'lblDASObjects
        '
        lblDASObjects.Location = New System.Drawing.Point(16, 32)
        lblDASObjects.Name = "lblDASObjects"
        lblDASObjects.Size = New System.Drawing.Size(88, 16)
        lblDASObjects.TabIndex = 0
        lblDASObjects.Text = "DAS Objects"
        '
        'grpRecordLog
        '
        grpRecordLog.Controls.Add(lbRecordLog)
        grpRecordLog.Location = New System.Drawing.Point(16, 168)
        grpRecordLog.Name = "grpRecordLog"
        grpRecordLog.Size = New System.Drawing.Size(520, 240)
        grpRecordLog.TabIndex = 23
        grpRecordLog.TabStop = False
        grpRecordLog.Text = "Record Log"
        '
        'lbRecordLog
        '
        lbRecordLog.Location = New System.Drawing.Point(8, 16)
        lbRecordLog.Name = "lbRecordLog"
        lbRecordLog.Size = New System.Drawing.Size(504, 212)
        lbRecordLog.TabIndex = 0
        '
        'NetComExampleStreamsForm
        '
        AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        ClientSize = New System.Drawing.Size(552, 422)
        Controls.Add(grpRecordLog)
        Controls.Add(grpStreamProps)
        Controls.Add(lblServerNameComment)
        Controls.Add(txtServerName)
        Controls.Add(btnDisconnect)
        Controls.Add(btnConnect)
        Controls.Add(lblServerName)
        FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Name = "NetComExampleStreamsForm"
        Text = "NetCom Example - Streams"
        grpStreamProps.ResumeLayout(False)
        grpRecordLog.ResumeLayout(False)
        ResumeLayout(False)

    End Sub

#End Region

#Region "UI Helpers"
    Private Sub RecordLogUpdate(ByRef updateText As String)
        lbRecordLog.Items.Add(updateText)
        lbRecordLog.SelectedItem = updateText
    End Sub

    Private Function GetAndUpdateDASObjectsAndTypes() As Boolean
        'reset the DAS lists
        cmbDASObjects.Items.Clear()
        mDASObjectList = New List(Of String)
        mDASTypesList = New List(Of String)

        Dim objectList As List(Of String) = New List(Of String)
        Dim typeList As List(Of String) = New List(Of String)

        If mNetComClient.GetDASObjectsAndTypes(objectList, typeList) Then
            'Cheetah 5.7.0 and Pegasus 2.0.0 added the DAS type AcqSource which can not
            'stream data. We will not add them to the streaming list.
            'load all object names into the combo box
            For objectIndex As Int32 = 0 To typeList.Count - 1
                If Not String.Compare(typeList.Item(objectIndex), MNetCom.DASObjectType.AcqSource) = 0 Then
                    mDASObjectList.Add(objectList.Item(objectIndex))
                    mDASTypesList.Add(typeList.Item(objectIndex))
                End If
            Next

            For Each dasObject As String In mDASObjectList
                cmbDASObjects.Items.Add(dasObject)
            Next

            'select the first object in the combo box, and update the ui
            If mDASObjectList.Count > 0 Then
                cmbDASObjects.SelectedIndex = 0
                lblObjectTypeString.Text = CType(mDASTypesList.Item(0), String)
                lblObjectCountNum.Text = mDASObjectList.Count.ToString()
            End If
        Else

            MessageBox.Show(Me, "Retrieval of DAS objects and types failed.  List must be refreshed.", "NetCom Error",
                            MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
            Return False
        End If

        Return True
    End Function

#End Region

#Region "UI Event Handlers"
    Private Sub btnConnect_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnConnect.Click
        If Not mNetComClient.AreWeConnected Then
            If mNetComClient.ConnectToServer(txtServerName.Text) Then
                mNetComClient.SetApplicationName("NetCom Streams Example")

                'change ui to show connected status
                txtServerName.Enabled = False
                btnConnect.Enabled = False
                btnDisconnect.Enabled = True
                grpRecordLog.Enabled = True
                grpStreamProps.Enabled = True

                If GetAndUpdateDASObjectsAndTypes() = False Then
                    Return
                End If
            Else
                MessageBox.Show(Me, "Connection to server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
            End If
        End If
    End Sub

    Private Sub btnDisconnect_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDisconnect.Click
        If mNetComClient.AreWeConnected Then
            If mNetComClient.DisconnectFromServer Then
                'change ui to show disconnected status
                txtServerName.Enabled = True
                btnConnect.Enabled = True
                btnDisconnect.Enabled = False
                cmbDASObjects.Items.Clear()
                lbRecordLog.Items.Clear()
                lblObjectCountNum.Text = ""
                lblObjectTypeString.Text = ""
                grpRecordLog.Enabled = False
                grpStreamProps.Enabled = False
            Else
                MessageBox.Show(Me, "Disconnection from server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
            End If
        End If
    End Sub

    Private Sub btnObjectRefresh_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnObjectRefresh.Click
        GetAndUpdateDASObjectsAndTypes()
    End Sub

    Private Sub btnOpenStream_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnOpenStream.Click

        Dim curIndex As Integer = cmbDASObjects.SelectedIndex
        'ensure something is selected to open
        If curIndex = -1 Then
            MessageBox.Show(Me, "No object selected for stream open", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
            Return
        End If

        'get the strings from the object list
        Dim curDASObject As String = CType(mDASObjectList.Item(curIndex), String)
        Dim curDASType As String = CType(mDASTypesList.Item(curIndex), String)

        If Not (mNetComClient.OpenStream(curDASObject)) Then
            MessageBox.Show(Me, "Could not open stream for ObjectName: " & curDASObject & " Type: " & curDASType, "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
        End If

    End Sub

    Private Sub btnCloseStream_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCloseStream.Click

        Dim curIndex As Integer = cmbDASObjects.SelectedIndex

        'ensure something is selected to close
        If curIndex = -1 Then
            MessageBox.Show(Me, "No object selected for stream close", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
            Return
        End If

        'get the strings from the object list
        Dim curDASObject As String = CType(mDASObjectList.Item(curIndex), String)
        Dim curDASType As String = CType(mDASTypesList.Item(curIndex), String)

        If Not (mNetComClient.CloseStream(curDASObject)) Then
            MessageBox.Show(Me, "Could not close stream for ObjectName: " & curDASObject & " Type: " & curDASType, "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1)
        End If
    End Sub

    Private Sub cmbDASObjects_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmbDASObjects.SelectedIndexChanged
        Dim curIndex As Integer = cmbDASObjects.SelectedIndex
        If curIndex = -1 Then
            Return
        Else
            lblObjectTypeString.Text = CType(mDASTypesList(curIndex), String)
        End If

    End Sub
#End Region

#Region "NetCom Callback Functions"
    Private Sub NetComCallbackSE(ByVal sender As Object, ByVal records As MNetCom.MSERec, ByVal numRecords As Integer, ByVal objectName As String)


        'since we passed the Me pointer to the callback object, we can assume that the sender
        'is of type NetComExampleStreamsForm.  
        Dim thisClass As NetComExampleStreamsForm = CType(sender, NetComExampleStreamsForm)

        'add the object name to the textbox
        Dim msgString As String
        msgString = "Received SE Record For: " & objectName & " at DAS TS " & records.qwTimeStamp.ToString()

        Dim RecordLogUpdateDelegate As New AsyncRecordLogUpdate(AddressOf RecordLogUpdate)
        lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, New Object() {msgString})

    End Sub

    Private Sub NetComCallbackST(ByVal sender As Object, ByVal records As MNetCom.MSTRec, ByVal numRecords As Integer, ByVal objectName As String)


        'since we passed the Me pointer to the callback object, we can assume that the sender
        'is of type NetComExampleStreamsForm.  
        Dim thisClass As NetComExampleStreamsForm = CType(sender, NetComExampleStreamsForm)

        'add the object name to the textbox
        Dim msgString As String
        msgString = "Received ST Record For: " & objectName & " at DAS TS " & records.qwTimeStamp.ToString()

        Dim RecordLogUpdateDelegate As New AsyncRecordLogUpdate(AddressOf RecordLogUpdate)
        lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, New Object() {msgString})

    End Sub

    Private Sub NetComCallbackTT(ByVal sender As Object, ByVal records As MNetCom.MTTRec, ByVal numRecords As Integer, ByVal objectName As String)


        'since we passed the Me pointer to the callback object, we can assume that the sender
        'is of type NetComExampleStreamsForm.  
        Dim thisClass As NetComExampleStreamsForm = CType(sender, NetComExampleStreamsForm)

        'add the object name to the textbox
        Dim msgString As String
        msgString = "Received TT Record For: " & objectName & " at DAS TS " & records.qwTimeStamp.ToString()

        Dim RecordLogUpdateDelegate As New AsyncRecordLogUpdate(AddressOf RecordLogUpdate)
        lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, New Object() {msgString})

    End Sub

    Private Sub NetComCallbackCSC(ByVal sender As Object, ByVal records As MNetCom.MCRRec, ByVal numRecords As Integer, ByVal objectName As String)


        'since we passed the Me pointer to the callback object, we can assume that the sender
        'is of type NetComExampleStreamsForm.  
        Dim thisClass As NetComExampleStreamsForm = CType(sender, NetComExampleStreamsForm)

        'add the object name to the textbox
        Dim msgString As String
        msgString = "Received CSC Record For: " & objectName & " at DAS TS " & records.qwTimeStamp.ToString()

        Dim RecordLogUpdateDelegate As New AsyncRecordLogUpdate(AddressOf RecordLogUpdate)
        lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, New Object() {msgString})

    End Sub

    Private Sub NetComCallbackEV(ByVal sender As Object, ByVal records As MNetCom.MEventRec, ByVal numRecords As Integer, ByVal objectName As String)


        'since we passed the Me pointer to the callback object, we can assume that the sender
        'is of type NetComExampleStreamsForm.  
        Dim thisClass As NetComExampleStreamsForm = CType(sender, NetComExampleStreamsForm)

        'add the object name to the textbox
        Dim msgString As String
        msgString = "Received Event Record For: " & objectName & " at DAS TS " & records.qwTimeStamp.ToString()

        Dim RecordLogUpdateDelegate As New AsyncRecordLogUpdate(AddressOf RecordLogUpdate)
        lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, New Object() {msgString})

    End Sub

    Private Sub NetComCallbackVT(ByVal sender As Object, ByVal records As MNetCom.MVideoRec, ByVal numRecords As Integer, ByVal objectName As String)


        'since we passed the Me pointer to the callback object, we can assume that the sender
        'is of type NetComExampleStreamsForm.  
        Dim thisClass As NetComExampleStreamsForm = CType(sender, NetComExampleStreamsForm)

        'add the object name to the textbox
        Dim msgString As String
        msgString = "Received Video Record For: " & objectName & " at DAS TS " & records.qwTimeStamp.ToString()

        Dim RecordLogUpdateDelegate As New AsyncRecordLogUpdate(AddressOf RecordLogUpdate)
        lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, New Object() {msgString})

    End Sub
#End Region

    
End Class
