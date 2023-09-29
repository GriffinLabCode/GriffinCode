/*
defines lots of microsoft specific stuff so that it this code can be compiled with a standard gcc.

needs the 3rd party files StdString.h and PortableFileClass.hpp as drop-in replacements for MFC stuff.

this version is for Intel 64 bit g++ !

urut@caltech.edu
*/

#ifndef _COMPAT_
#define _COMPAT_

#include "StdString.h"
#include <fstream>
#include <string>

//memory mapping
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h> 
#include <fcntl.h> 
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

//MS compatibility stuff

#define BOOL bool
#define CString CStdString
//#define CFile File

#define __int8 char
#define __int16	short
#define __int32 int 
#define __int64 long
#define ULONGLONG unsigned long long
#define UINT unsigned int

#define FALSE 0
#define TRUE 1


#endif
