# File Name: NandiToyota_LeadScore.R
# File Type: R Script
# File Size: 1 KB
# Authors: Anju M Nair {anju@popularmc.com} & Resmi Reghukumar {Data2@popularmc.com}
# Created On: 11/12/2021 12:27:26 PM
# Last Modified On: 21/12/2021 12:11:30 PM
# Copy Rights: Popular Motor Corporation Pvt Ltd
# Description: Lead Scoring different dataset

# Setting the Current Working Directory
setwd("E:/Main Code")

# Suppress Warnings
options(warn = -1)

# Import Required Packages
library(readxl)
library(svDialogs)

# Read "Master_Models_Data.csv" File
MasterFile=read.csv("Master_Models_Data.csv",header = T,check.names = F)

# Get Model ID From Dialog Box
var1 <- dlgInput(t(MasterFile))$res

# If Model ID found invokes corresponding data and model
if(var1 %in% MasterFile$Modelid){
  source("LeadScoring.R")}else
    print("invalid ID")


  