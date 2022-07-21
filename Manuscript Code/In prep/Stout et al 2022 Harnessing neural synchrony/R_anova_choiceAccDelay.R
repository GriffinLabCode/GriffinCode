# install.packages("tidyverse")
# install.packages("lmSupport")
# install.packages("gmodels")
# install.packages("ez")
# install.packages("psych")

#--------------------------------------------#
# change dir
setwd("X:/07. Manuscripts/In preparation/Harnessing neural synchrony")

# load dataset
data2load = 'data_choiceXdelay_spreadSheet.csv'
dataIN = read.csv(data2load)

# remove na
library("tidyverse")

# ezANOVA
library(ez)

anovaOUT = ezANOVA(
   data       = dataIN
   , dv       = ratAccCat # dv
   , wid      = ratID # subjects
   , within   = .(delayMeas) # within subjects factors
   , between  = NULL
   , detailed = TRUE
   , type     = 3
 )

print(anovaOUT)
