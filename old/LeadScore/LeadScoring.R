options(warn = -1)
library(readxl)
library(ggplot2)
library(nnet)
library(rpart)
library(caret)
library(dplyr)
require(e1071)
require(gmodels)
require(tidyverse)
# Read All Enquiries
Enquiry_Data= read_csv(MasterFile$`Data File`[MasterFile$Modelid==var1],show_col_types = FALSE)
#All_Seller_Enquiry<-read_excel("MAR 19 - JUL 21 SELLER ENQUIRY.xlsx")
# Replace all na in character variables with NULL
Enquiry_Data[sapply(Enquiry_Data,function(x) is.character(x) & is.na(x))]="NULL"
# Convert All character Variable to Factor
Enquiry_Data[sapply(Enquiry_Data, is.character)] <- lapply(Enquiry_Data[sapply(Enquiry_Data, is.character)],as.factor)
# Convert Class to Factor
Enquiry_Data$Status<-as.factor(Enquiry_Data$Status)
Enquiry_Data$Status=relevel(Enquiry_Data$Status, ref = "1")
# create 70%/30% for training and validation dataset

set.seed(1234)
trainIndex<- sample(1: nrow(Enquiry_Data), round(0.7*nrow(Enquiry_Data)))
Training_Data<-Enquiry_Data[trainIndex,]
Testing_Data<- Enquiry_Data[-trainIndex,]

# load the model
super_model <- readRDS(MasterFile$`Model File`[MasterFile$Modelid==var1])

# Model dataset
Training_Data$"Predicted Class" <- predict(super_model,Training_Data,type ="class")
Training_Data$"Predicted Probability" <- predict(super_model,Training_Data,type = "prob")
#Lift Table Calculation for Model Dataset
PredProb_Train=Training_Data$`Predicted Probability`[,2]
Actual_Train=Training_Data$Status
groups=10
if(is.factor(Actual_Train)) Actual_Train<-as.integer(as.character(Actual_Train))
if(is.factor(PredProb_Train)) PredProb_Train<-as.integer(as.numeric(PredProb_Train))
helper=data.frame(cbind(Actual_Train,PredProb_Train))
helper[,"bucket"]=ntile(-helper[,"PredProb_Train"],groups)
gain_table_Train = helper %>% group_by(bucket) %>% 
  summarise_at(vars(Actual_Train),funs(total=n(),
                                       totalresp=sum(., na.rm = T))) %>% 
  mutate(Cumresp=cumsum(totalresp),Gain=Cumresp/sum(totalresp)*100,cumlift=Gain/(bucket*(100/groups)))

cat("Confusion Matrix of Model Dataset")
cat("\n")
Training_Data$`Predicted Class`=relevel(Training_Data$`Predicted Class`, ref = "1")
Predicted=Training_Data$"Predicted Class" 
Actual=Training_Data$Status
CrossTable(Actual,Predicted)
c=confusionMatrix(Training_Data$`Predicted Class`, Training_Data$Status)
Accuracy=round((c$table[1,1]+c$table[2,2])/(c$table[1,1]+c$table[1,2]+c$table[2,1]+c$table[2,2])*100,2)
cat("--------------------------------------")
cat("\n")
cat("Classification Matrix")
cat("\n")
cat("--------------------------------------")
cat("\n")
cat("Accuracy=",Accuracy,paste0("%"))
cat("\n")
precision=round((c$table[1,1]/(c$table[1,1]+c$table[1,2]))*100,2)
cat("Precision=",precision,paste0("%"))
cat("\n")
recall=round((c$table[1,1]/(c$table[1,1]+c$table[2,1]))*100,2)
cat("Recall=",recall,paste0("%"))
cat("\n")
F1score=round(2*(precision*recall)/(precision+recall),2)
cat("F1-Score=",F1score,paste0("%"))
cat("\n")
# Validation dataset
Testing_Data$"Predicted Class" <- predict(super_model,Testing_Data,type ="class")
Testing_Data$"Predicted Prob" <- predict(super_model,Testing_Data,type ="prob")
#lift Table Calculation for Validation Dataset
PredProb_Test=Testing_Data$`Predicted Prob`[,2]
Actual_Test=Testing_Data$Status
groups=10
if(is.factor(Actual_Test)) Actual_Test<-as.integer(as.character(Actual_Test))
if(is.factor(PredProb_Test)) PredProb_Test<-as.integer(as.numeric(PredProb_Test))
helper=data.frame(cbind(Actual_Test,PredProb_Test))
helper[,"bucket"]=ntile(-helper[,"PredProb_Test"],groups)
gain_table_Test = helper %>% group_by(bucket) %>% 
  summarise_at(vars(Actual_Test),funs(total=n(),
                                      totalresp=sum(., na.rm = T))) %>% 
  mutate(Cumresp=cumsum(totalresp),Gain=Cumresp/sum(totalresp)*100,cumlift=Gain/(bucket*(100/groups)))

