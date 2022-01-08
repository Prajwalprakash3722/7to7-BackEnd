#Suppress Warnings
options(warn = -1)

setwd("/home/atreyab/Documents/Projects/Hackathons/seventoseven/7to7-BackEnd/old/LeadScore")

#Load Package
suppressPackageStartupMessages( library(readxl))
suppressPackageStartupMessages( library(ggplot2))
suppressPackageStartupMessages( library(nnet))
suppressPackageStartupMessages( library(rpart))
suppressPackageStartupMessages( library(caret))
suppressPackageStartupMessages( library(dplyr))
suppressPackageStartupMessages( library(e1071))
suppressPackageStartupMessages( library(gmodels))
suppressPackageStartupMessages( library(tidyverse))
suppressPackageStartupMessages( library(svDialogs))


# me add
print(MasterFile$`Model File`[MasterFile$Modelid==var1])
# print("Read 1")

#load the model
  super_model <- readRDS(MasterFile$`Model File`[MasterFile$Modelid==var1])


print("Read 2")

#Read Prediction dataset
  Test_Data<-read_csv(MasterFile$`Input Data File`[MasterFile$Modelid==var1],show_col_types = FALSE)

#Convert All character Variable to Factor
  Test_Data[sapply(Test_Data, is.character)] <- lapply(Test_Data[sapply(Test_Data, is.character)],as.factor)

#Convert Class to Factor
  Test_Data$Status<-as.factor(Test_Data$Status)
  
#Relevel Actual Status
  Test_Data$Status=relevel(Test_Data$Status, ref = "1")
  
#Predict input data file
  Test_Data$"Predicted Class" <- predict(super_model,Test_Data,type ="class")
  Test_Data$"Predicted Prob" <- predict(super_model,Test_Data,type ="prob")
  
#Save Prediction File
  b=MasterFile$`Input Data File`[MasterFile$Modelid==var1]
  v=gsub(pattern = "\\.csv$","",b)
  x=paste(v,"- scored.csv")
  MasterFile$`Output Data File`[MasterFile$Modelid==var1]=x
  write.csv(MasterFile,masterfileName,row.names = F)
  write.csv(Test_Data,paste(v,"- scored.csv")) 
  
#Print Confusion Matrix
  cat("\n")
  cat("Confusion Matrix of Prediction Dataset")
  cat("\n")
  
  # Relevel Predicted Class
  Test_Data$`Predicted Class`=relevel(Test_Data$`Predicted Class`, ref = "1")
  
  Actual=Test_Data$Status
  Predicted=Test_Data$`Predicted Class`
  CrossTable( Actual,Predicted)
  # str(x)
  e=confusionMatrix(Predicted, Actual)


  # write.csv(e,paste(v,"- scored.csv")) 
  write.csv(as.matrix(e),paste(v,"- confusion.csv"))




  # print(e)
  Accuracy=round(((e$table[1,1]+e$table[2,2])/(e$table[1,1]+e$table[1,2]+e$table[2,1]+e$table[2,2]))*100,2)
  cat("--------------------------------------")
  cat("\n")
  cat("Classification Matrix")
  cat("\n")
  cat("--------------------------------------")
  cat("\n")
  cat("Accuracy=",Accuracy,paste0("%"))
  cat("\n")
  precision=round((e$table[1,1]/(e$table[1,1]+e$table[1,2]))*100,2)
  cat("Precision=",precision,paste0("%"))
  cat("\n")
  recall=round((e$table[1,1]/(e$table[1,1]+e$table[2,1]))*100,2)
  cat("Recall=",recall,paste0("%"))
  cat("\n")
  F1score=round(2*(precision*recall)/(precision+recall),2)
  cat("F1-Score=",F1score,paste0("%"))
  cat("\n")

