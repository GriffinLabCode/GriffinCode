#!/bin/sh
#
#
#this script compiles all neuralynx code necessary to read neuralynx files from matlab.
#
#this is the 64 Bit Version. 
#
#june 2004, ueli rutishauser, urut@caltech.edu
#updated july 2008. tested with g++ 4.2.3 with glibc 2.7 (ubuntu)
#updated oct  2008 -> 64 Bit Version
#updated aug 2009 -> Mac OS X
#

INCLMATLAB="/Applications/MATLAB_R2009a.app/extern/include/"
BINMATLAB="/Applications/MATLAB_R2009a.app/bin/"


rm *.o
rm *.mexmaci64

g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB Nlx_Code.cpp

g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeBuf.cpp

g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeEventBuf.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB FileDataBucket.cpp 
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB GeneralOperations.cpp

g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB ProcessorEV.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB ProcessorCSC.cpp

g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeCSCBuf.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeMClustTSBuf.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeSEBuf.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeSTBuf.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeTSBuf.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeTTBuf.cpp
g++ -Wno-non-template-friend -fPIC -arch x86_64 -fpermissive -c -I$INCLMATLAB TimeVideoBuf.cpp


#now make matlab binary
$BINMATLAB/mex CXXFLAGS='$CFLAGS -fpermissive' -o Nlx2MatEV Nlx2MatEV.cpp FileDataBucket.o GeneralOperations.o Nlx_Code.o ProcessorEV.o TimeBuf.o TimeEventBuf.o TimeCSCBuf.o TimeMClustTSBuf.o TimeSEBuf.o TimeSTBuf.o TimeTSBuf.o TimeTTBuf.o TimeVideoBuf.o
$BINMATLAB/mex CXXFLAGS='$CFLAGS -fpermissive' -o Nlx2MatCSC Nlx2MatCSC.cpp FileDataBucket.o GeneralOperations.o Nlx_Code.o ProcessorCSC.o TimeBuf.o TimeEventBuf.o TimeCSCBuf.o TimeMClustTSBuf.o TimeSEBuf.o TimeSTBuf.o TimeTSBuf.o TimeTTBuf.o TimeVideoBuf.o


