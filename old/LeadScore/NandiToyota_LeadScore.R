# File Name: NandiToyota_LeadScore.R
# File Type: R Script
# File Size: 1 KB
# Authors: Anju M Nair {anju@popularmc.com} & Resmi Reghukumar {Data2@popularmc.com}
# Created On: 11/12/2021 12:27:26 PM
# Last Modified On: 22/12/2021 12:11:30 PM
# Copy Rights: Popular Motor Corporation Pvt Ltd
# Description: Lead Scoring different dataset

# Setting the Current Working Directory
# wd<-"/home/atreyab/Documents/Projects/seventoseven/7to7-BackEnd/old/LeadScore/"
setwd("/home/atreyab/Documents/Projects/Hackathons/seventoseven/7to7-BackEnd/old/LeadScore")
# print(paste("1","22",sep=""))
# stop("no")
# Suppress Warnings
options(warn = -1)

# Import Required Packages
# library(readxl)

# Read "Master_Models_Data.csv" File
masterfileName = "Master_New.csv"
MasterFile=read.csv(masterfileName,header = T,check.names = F)
# print("Read master")
# my mods
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  # print(args[1])
  # stop("hi")
}
# Get Model ID From Dialog Box
# var1 <- dlgInput(t(MasterFile))$res
var1 <- args[1]

# If Model ID found invokes corresponding data and model
if(var1 %in% MasterFile$Modelid){
  source("LeadScoring.R")}else
    print("invalid ID")


  