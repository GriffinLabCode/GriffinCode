//**********************************************
//	NetComExampleCommandsForm.cs
//	Copyright 2016 @ Neuralynx, Inc
//**********************************************
using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace NetComExampleCommands
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class NetComExampleCommandsForm : System.Windows.Forms.Form
	{
		#region UI Members
        internal System.Windows.Forms.Panel pnlCommands;
			internal System.Windows.Forms.Label lblCommandList;
			internal System.Windows.Forms.Button btnSendCommand;
			internal System.Windows.Forms.ComboBox cmbCommandList;
			internal System.Windows.Forms.Label lblServerNameComment;
			internal System.Windows.Forms.TextBox txtServerName;
			internal System.Windows.Forms.Button btnDisconnect;
			internal System.Windows.Forms.Button btnConnect;
			internal System.Windows.Forms.Label lblServerName;
		#endregion

		#region Private Members
			private MNetCom.MNetComClient mNetComClient;
		#endregion
            private Label lblReplyStringValue;
            private Label lblReplyStringLabel;


		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		#region Constructor
			public NetComExampleCommandsForm()
			{
				//initialize class vars
				this.mNetComClient = new MNetCom.MNetComClient();

				//
				// Required for Windows Form Designer support
				//
				InitializeComponent();

				//
				// TODO: Add any constructor code after InitializeComponent call
				//

				//extra UI setup
				this.cmbCommandList.SelectedIndex = 0;
				this.btnDisconnect.Enabled = false;
				this.pnlCommands.Enabled = false;
				
				//Set the logfile name
				if (!(this.mNetComClient.SetLogFileName(Application.StartupPath.ToString() + "\\NetComExampleCommandsLogfile.txt")))
				{
					   MessageBox.Show(this, "Call to set the logfile name failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
				}

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
            this.pnlCommands = new System.Windows.Forms.Panel();
            this.lblCommandList = new System.Windows.Forms.Label();
            this.btnSendCommand = new System.Windows.Forms.Button();
            this.cmbCommandList = new System.Windows.Forms.ComboBox();
            this.lblServerNameComment = new System.Windows.Forms.Label();
            this.txtServerName = new System.Windows.Forms.TextBox();
            this.btnDisconnect = new System.Windows.Forms.Button();
            this.btnConnect = new System.Windows.Forms.Button();
            this.lblServerName = new System.Windows.Forms.Label();
            this.lblReplyStringLabel = new System.Windows.Forms.Label();
            this.lblReplyStringValue = new System.Windows.Forms.Label();
            this.pnlCommands.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlCommands
            // 
            this.pnlCommands.Controls.Add(this.lblReplyStringValue);
            this.pnlCommands.Controls.Add(this.lblReplyStringLabel);
            this.pnlCommands.Controls.Add(this.lblCommandList);
            this.pnlCommands.Controls.Add(this.btnSendCommand);
            this.pnlCommands.Controls.Add(this.cmbCommandList);
            this.pnlCommands.Location = new System.Drawing.Point(16, 64);
            this.pnlCommands.Name = "pnlCommands";
            this.pnlCommands.Size = new System.Drawing.Size(488, 65);
            this.pnlCommands.TabIndex = 12;
            // 
            // lblCommandList
            // 
            this.lblCommandList.Location = new System.Drawing.Point(-3, 16);
            this.lblCommandList.Name = "lblCommandList";
            this.lblCommandList.Size = new System.Drawing.Size(93, 21);
            this.lblCommandList.TabIndex = 24;
            this.lblCommandList.Text = "Command List";
            this.lblCommandList.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // btnSendCommand
            // 
            this.btnSendCommand.Location = new System.Drawing.Point(392, 17);
            this.btnSendCommand.Name = "btnSendCommand";
            this.btnSendCommand.Size = new System.Drawing.Size(96, 23);
            this.btnSendCommand.TabIndex = 23;
            this.btnSendCommand.Text = "Send Command";
            this.btnSendCommand.Click += new System.EventHandler(this.btnSendCommand_Click);
            // 
            // cmbCommandList
            // 
            this.cmbCommandList.Items.AddRange(new object[] {
            "-PostEvent \"Test Event\" 0 0",
            "-StartAcquisition"});
            this.cmbCommandList.Location = new System.Drawing.Point(96, 17);
            this.cmbCommandList.Name = "cmbCommandList";
            this.cmbCommandList.Size = new System.Drawing.Size(288, 21);
            this.cmbCommandList.TabIndex = 22;
            // 
            // lblServerNameComment
            // 
            this.lblServerNameComment.Location = new System.Drawing.Point(112, 40);
            this.lblServerNameComment.Name = "lblServerNameComment";
            this.lblServerNameComment.Size = new System.Drawing.Size(208, 16);
            this.lblServerNameComment.TabIndex = 11;
            this.lblServerNameComment.Text = "(User may enter pc name or IP address)";
            // 
            // txtServerName
            // 
            this.txtServerName.Location = new System.Drawing.Point(96, 16);
            this.txtServerName.Name = "txtServerName";
            this.txtServerName.Size = new System.Drawing.Size(232, 20);
            this.txtServerName.TabIndex = 10;
            // 
            // btnDisconnect
            // 
            this.btnDisconnect.Location = new System.Drawing.Point(432, 16);
            this.btnDisconnect.Name = "btnDisconnect";
            this.btnDisconnect.Size = new System.Drawing.Size(75, 23);
            this.btnDisconnect.TabIndex = 9;
            this.btnDisconnect.Text = "Disconnect";
            this.btnDisconnect.Click += new System.EventHandler(this.btnDisconnect_Click);
            // 
            // btnConnect
            // 
            this.btnConnect.Location = new System.Drawing.Point(344, 16);
            this.btnConnect.Name = "btnConnect";
            this.btnConnect.Size = new System.Drawing.Size(75, 23);
            this.btnConnect.TabIndex = 8;
            this.btnConnect.Text = "Connect";
            this.btnConnect.Click += new System.EventHandler(this.btnConnect_Click);
            // 
            // lblServerName
            // 
            this.lblServerName.Location = new System.Drawing.Point(16, 16);
            this.lblServerName.Name = "lblServerName";
            this.lblServerName.Size = new System.Drawing.Size(72, 16);
            this.lblServerName.TabIndex = 7;
            this.lblServerName.Text = "Server Name";
            // 
            // lblReplyStringLabel
            // 
            this.lblReplyStringLabel.AutoSize = true;
            this.lblReplyStringLabel.Location = new System.Drawing.Point(26, 45);
            this.lblReplyStringLabel.Name = "lblReplyStringLabel";
            this.lblReplyStringLabel.Size = new System.Drawing.Size(64, 13);
            this.lblReplyStringLabel.TabIndex = 25;
            this.lblReplyStringLabel.Text = "Reply String";
            this.lblReplyStringLabel.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lblReplyStringValue
            // 
            this.lblReplyStringValue.AutoSize = true;
            this.lblReplyStringValue.Location = new System.Drawing.Point(96, 45);
            this.lblReplyStringValue.Name = "lblReplyStringValue";
            this.lblReplyStringValue.Size = new System.Drawing.Size(10, 13);
            this.lblReplyStringValue.TabIndex = 26;
            this.lblReplyStringValue.Text = " ";
            this.lblReplyStringValue.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // NetComExampleCommandsForm
            // 
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.ClientSize = new System.Drawing.Size(520, 133);
            this.Controls.Add(this.pnlCommands);
            this.Controls.Add(this.lblServerNameComment);
            this.Controls.Add(this.txtServerName);
            this.Controls.Add(this.btnDisconnect);
            this.Controls.Add(this.btnConnect);
            this.Controls.Add(this.lblServerName);
            this.Name = "NetComExampleCommandsForm";
            this.Text = "NetCom Examples - Commands";
            this.pnlCommands.ResumeLayout(false);
            this.pnlCommands.PerformLayout();
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
			Application.Run(new NetComExampleCommandsForm());
		}

		#region UI Event Handlers
		//**************************************************************
		//**************************************************************
		private void btnConnect_Click(object sender, System.EventArgs e)
		{
			if (!( this.mNetComClient.AreWeConnected()))
			{
				if (this.mNetComClient.ConnectToServer(this.txtServerName.Text))
				{
					this.mNetComClient.SetApplicationName("NetCom Commands Example");

					//change ui to show connected status
					this.txtServerName.Enabled = false;
					this.btnConnect.Enabled = false;
					this.btnDisconnect.Enabled = true;
					this.pnlCommands.Enabled = true;
				}
				else
				{
					MessageBox.Show(this, "Connection to server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
				}
			}
		}

		//**************************************************************
		//**************************************************************
		private void btnDisconnect_Click(object sender, System.EventArgs e)
		{
			if (this.mNetComClient.AreWeConnected())
			{
				if ( this.mNetComClient.DisconnectFromServer() )
				{
					//change ui to show disconnected status
					this.txtServerName.Enabled = true;
					this.btnConnect.Enabled = true;
					this.btnDisconnect.Enabled = false;
					this.pnlCommands.Enabled = false;
				}
				else
				{
					MessageBox.Show(this, "Disconnection from server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
				}
			}
		}

		//**************************************************************
		//**************************************************************
		private void btnSendCommand_Click(object sender, System.EventArgs e)
		{
			string reply = "";
			if (!(mNetComClient.SendCommand(this.cmbCommandList.Text, ref reply)))
			{
				MessageBox.Show(this, "Send command to server failed", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
			}else {
                String[] parsedReplyString = reply.Split(' ');
                if (0 < parsedReplyString.GetLength(0)) {
                    if( parsedReplyString[0].Equals( "-1" )){
                        MessageBox.Show(this, "Cheetah could not process your command.", "NetCom Error", MessageBoxButtons.OK, MessageBoxIcon.Error, MessageBoxDefaultButton.Button1);
                    }
                }
                this.lblReplyStringValue.Text = reply;
            }
		
		}

		#endregion

	}
}
