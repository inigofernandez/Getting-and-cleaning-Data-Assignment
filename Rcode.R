
library(data.table)
library(dplyr)


#Downloading the information for the assigment
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(destFile)
}
dateDownloaded <- date()

setwd("./UCI_HAR_Dataset")

#Reading the unzip files
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)
ActivityLabels <- read.table("./activity_labels.txt", header = F)
FeaturesNames <- read.table("./features.txt", header = F)


#Merguing dataframes
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

names(ActivityData) <- "ActivityCODE"
names(ActivityLabels) <- c("ActivityCODE", "ActivityType")


#Joining ActivityData and ActivityLabels dataframes
Activity <- full_join(ActivityData, ActivityLabels, "ActivityCODE")[, 2]

names(SubjectData) <- "Subject"
names(FeaturesData) <- FeaturesNames$V2


#Create one large Dataset with only these variables: SubjectData,  Activity,  FeaturesData
Data1 <- cbind(SubjectData, Activity)
Data1 <- cbind(DataSet, FeaturesData)

#Selecting the sentences which conteins mean and std from FeaturesNames and grapping those names from Dataset 
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(Data1, select=DataNames)

#Rename the technical names with others more intuitives
names(DataSet)<-gsub("^t", "Time", names(DataSet))
names(DataSet)<-gsub("^f", "Frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

#Create a second dataset with the average of each variable for each activity and each subject
Data2<-aggregate(. ~Subject + Activity, DataSet, mean)
Data2<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

#Save the final dataset
write.table(Data2, file = "tidydataset.txt",row.name=FALSE)