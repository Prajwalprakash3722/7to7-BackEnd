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
  e=confusionMatrix(Predicted, Actual)
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


#lift chart
# pct=(sum(gain_table_Train$totalresp)/nrow(Training_Data))*100
# p=ggplot()+
#   geom_line(data=gain_table_Train ,aes(x=bucket*10,y=Gain, color="ModelSet"), size=0.5, show.legend = F)+
#   geom_line(data=gain_table_Test ,aes(x=bucket*10,y=Gain, color="ValidationSet"), size=0.5, show.legend = F)+
#   #geom_line(data=gain_table_Prediction ,aes(x=bucket*10,y=Gain, color="PredictionSet"), size=0.5, show.legend = F)+
#   geom_polygon(data = data.frame(x = c(0, pct, 100, 0),
#                                  y = c(0, 100, 100, 0)),
#                aes(x = x, y = y), alpha = 0.1)+
#   geom_line(data = data.frame(x = c(0, pct, 100, 0), y = c(0, 100, 100, 0)), aes(x=x,y=y,color="ideal"),size=1)+
#   geom_line(data = data.frame(x = c(0,100),y = c(0,100)), aes(x=x,y=y, color="Random"),size=1)+
#   xlab("%Enquiries")+
#   ylab("%Conversion")+
#   scale_x_continuous(breaks = seq(0,100,by=10))+
#   scale_y_continuous(breaks = seq(0,100,by=10))+
#   scale_colour_manual(name="",values = c("ideal"='darkgreen',"ModelSet"="blue","ValidationSet"="Black","Random"="red"))+
#   scale_linetype_manual(name="", labels=c("ideal","ModelSet","ValidationSet","Random"),values = c("ideal"=1,"ModelSet"=1,"ValidationSet"=1,"Random"=1))+
#   theme_bw()+
#   theme(legend.key.size=unit(0.3,"lines"),legend.text = element_text(size = 12,colour = "black", face = "bold"),legend.position = "top",axis.text.x = element_text(angle = 0,hjust = 0,colour = "black", face = "bold"), axis.text.y = element_text(colour = "black", face = "bold",hjust = 0),axis.title.y = element_text(color = "black", size = 14, face = "bold"), axis.title.x = element_text(colour = "black",size = 14, face = "bold"),axis.text = element_text(face = "bold", size = 10))+
#   theme(legend.key.size =  unit(0.2, "in"))
# windows()
# print(p)
# 