cat("\n")
cat("Confusion Matrix of Validation Dataset")
cat("\n")
Testing_Data$`Predicted Class`=relevel(Testing_Data$`Predicted Class`, ref = "1")
Predicted=Testing_Data$`Predicted Class` 
Actual= Testing_Data$Status
CrossTable(Actual,Predicted)
d=confusionMatrix(Testing_Data$`Predicted Class`, Testing_Data$Status)
Accuracy=round(((d$table[1,1]+d$table[2,2])/(d$table[1,1]+d$table[1,2]+d$table[2,1]+d$table[2,2]))*100,2)
cat("--------------------------------------")
cat("\n")
cat("Classification Matrix")
cat("\n")
cat("--------------------------------------")
cat("\n")
cat("Accuracy=",Accuracy,paste0("%"))
cat("\n")
precision=round((d$table[1,1]/(d$table[1,1]+d$table[1,2]))*100,2)
cat("Precision=",precision,paste0("%"))
cat("\n")
recall=round((d$table[1,1]/(d$table[1,1]+d$table[2,1]))*100,2)
cat("Recall=",recall,paste0("%"))
cat("\n")
F1score=round(2*(precision*recall)/(precision+recall),2)
cat("F1-Score=",F1score,paste0("%"))
cat("\n")
#****************************************************************

# # Read Prediction dataset
if(MasterFile$`Prediction File`[MasterFile$Modelid==var1]==""){
  print("Prediction File Not Found")
}else{
  Test_Data<-read_csv(MasterFile$`Prediction File`[MasterFile$Modelid==var1],show_col_types = FALSE)

# # Replace all na in character variables with NULL
#Test_Data[sapply(Test_Data,function(x) is.character(x) & is.na(x))]="NULL"
# # Convert All character Variable to Factor
  Test_Data[sapply(Test_Data, is.character)] <- lapply(Test_Data[sapply(Test_Data, is.character)],as.factor)
# # Convert Class to Factor
  Test_Data$Status<-as.factor(Test_Data$Status)
# Relevel Factor
  Test_Data$Status=relevel(Test_Data$Status, ref = "1")
# Prediction dataset
  Test_Data$"Predicted Class" <- predict(super_model,Test_Data,type ="class")
  Test_Data$"Predicted Prob" <- predict(super_model,Test_Data,type ="prob")
  cat("\n")
  cat("Confusion Matrix of Prediction Dataset")
  cat("\n")
  CrossTable( Test_Data$Status,Test_Data$`Predicted Class`)
  e=confusionMatrix(Test_Data$`Predicted Class`, Test_Data$Status)
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
}

# PredProb_Prediction=Test_Data$`Predicted Prob`[,2]
# Actual_Prediction=Test_Data$Status
# groups=10
# if(is.factor(Actual_Prediction)) Actual_Prediction<-as.integer(as.character(Actual_Prediction))
# if(is.factor(PredProb_Prediction)) PredProb_Prediction<-as.integer(as.numeric(PredProb_Prediction))
# helper=data.frame(cbind(Actual_Prediction,PredProb_Prediction))
# helper[,"bucket"]=ntile(-helper[,"PredProb_Prediction"],groups)
# gain_table_Prediction = helper %>% group_by(bucket) %>% 
#   summarise_at(vars(Actual_Prediction),funs(total=n(),
#                                       totalresp=sum(., na.rm = T))) %>% 
#   mutate(Cumresp=cumsum(totalresp),Gain=Cumresp/sum(totalresp)*100,cumlift=Gain/(bucket*(100/groups)))
# 
#************************************************************************************

