#**********************************************
# <IPyNetComClient.py>
# Copyright 2016 @ Neuralynx, Inc
#**********************************************

from System.Collections.Generic import *
from System import Convert
import clr, platform, sys

# based on systems architecture ref to dotNet DLLS
if (platform.architecture()[0] == "64bit"):
    # optional for 64bit architecture, IronPython64
    fileAndPath = "MNetComClient3_x64.dll"
    clr.AddReferenceToFileAndPath(fileAndPath)
        
else:
    fileAndPath = "MNetComClient3.dll"
    clr.AddReferenceToFileAndPath(fileAndPath)


from MNetCom import *


class IPyNetComClient(MNetComClient):
    ''' includes all the wrapper functions for MNetComClient'''

    def __new__(self):

        self = MNetComClient.__new__(self)
        # delegates for callback functions
        self.MNC_SECallback = MNC_SECallback
        self.MNC_STCallback = MNC_STCallback
        self.MNC_TTCallback = MNC_TTCallback
        self.MNC_CSCCallback = MNC_CSCCallback
        self.MNC_EVCallback = MNC_EVCallback
        self.MNC_VTCallback = MNC_VTCallback
        self.MNC_ConnectionLostCallback = MNC_ConnectionLostCallback
        self.MNC_MessageCallback = MNC_MessageCallback
        return self

    def __init__(self):
        super(IPyNetComClient, self).__init__()
        
    def areWeConnected(self):
        ''' Gets the current connection state of this client.

	        Returns boolean: True if client is currently connected
		        False if client is not connected'''

        return self.AreWeConnected()

    def getServerAppName(self):
        ''' Retrieves the name of the application that this client is connected to.

	        Returns string: The name of application that this client is connected to.  
                If the client is not connected, the return value is "Not Connected"''' 

        return self.GetServerApplicationName()

    def getServerAddress(self):
        ''' Retrieves the IP address of the PC running the NetCom server that this client is connected to.

	        Returns string: The IP of the PC running the NetCom server that this client is connected to.  
                If the client is not connected, the return value is "Not Connected"''' 

        return self.GetServerIPAddress()

    def getServerPcName(self):
        ''' Retrieves the name of the PC running the NetCom server that this client is connected to.

            Returns string: The name of the PC running the NetCom server that this client is connected to. 
                If the client is not connected, the return value is "Not Connected"'''

        return self.GetServerPCName()

    def setAppName(self, name):
        ''' Sets a name to identify your application to the NetCom server. 
            The server application will use this name to show information 
            about the connection to your application.

            Argument name of type String: The name is used to identify all traffic on this connection NetCom server logs. 
                This name is also displayed in the Router's connection list or in DAS's NetCom connection display.

            Returns boolean: True if the application name was set in the server's connection list.
                False on a failed attempt to update the server's connection list. 
                If this function is called while not connected to a NetCom server,
                it will return False and the application name will need to be reset after a connection is established.
            '''

        if (isinstance(name, str)):
              status = self.SetApplicationName(name)
        else:
            status = False
        return status

    def setLogFileName(self, fileName):
        ''' Sets the logfile name for this client.  If this command is not called, no logfile will be created.

            Argument fileName of type string: All NetCom communications will be logged to fileName.

            Returns boolean: True if this successfully sets the logfile name and opens the logfile.  Returns false if the logfile could not be opened. 
                This function can be called while not connected to a NetCom server.
            '''

        if (isinstance(fileName, str)):
            status =  self.SetLogFileName(fileName)
        else:
            status = False
        return status


    def getClientVersionString(self):
        ''' Retrieves the version of the client being used.

            Returns string:  The version of the NetCom client being used.'''

        return self.GetClientVersionString() 

    def connectToServer(self, ipaddress, routerConnection = True):
        ''' Connects this client to a NetCom server application.

            Argument ipaddress of type string:	Either the network name (i.e. "CheetahPC") 
                or a string representing the IP address (i.e. "192.168.1.100" ) of the PC running a NetCom server. 
            Argument routerConnection of type boolean: An optional argument that tells the NetComClient to attempt
                 to connect to the Router application prior to attempting a direct connection to DAS.  
                 DAS only supports a single NetComClient connection, so using the Router is advisable if multiple applications need data from DAS.  
                This argument defaults to True if not specified.  For most applications this value should always be True.

            Returns boolean: True if the connection to serverName was successful.  Returns false on a failed connection attempt.  
                If this function is called while currently connected to a NetCom server, it will return False and not close the current connection.'''
        if (isinstance(ipaddress, str)):
            status = self.ConnectToServer(ipaddress, routerConnection)
        else:
            status = False
        return status

        
    def disconnectFromServer(self):
        ''' Disconnects this client from a NetCom server application.

            Returns boolean: True if the disconnection from the currently connected  server was successful. 
                False on a failed disconnection attempt.  On a failed disconnect, the state of the NetCom client is undetermined.  It is advisable that a new MNetComClient object be created. 
                If this function is called while not connected to a NetCom server, it will return True.'''

        self.pyNetComObjects = None
        self.pyNetComTypes = None
        return self.DisconnectFromServer()

    def getDASObjectsTypes(self):
        ''' Retrieves all objects defined in DAS's object list, along with their corresponding types.

            Returns True and List of Objects and Types from DAS.
                    False on a failed attempt to receive DAS's object list.  If this function is called while not connected to a NetCom server, 
                    it will return False and the object and types lists will need to be refreshed after a connection is established.'''
        objectList = List[str]()
        typeList = List[str]()
        ncCall = self.GetDASObjectsAndTypes(objectList,typeList)
        if (ncCall[0]):
            # get available objects and types
            pyNetComObjects = objectList
            pyNetComTypes = typeList
            return [ncCall[0], pyNetComObjects, pyNetComTypes]
        else:
            return [ncCall[0],[],[]]


 ####################################################   CallBack Functions #################################################
 ########################################################################################################################### 


    def setCallbackFunctionSE(self,ipyNetComSEcallBack):
        '''Sets the callback function for single electrode records.

           Argument ipyNetComSEcallBack: A delegate to the function that will be called when any MSERec record is received by this client. 
                This function will be called as long as any single electrode object has an open stream.  
                This function ceases to be called when all single electrode streams have been closed.'''

        ipyNetComSE = MNC_SECallback(ipyNetComSEcallBack)
        self.SetCallbackFunctionSE(ipyNetComSE,self)

    def setCallbackFunctionST(self,ipyNetComSTcallBack):
        '''Sets the callback function for stereotrode records.

           Argument ipyNetComSTcallBack: A delegate to the function that will be called when any MSTRec record is received by this client.  
                This function will be called as long as any stereotrode object has an open stream.  
                This function ceases to be called when all stereotrode streams have been closed.'''

        ipyNetComST = MNC_STCallback(ipyNetComSTcallBack)
        self.SetCallbackFunctionST(ipyNetComST,self)

    def setCallbackFunctionTT(self,ipyNetComTTcallBack):
        '''Sets the callback function for tetrode records.

           Argument ipyNetComTTcallBack: A delegate to the function that will be called when any MTTRec record is received by this client.  
                This function will be called as long as any tetrode object has an open stream.  
                This function ceases to be called when all tetrode streams have been closed.'''
        ipyNetComTT = MNC_TTCallback(ipyNetComTTcallBack)
        self.SetCallbackFunctionTT(ipyNetComTT,self)

    def setCallbackFunctionCSC(self,ipyNetComCSCcallBack):
        '''Sets the callback function for continuously sampled records.

            Argument ipyNetComCSCcallBack: A delegate to the function that will be called when any MCRRec record is received by this client.  
                This function will be called as long as any continuously sampled object has an open stream.  
                This function ceases to be called when all continuously sampled streams have been closed. '''

        ipyNetComCSC = MNC_CSCCallback(ipyNetComCSCcallBack)
        self.SetCallbackFunctionCSC(ipyNetComCSC,self)
    
    def setCallbackFunctionEV(self,ipyNetComEVcallBack):
        '''Sets the callback function for event records.

           Argument ipyNetComEVcallBack: A delegate to the function that will be called when any MEventRec record is received by this client.  
                This function will be called as long as any event object has an open stream.  
                This function ceases to be called when all event streams have been closed.'''

        ipyNetComEV = MNC_EVCallback(ipyNetComEVcallBack)
        self.SetCallbackFunctionEV(ipyNetComEV,self)
     
    def setCallbackFunctionVT(self,ipyNetComVTcallBack):
        '''Sets the callback function for video tracker records.

           Argument ipyNetComVTcallBack: A delegate to the function that will be called when any MVideoRec record is received by this client. 
                This function will be called as long as any video tracker object has an open stream. 
                This function ceases to be called when all video tracker streams have been closed.'''

        ipyNetComVT = MNC_VTCallback(ipyNetComVTcallBack)
        self.SetCallbackFunctionVT(ipyNetComVT,self)

    def setConnectionLostCallbackFunction(self,ipyNetComConnectionLostcallBack):
        '''sets callback function for connection lost

           Argument ipyNetComConnectionLostcallBack: A delegate to the function that will be called when any MNC_ConnectionLostCallback record is received by this client. 
        '''

        ipyNetComConnectionLost = MNC_ConnectionLostCallback(ipyNetComConnectionLostcallBack)
        self.SetConnectionLostCallbackFunction(ipyNetComConnectionLost,self)

    def setMessageCallbackFunction(self,ipyNetComMessagecallBack):
        '''sets callback function for NLX  messages

          Argument ipyNetComConnectionLostcallBack: A delegate to the function that will be called when any MNC_MessageCallback message is received by this client. 
        '''

        ipyNetComMessage = MNC_MessageCallback(ipyNetComMessagecallBack)
        self.SetMessageCallbackFunction(ipyNetComMessage,self)
        

 ####################################################   Stream Controller  ###############################################
 #########################################################################################################################

    
    def openStream(self, objectName):
        '''Opens a record stream between this client and a NetCom server.  
           Opening a stream will cause the defined callback function corresponding to the object type of objectName to be called after receiving a record for the specified object name.
           
           Argument objectName: The name of the object to stream data from.  This name is specified in the DAS setup files. 
                A listing of defined object names can be obtained from the getDASObjectsTypes() function.

           Returns boolean: True if the the specified object name and type were found in DAS's object list, and a stream was successfully opened.  Returns false on any of the following conditions:
                The object name specified was not found in DAS's object list.
                A network or other error prevented the stream from opening.
                If this function is called while not connected to a NetCom server, it will return False and the stream will need to be reopened after a connection is established. 
                If this function is called successfully multiple times using the same arguments, it must be closed the same number of times to halt record callbacks.  
                Calling DisconnectFromServer automatically closes all opened streams.
            '''
        if isinstance(objectName, str):
            status = self.OpenStream(objectName)
        else:
            status = False
        return status

    def closeStream(self, DASObjectName):
        '''Closes a record stream between this client and a NetCom server. 
           Closing a stream will cause DAS to cease sending records  for the specified object.  
           The callback function will continue to be called until all records for this object, received before calling CloseStream, have been processed.
           
           Argument DASObjectName: The name of the object whose stream should be closed.  This name is specified in the DAS setup files.  
                    A listing of defined object names can be obtained from the getDASObjectsTypes() function.     
           
           Returns boolean: True if the the specified object name and type were found in DAS's object list, and a stream was successfully closed.  Returns false on any of the following conditions:
                    The object name specified was not found in DAS's object list.
                    A stream for this object name and type has not yet been opened.
                    A network or other error prevented the stream from opening.
                    If this function is called while not connected to a NetCom server, it will return False. 
                    If OpenStream is called successfully multiple times using the same arguments, it must be closed the same number of times to halt record callbacks. 
                    Calling DisconnectFromServer automatically closes all opened streams.'''
        if isinstance(DASObjectName, str):
            status = self.CloseStream(DASObjectName)
        else:
            status = False
        return status



 ####################################################   Send Command  ####################################################
 #########################################################################################################################
 
    def sendCommand(self, command):
        '''Sends a generic command to DAS for processing.  
            This is a synchronous command that will wait until the NetCom server sends a response before returning. For a complete list of DAS commands,
            see the Commands section of the DAS Reference Guide (available under the Help menu in DAS).

            Argument command: The formatted command string that DAS is to process.  Command strings are identical to configuration file commands.
            
            Returns boolean: True if this successfully sends a command and receives a response to/from a NetCom server.  
                        false on a failed attempt to send a command, or receive a response from a NetCom server. 
                        If this function is called while not connected to a NetCom server, it will return False and the command will be discarded.
            Returns response of type string: The reply received from the NetCom server will be returned if not "-1" or "0" 
        '''
        
        reply = ''
        if isinstance(command, str):
            response = self.SendCommand(command, reply)
            if ((response[0] == True)):
                # check reply if it is not '-1'
                if((response[1].split())[0] != '-1'):
                    return response
            return [False,'-1'] 
        else:
            return [False,'0']  



