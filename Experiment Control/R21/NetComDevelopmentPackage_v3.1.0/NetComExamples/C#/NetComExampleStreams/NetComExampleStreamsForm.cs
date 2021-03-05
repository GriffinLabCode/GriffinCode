//**********************************************
//	NetComExampleStreamsForm.cs
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace NetComExampleStreams
{
	public class NetComExampleStreamsForm : System.Windows.Forms.Form
	{
		#region UI Members
		internal System.Windows.Forms.Label lblServerName;
		internal System.Windows.Forms.GroupBox grpStreamProps;
		internal System.Windows.Forms.Button btnCloseStream;
		internal System.Windows.Forms.Button btnOpenStream;
		internal System.Windows.Forms.Button btnObjectRefresh;
		internal System.Windows.Forms.Label lblObjectCountNum;
		internal System.Windows.Forms.Label lblObjectCount;
		internal System.Windows.Forms.Label lblObjectTypeString;
		internal System.Windows.Forms.Label lblObjectType;
		internal System.Windows.Forms.ComboBox cmbDASObjects;
		internal System.Windows.Forms.Label lblDASObjects;
		internal System.Windows.Forms.Label lblServerNameComment;
		internal System.Windows.Forms.TextBox txtServerName;
		internal System.Windows.Forms.Button btnDisconnect;
		internal System.Windows.Forms.Button btnConnect;
		internal System.Windows.Forms.GroupBox grpRecordLog;
		internal System.Windows.Forms.ListBox lbRecordLog;
		#endregion

		#region Private Members
		//netcom client
		private MNetCom.MNetComClient mNetComClient;
		
		//callback delegates
		private MNetCom.MNC_SECallback mNetcomSECallback;
		private MNetCom.MNC_STCallback mNetcomSTCallback;
		private MNetCom.MNC_TTCallback mNetcomTTCallback;
		private MNetCom.MNC_CSCCallback mNetcomCSCCallback;
		private MNetCom.MNC_EVCallback mNetcomEVCallback;
		private MNetCom.MNC_VTCallback mNetcomVTCallback; 
		
		//Needed for proper UI updating in a multi-threaded application
		private delegate void AsyncRecordLogUpdate(String updateText);

		//cheetah object list holders
		private List<String> mDASObjectList;
		private List<String> mDASTypesList;
		#endregion

		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		#region Constructor
		public NetComExampleStreamsForm()
		{
			//initialize class vars
			mNetComClient = new MNetCom.MNetComClient();

			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
			//extra UI setup
			btnDisconnect.Enabled = false;
			grpRecordLog.Enabled = false;
			grpStreamProps.Enabled = false;

			//Set the log file name
			if (( mNetComClient.SetLogFileName(Application.StartupPath.ToString() + "\\NetComExampleStreamsLogfile.txt") ) == false )
			{
				MessageBox.Show(this, "Call to set the log file name failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
			}

			//register the callback functions
			mNetcomSECallback = new MNetCom.MNC_SECallback(NetComCallbackSE);
			mNetComClient.SetCallbackFunctionSE(mNetcomSECallback, this);
			mNetcomSTCallback = new MNetCom.MNC_STCallback(NetComCallbackST);
			mNetComClient.SetCallbackFunctionST(mNetcomSTCallback, this);
			mNetcomTTCallback = new MNetCom.MNC_TTCallback( NetComCallbackTT);
			mNetComClient.SetCallbackFunctionTT(mNetcomTTCallback, this);
			mNetcomCSCCallback = new MNetCom.MNC_CSCCallback( NetComCallbackCSC);
			mNetComClient.SetCallbackFunctionCSC(mNetcomCSCCallback, this);
			mNetcomEVCallback = new MNetCom.MNC_EVCallback( NetComCallbackEV);
			mNetComClient.SetCallbackFunctionEV(mNetcomEVCallback, this);
			mNetcomVTCallback = new MNetCom.MNC_VTCallback( NetComCallbackVT);
			mNetComClient.SetCallbackFunctionVT(mNetcomVTCallback, this);
		}

		#endregion

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
            this.lblServerName = new System.Windows.Forms.Label();
            this.grpStreamProps = new System.Windows.Forms.GroupBox();
            this.btnCloseStream = new System.Windows.Forms.Button();
            this.btnOpenStream = new System.Windows.Forms.Button();
            this.btnObjectRefresh = new System.Windows.Forms.Button();
            this.lblObjectCountNum = new System.Windows.Forms.Label();
            this.lblObjectCount = new System.Windows.Forms.Label();
            this.lblObjectTypeString = new System.Windows.Forms.Label();
            this.lblObjectType = new System.Windows.Forms.Label();
            this.cmbDASObjects = new System.Windows.Forms.ComboBox();
            this.lblDASObjects = new System.Windows.Forms.Label();
            this.lblServerNameComment = new System.Windows.Forms.Label();
            this.txtServerName = new System.Windows.Forms.TextBox();
            this.btnDisconnect = new System.Windows.Forms.Button();
            this.btnConnect = new System.Windows.Forms.Button();
            this.grpRecordLog = new System.Windows.Forms.GroupBox();
            this.lbRecordLog = new System.Windows.Forms.ListBox();
            this.grpStreamProps.SuspendLayout();
            this.grpRecordLog.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblServerName
            // 
            this.lblServerName.Location = new System.Drawing.Point(16, 10);
            this.lblServerName.Name = "lblServerName";
            this.lblServerName.Size = new System.Drawing.Size(72, 16);
            this.lblServerName.TabIndex = 24;
            this.lblServerName.Text = "Server Name";
            // 
            // grpStreamProps
            // 
            this.grpStreamProps.Controls.Add(this.btnCloseStream);
            this.grpStreamProps.Controls.Add(this.btnOpenStream);
            this.grpStreamProps.Controls.Add(this.btnObjectRefresh);
            this.grpStreamProps.Controls.Add(this.lblObjectCountNum);
            this.grpStreamProps.Controls.Add(this.lblObjectCount);
            this.grpStreamProps.Controls.Add(this.lblObjectTypeString);
            this.grpStreamProps.Controls.Add(this.lblObjectType);
            this.grpStreamProps.Controls.Add(this.cmbDASObjects);
            this.grpStreamProps.Controls.Add(this.lblDASObjects);
            this.grpStreamProps.Location = new System.Drawing.Point(16, 64);
            this.grpStreamProps.Name = "grpStreamProps";
            this.grpStreamProps.Size = new System.Drawing.Size(520, 88);
            this.grpStreamProps.TabIndex = 29;
            this.grpStreamProps.TabStop = false;
            this.grpStreamProps.Text = "Stream Properties";
            // 
            // btnCloseStream
            // 
            this.btnCloseStream.Location = new System.Drawing.Point(192, 56);
            this.btnCloseStream.Name = "btnCloseStream";
            this.btnCloseStream.Size = new System.Drawing.Size(88, 23);
            this.btnCloseStream.TabIndex = 8;
            this.btnCloseStream.Text = "Close Stream";
            this.btnCloseStream.Click += new System.EventHandler(this.btnCloseStream_Click);
            // 
            // btnOpenStream
            // 
            this.btnOpenStream.Location = new System.Drawing.Point(104, 56);
            this.btnOpenStream.Name = "btnOpenStream";
            this.btnOpenStream.Size = new System.Drawing.Size(80, 23);
            this.btnOpenStream.TabIndex = 7;
            this.btnOpenStream.Text = "Open Stream";
            this.btnOpenStream.Click += new System.EventHandler(this.btnOpenStream_Click);
            // 
            // btnObjectRefresh
            // 
            this.btnObjectRefresh.Location = new System.Drawing.Point(16, 56);
            this.btnObjectRefresh.Name = "btnObjectRefresh";
            this.btnObjectRefresh.Size = new System.Drawing.Size(80, 23);
            this.btnObjectRefresh.TabIndex = 6;
            this.btnObjectRefresh.Text = "Refresh List";
            this.btnObjectRefresh.Click += new System.EventHandler(this.btnObjectRefresh_Click);
            // 
            // lblObjectCountNum
            // 
            this.lblObjectCountNum.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.lblObjectCountNum.Location = new System.Drawing.Point(472, 29);
            this.lblObjectCountNum.Name = "lblObjectCountNum";
            this.lblObjectCountNum.Size = new System.Drawing.Size(32, 23);
            this.lblObjectCountNum.TabIndex = 5;
            // 
            // lblObjectCount
            // 
            this.lblObjectCount.Location = new System.Drawing.Point(400, 32);
            this.lblObjectCount.Name = "lblObjectCount";
            this.lblObjectCount.Size = new System.Drawing.Size(72, 16);
            this.lblObjectCount.TabIndex = 4;
            this.lblObjectCount.Text = "Object Count";
            // 
            // lblObjectTypeString
            // 
            this.lblObjectTypeString.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.lblObjectTypeString.Location = new System.Drawing.Point(296, 29);
            this.lblObjectTypeString.Name = "lblObjectTypeString";
            this.lblObjectTypeString.Size = new System.Drawing.Size(88, 23);
            this.lblObjectTypeString.TabIndex = 3;
            // 
            // lblObjectType
            // 
            this.lblObjectType.Location = new System.Drawing.Point(224, 32);
            this.lblObjectType.Name = "lblObjectType";
            this.lblObjectType.Size = new System.Drawing.Size(72, 16);
            this.lblObjectType.TabIndex = 2;
            this.lblObjectType.Text = "Object Type";
            // 
            // cmbDASObjects
            // 
            this.cmbDASObjects.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbDASObjects.Location = new System.Drawing.Point(104, 30);
            this.cmbDASObjects.Name = "cmbDASObjects";
            this.cmbDASObjects.Size = new System.Drawing.Size(112, 21);
            this.cmbDASObjects.TabIndex = 1;
            this.cmbDASObjects.SelectedIndexChanged += new System.EventHandler(this.cmbDASObjects_SelectedIndexChanged);
            // 
            // lblDASObjects
            // 
            this.lblDASObjects.Location = new System.Drawing.Point(16, 32);
            this.lblDASObjects.Name = "lblDASObjects";
            this.lblDASObjects.Size = new System.Drawing.Size(88, 16);
            this.lblDASObjects.TabIndex = 0;
            this.lblDASObjects.Text = "DAS Objects";
            // 
            // lblServerNameComment
            // 
            this.lblServerNameComment.Location = new System.Drawing.Point(125, 32);
            this.lblServerNameComment.Name = "lblServerNameComment";
            this.lblServerNameComment.Size = new System.Drawing.Size(223, 16);
            this.lblServerNameComment.TabIndex = 28;
            this.lblServerNameComment.Text = "(User may enter PC name or IP address)";
            // 
            // txtServerName
            // 
            this.txtServerName.Location = new System.Drawing.Point(96, 8);
            this.txtServerName.Name = "txtServerName";
            this.txtServerName.Size = new System.Drawing.Size(280, 20);
            this.txtServerName.TabIndex = 27;
            // 
            // btnDisconnect
            // 
            this.btnDisconnect.Location = new System.Drawing.Point(464, 7);
            this.btnDisconnect.Name = "btnDisconnect";
            this.btnDisconnect.Size = new System.Drawing.Size(75, 23);
            this.btnDisconnect.TabIndex = 26;
            this.btnDisconnect.Text = "Disconnect";
            this.btnDisconnect.Click += new System.EventHandler(this.btnDisconnect_Click);
            // 
            // btnConnect
            // 
            this.btnConnect.Location = new System.Drawing.Point(384, 7);
            this.btnConnect.Name = "btnConnect";
            this.btnConnect.Size = new System.Drawing.Size(75, 23);
            this.btnConnect.TabIndex = 25;
            this.btnConnect.Text = "Connect";
            this.btnConnect.Click += new System.EventHandler(this.btnConnect_Click);
            // 
            // grpRecordLog
            // 
            this.grpRecordLog.Controls.Add(this.lbRecordLog);
            this.grpRecordLog.Location = new System.Drawing.Point(16, 168);
            this.grpRecordLog.Name = "grpRecordLog";
            this.grpRecordLog.Size = new System.Drawing.Size(520, 240);
            this.grpRecordLog.TabIndex = 30;
            this.grpRecordLog.TabStop = false;
            this.grpRecordLog.Text = "Record Log";
            // 
            // lbRecordLog
            // 
            this.lbRecordLog.Location = new System.Drawing.Point(8, 16);
            this.lbRecordLog.Name = "lbRecordLog";
            this.lbRecordLog.Size = new System.Drawing.Size(504, 212);
            this.lbRecordLog.TabIndex = 0;
            // 
            // NetComExampleStreamsForm
            // 
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.ClientSize = new System.Drawing.Size(552, 422);
            this.Controls.Add(this.lblServerName);
            this.Controls.Add(this.grpStreamProps);
            this.Controls.Add(this.lblServerNameComment);
            this.Controls.Add(this.txtServerName);
            this.Controls.Add(this.btnDisconnect);
            this.Controls.Add(this.btnConnect);
            this.Controls.Add(this.grpRecordLog);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "NetComExampleStreamsForm";
            this.Text = "NetCom Example - Streams";
            this.grpStreamProps.ResumeLayout(false);
            this.grpRecordLog.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new NetComExampleStreamsForm());
		}

		#region UI Helper Functions

		//********************************************************************************************************************
		private void RecordLogUpdate(String updateText) 
		{
			lbRecordLog.Items.Add(updateText);
			lbRecordLog.SelectedItem = updateText;
		}

        private bool GetAndUpdateDASObjectsAndTypes()
        {
            //reset the array lists
            mDASObjectList = new List<String>();
            mDASTypesList = new List<String>();

            var dasObjects = new List<String>();
            var dasTypes = new List<String>();
            if (mNetComClient.GetDASObjectsAndTypes(ref dasObjects, ref dasTypes) == false)
            {
                MessageBox.Show(this, "Retrieval of DAS objects and types failed.  List must be refreshed.", "NetCom Error",
                    MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
            }

            //Cheetah 5.7.0 and Pegasus 2.0.0 introduced the AcqSource object type
            //which can not stream data. We will not add any AcqSource objects to
            //the object list
            for (int objectIndex = 0; objectIndex < dasTypes.Count; ++objectIndex)
            {
                if (String.Compare(dasTypes[objectIndex], MNetCom.DASObjectType.AcqSource) != 0)
                {
                    mDASObjectList.Add(dasObjects[objectIndex]);
                    mDASTypesList.Add(dasTypes[objectIndex]);
                }
            }

            cmbDASObjects.Items.Clear();
            foreach (string objectName in mDASObjectList)
            {
                cmbDASObjects.Items.Add(objectName);
            }


            //select the first object in the combo box, and update the ui
            if (mDASObjectList.Count > 0)
            {
                cmbDASObjects.SelectedIndex = 0;
                lblObjectTypeString.Text = (string)mDASTypesList[0];
                lblObjectCountNum.Text = mDASObjectList.Count.ToString();
            }
            else
            {
                MessageBox.Show(this, "DAS does not contain any objects.", "NetCom Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
                return false;
            }
            return true;
        }

#endregion

		#region UI Event Handlers

		private void btnConnect_Click(object sender, System.EventArgs e)
		{
			if (mNetComClient.AreWeConnected() == false)
			{
                if (mNetComClient.ConnectToServer(txtServerName.Text))
                {
                    mNetComClient.SetApplicationName("NetCom Streams Example");

                    //change ui to show connected status
                    txtServerName.Enabled = false;
                    btnConnect.Enabled = false;
                    btnDisconnect.Enabled = true;
                    grpRecordLog.Enabled = true;
                    grpStreamProps.Enabled = true;

                    if (GetAndUpdateDASObjectsAndTypes())
                    {
                        return;
                    }

                }
                else
                {
                    MessageBox.Show(this, "Connection to server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
                }		
			}
		}

		private void btnDisconnect_Click(object sender, System.EventArgs e)
		{
			if (mNetComClient.AreWeConnected())
			{
				if ( mNetComClient.DisconnectFromServer() )
				{
					//change ui to show disconnected status
					txtServerName.Enabled = true;
					btnConnect.Enabled = true;
					btnDisconnect.Enabled = false;
					cmbDASObjects.Items.Clear();
					lbRecordLog.Items.Clear();
					lblObjectCountNum.Text = "";
					lblObjectTypeString.Text = "";
					grpRecordLog.Enabled = false;
					grpStreamProps.Enabled = false;
				}
				else
				{
					MessageBox.Show(this, "Disconnection from server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
				}
			}
		}

		private void btnObjectRefresh_Click(object sender, System.EventArgs e)
		{
	        if (GetAndUpdateDASObjectsAndTypes())
            {
                return;
            }

        }

		//**************************************************************
		//**************************************************************
		private void btnOpenStream_Click(object sender, System.EventArgs e)
		{
			int curIndex = cmbDASObjects.SelectedIndex;
			//ensure something is selected to open
			if ( curIndex == -1)
			{
				MessageBox.Show(this, "No object selected for stream open", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
					return;
			}

			//get the strings from the object list
			string curDASObject = (string)mDASObjectList[curIndex];

			if (! (mNetComClient.OpenStream(curDASObject)) )
			{
				MessageBox.Show(this, "Could not open stream for ObjectName: " + curDASObject, "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
			}
		}

		//**************************************************************
		//**************************************************************
		private void btnCloseStream_Click(object sender, System.EventArgs e)
		{
			int curIndex = cmbDASObjects.SelectedIndex;
			//ensure something is selected to close
			if ( curIndex == -1)
			{
				MessageBox.Show(this, "No object selected for stream close", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
					return;
			}

			//get the strings from the object list
			string curDASObject = (string)mDASObjectList[curIndex];

			if (! (mNetComClient.CloseStream(curDASObject)) )
			{
				MessageBox.Show(this, "Could not close stream for ObjectName: " + curDASObject, "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
			}
		
		}

		//********************************************************************************************************************
		//********************************************************************************************************************
		private void cmbDASObjects_SelectedIndexChanged(object sender, System.EventArgs e)
		{
			int curIndex = cmbDASObjects.SelectedIndex;
			if (curIndex == -1)
			{
				return;
			}
			else
			{
				lblObjectTypeString.Text = (string)mDASTypesList[curIndex];
			}
		}
		#endregion

		#region NetCom Callback Functions
		void NetComCallbackSE(Object sender, MNetCom.MSERec records, int numRecords, string objectName)
		{

            //since we passed the this pointer to the callback object, we can assume that the sender
            //is of type NetComExampleStreamsForm.  
            NetComExampleStreamsForm thisClass = (NetComExampleStreamsForm)sender;

            //add the object name to the textbox
            string msgString;
            msgString = "Received SE Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();

            // Update UI on the UI thread using delegate.
			AsyncRecordLogUpdate RecordLogUpdateDelegate = new AsyncRecordLogUpdate(RecordLogUpdate);
			lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, new Object[] {msgString});
		}

		void NetComCallbackST(Object sender, MNetCom.MSTRec records, int numRecords, string objectName)
		{

            //since we passed the this pointer to the callback object, we can assume that the sender
            //is of type NetComExampleStreamsForm.  
            NetComExampleStreamsForm thisClass = (NetComExampleStreamsForm) sender;

			//add the object name to the textbox
			string msgString;
			msgString = "Received ST Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();

			// Update UI on the UI thread using delegate.
			AsyncRecordLogUpdate RecordLogUpdateDelegate = new AsyncRecordLogUpdate(RecordLogUpdate);
			lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, new Object[] {msgString});

		}

		void NetComCallbackTT(Object sender, MNetCom.MTTRec records, int numRecords, string objectName)
		{

            //since we passed the this pointer to the callback object, we can assume that the sender
            //is of type NetComExampleStreamsForm.   
            NetComExampleStreamsForm thisClass = (NetComExampleStreamsForm) sender;

			//add the object name to the textbox
			string msgString;
			msgString = "Received TT Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();

			// Update UI on the UI thread using delegate.
			AsyncRecordLogUpdate RecordLogUpdateDelegate = new AsyncRecordLogUpdate(RecordLogUpdate);
			lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, new Object[] {msgString});		

		}

		void NetComCallbackCSC(Object sender, MNetCom.MCRRec records, int numRecords, string objectName)
		{

            //since we passed the this pointer to the callback object, we can assume that the sender
            //is of type NetComExampleStreamsForm.   
            NetComExampleStreamsForm thisClass = (NetComExampleStreamsForm) sender;

			//add the object name to the textbox
			string msgString;
			msgString = "Received CSC Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();

			// Update UI on the UI thread using delegate.
			AsyncRecordLogUpdate RecordLogUpdateDelegate = new AsyncRecordLogUpdate(RecordLogUpdate);
			lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, new Object[] {msgString});	

		}

		void NetComCallbackEV(Object sender, MNetCom.MEventRec records, int numRecords, string objectName)
		{

            //since we passed the this pointer to the callback object, we can assume that the sender
            //is of type NetComExampleStreamsForm.   
            NetComExampleStreamsForm thisClass = (NetComExampleStreamsForm) sender;

			//add the object name to the textbox
			string msgString;
			msgString = "Received Event Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString() + " with string: " + records.EventString;

			// Update UI on the UI thread using delegate.
			AsyncRecordLogUpdate RecordLogUpdateDelegate = new AsyncRecordLogUpdate(RecordLogUpdate);
			lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, new Object[] {msgString});
		}

		void NetComCallbackVT(Object sender, MNetCom.MVideoRec records, int numRecords, string objectName)
		{

            //since we passed the this pointer to the callback object, we can assume that the sender
            //is of type NetComExampleStreamsForm.   
            NetComExampleStreamsForm thisClass = (NetComExampleStreamsForm) sender;

			//add the object name to the textbox
			string msgString;
			msgString = "Received Video Record For: " + objectName + " at DAS TS " + records.qwTimeStamp.ToString();

			// Update UI on the UI thread using delegate.
			AsyncRecordLogUpdate RecordLogUpdateDelegate = new AsyncRecordLogUpdate(RecordLogUpdate);
			lbRecordLog.BeginInvoke(RecordLogUpdateDelegate, new Object[] {msgString});

		}
		#endregion

		
	}
}