#Lift Chart for Model Dataset
# A=data.frame(Training_Data$`Predicted Probability`)
# Model_propensity<-data.frame(A$X1,Training_Data$Status)
# colnames(Model_propensity)[1]<-"Model dataset"
# colnames(Model_propensity)[2]<-"Status"
# #Model_propensity$`Model dataset`<-as.numeric(Model_propensity$`Model dataset`)
# #Model_propensity$Status<-factor(Model_propensity$Status)
# sorted_model_propensity<-Model_propensity[order(-Model_propensity$`Model dataset`),]
# #levels(sorted_model_propensity$Status)<- relevel(sorted_model_propensity$Status, ref = "1")
# lift_model<- lift(sorted_model_propensity$Status,sorted_model_propensity$`Model dataset`)
# #Lift Chart for Validation dataset
# B=data.frame(Testing_Data$`Predicted Prob`)
# Valid_propensity<-data.frame(B$X1,Testing_Data$Status)
# colnames(Valid_propensity)[1]<-"Validate dataset"
# colnames(Valid_propensity)[2]<-"Status"
# Valid_propensity$`Validate dataset`<-as.numeric(Valid_propensity$`Validate dataset`)
# Valid_propensity$Status<-factor(Valid_propensity$Status)
# sorted_valid_propensity<-Valid_propensity[order(-Valid_propensity$`Validate dataset`),]
# #sorted_valid_propensity$Status<- relevel(sorted_valid_propensity$Status, ref = "1")
# lift_valid<- lift(Status ~ `Validate dataset`, data = sorted_valid_propensity)
# # lift chart Using R ggplot()
# Model_data<- lift_model$data
# Valid_data<- lift_valid$data

pct=(sum(gain_table_Train$totalresp)/nrow(Training_Data))*100
p=ggplot()+
  geom_line(data=gain_table_Train ,aes(x=bucket*10,y=Gain, color="ModelSet"), size=0.5, show.legend = F)+
  geom_line(data=gain_table_Test ,aes(x=bucket*10,y=Gain, color="ValidationSet"), size=0.5, show.legend = F)+
  #geom_line(data=gain_table_Prediction ,aes(x=bucket*10,y=Gain, color="PredictionSet"), size=0.5, show.legend = F)+
  geom_polygon(data = data.frame(x = c(0, pct, 100, 0),
                                 y = c(0, 100, 100, 0)),
               aes(x = x, y = y), alpha = 0.1)+
  geom_line(data = data.frame(x = c(0, pct, 100, 0), y = c(0, 100, 100, 0)), aes(x=x,y=y,color="ideal"),size=1)+
  geom_line(data = data.frame(x = c(0,100),y = c(0,100)), aes(x=x,y=y, color="Random"),size=1)+
  xlab("%Enquiries")+
  ylab("%Conversion")+
  scale_x_continuous(breaks = seq(0,100,by=10))+
  scale_y_continuous(breaks = seq(0,100,by=10))+
  scale_colour_manual(name="",values = c("ideal"='darkgreen',"ModelSet"="blue","ValidationSet"="Black","Random"="red"))+
  scale_linetype_manual(name="", labels=c("ideal","ModelSet","ValidationSet","Random"),values = c("ideal"=1,"ModelSet"=1,"ValidationSet"=1,"Random"=1))+
  theme_bw()+
  theme(legend.key.size=unit(0.3,"lines"),legend.text = element_text(size = 12,colour = "black", face = "bold"),legend.position = "top",axis.text.x = element_text(angle = 0,hjust = 0,colour = "black", face = "bold"), axis.text.y = element_text(colour = "black", face = "bold",hjust = 0),axis.title.y = element_text(color = "black", size = 14, face = "bold"), axis.title.x = element_text(colour = "black",size = 14, face = "bold"),axis.text = element_text(face = "bold", size = 10))+
  theme(legend.key.size =  unit(0.2, "in"))
windows()
print(p)

