library(data.table)
library(dplyr)
##error
error1 = "no UCI HAR file in working directory. Please set your working directory to the one containing the folder 'UCI HAR Dataset'"
if (!file.exists("./UCI HAR Dataset")) {error1}
##files
("./UCI HAR Dataset/features.txt") -> labels_doc
("./UCI HAR Dataset/activity_labels.txt") -> activity_labels_doc
("./UCI HAR Dataset/test/X_test.txt") -> x_test_doc
file.y_test <- ("./UCI HAR Dataset/test/y_test.txt")
("./UCI HAR Dataset/train/X_train.txt") -> file.x.train
file.y_train <- ("./UCI HAR Dataset/train/y_train.txt")
subject_test_doc <- ("./UCI HAR Dataset/test/subject_test.txt")
subject_train_doc <- ("./UCI HAR Dataset/train/subject_train.txt")
##labels
read.table(labels_doc) -> xlabels
read.table(activity_labels_doc) -> activity_labels
##xtest
read.table(x_test_doc, col.names=xlabels$V2) -> xtest
data.table(xtest, keep.rownames = TRUE, keep.colnames = TRUE) -> x_test
fread(file.y_test) -> y_test
##I want to write a script here using tables() to return the numerical value of rows in order to automate the process
y_test[, a:=1:2947]; x_test[, a:=1:2947]; setkey(y_test, a); setkey(x_test, a); merge(x_test, y_test) ->  xy_test
read.table(subject_test_doc) -> xy_test$subject 
##xtrain
read.table(file.x.train, col.names=xlabels$V2) -> xtrain
data.table(xtrain, keep.rownames = TRUE, keep.colnames = TRUE) -> x_train
fread(file.y_train) -> y_train
y_train[, a:=1:7352]; x_train[, a:=1:7352]; setkey(y_train, a); setkey(x_train, a); merge(x_train, y_train) ->  xy_train
read.table(subject_train_doc) -> xy_train$subject
##combining the sets
xy_test[, type:="test"]; xy_train[, type:="train"]; rbind(xy_test, xy_train) ->test_train
##subsetting the mean and std
c(grep("mean", colnames(test_train))) -> means
##thanks Henrik on  Stackoverflow for the grep info
select(test_train, means) -> means_test_train_freq
##not working from here down
c(grep("Freq", colnames(test_train))) -> freq
select(means_test_train_freq, -(freq)) -> means_test_train
c(grep("std", colnames(test_train))) -> stds
select(test_train, stds) -> stds_test_train
stds_test_train$id <- (1:10299); means_test_train$id <- (1:10299)
merge(stds_test_train, means_test_train, by="id") -> stds_means
##activity labels
test_train$activity <- ifelse(test_train$V1 == 1, c("Walking"), ifelse(test_train$V1 == 2, c("Walking Upstairs"), ifelse(test_train$V1 == 3, c("Walking Downstairs"), ifelse(test_train$V1 == 4, c("Sitting"), ifelse(test_train$V1 == 5, c("Standing"), ifelse(test_train$V1 == 6, c("Laying"), "NA"))))))
##adding the labels
stds_means$activity <- test_train$activity 
stds_means$subject <- test_train$subject
## calculating the averages for each variable by type
stds_means[which(stds_means$activity=="Laying"), ] -> laying
stds_means[which(stds_means$activity=="Walking"), ] -> Walking
stds_means[which(stds_means$activity=="Walking Downstairs"), ] -> walking_downstairs
stds_means[which(stds_means$activity=="Standing"), ] -> standing
stds_means[which(stds_means$activity=="Walking Upstairs"), ] -> walking_upstairs
stds_means[which(stds_means$activity=="Sitting"), ] -> sitting
aggregate(walking_downstairs, by=list(walking_downstairs$subject), FUN=mean, rm.na=TRUE) -> mean_walking_downstairs; mean_walking_downstairs$activity <- c("Walking Downstairs")
aggregate(standing, by=list(standing$subject), FUN=mean, rm.na=TRUE) -> mean_standing; mean_standing$activity <- c("Standing")
aggregate(sitting, by=list(sitting$subject), FUN=mean, rm.na=TRUE) -> mean_sitting; mean_sitting$activity <- c("Sitting")
aggregate(laying, by=list(laying$subject), FUN=mean, rm.na=TRUE) -> mean_laying; mean_laying$activity <- c("Laying")
aggregate(Walking, by=list(Walking$subject), FUN=mean, rm.na=TRUE) -> mean_walking; mean_walking$activity <- c("Walking")
aggregate(walking_upstairs, by=list(walking_upstairs$subject), FUN=mean, rm.na=TRUE) -> mean_walking_up; mean_walking_up$activity <- c("Walking Upstairs")
mergedMeans = rbind(mean_walking_up, mean_walking, mean_laying, mean_sitting, mean_standing, mean_walking_downstairs)
arrange(mergedMeans, by=mergedMeans$subject) -> mergedMeans
##one more categorical variable
mergedMeans[, c(1:22, 36:55, 82:83)] -> mergedMeansT
mergedMeans[,c(1, 23:35, 56:83)] -> mergedMeansF
names(mergedMeansT) <- c("Group","id","tSTDBodyAccelerationX",
"tSTDBodyAccelerationY","tSTDBodyAccelerationZ","tSTDGravityAccelerationX","tSTDGravityAccelerationY","tSTDGravityAccelerationZ","tSTDBodyAccelerationJerkX","tSTDBodyAccelerationJerkY","tSTDBodyAccelerationJerkZ","tSTDBodyGyroX","tSTDBodyGyroY","tSTDBodyGyroZ","tSTDBodyGyroJerkX","tSTDBodyGyroJerkY","tSTDBodyGyroJerkZ","tSTDBodyAccelerationMagnitude","tSTDGravityAccelerationMagnitude","tSTDBodyAccelerationJerkMagnitude","tSTDBodyGyroMagnitude","tSTDGyroMagnitudeJerk","tMeanBodyAccelerationX","tMeanBodyAccelerationY","tMeanBodyAccelerationZ","tMeanGravityAccelerationX","tMeanGravityAccelerationY","tMeanGravityAccelerationZ","tMeanBodyAccelerationJerkX","tMeanBodyAccelerationJerkY","tMeanBodyAccelerationJerkZ","tMeanBodyGyroX","tMeanBodyGyroY","tMeanBodyGyroZ","tMeanBodyGyroJerkX","tMeanBodyGyroJerkY","tMeanBodyGyroJerkZ","tMeanBodyAccelerationMagnitude","tMeanGravityAccelerationMagnitude","tMeanBodyAccelerationJerkMagnitude","tMeanBodyGyroMagnitude","tMeanGyroMagnitudeJerk","activity","subject")
names(mergedMeansF) <- c("Group", "fSTDBodyAccelerationX","fSTDBodyAccelerationY",
"fSTDBodyAccelerationZ","fSTDGravityAccelerationX,","fSTDGravityAccelerationY","fSTDGravityAccelerationZ","fSTDBodyAccelerationJerkX","fSTDBodyAccelerationJerkY","fSTDBodyAccelerationJerkZ","fSTDBodyGyroX","fSTDBodyGyroY","fSTDBodyGyroZ","fSTDBodyGyroJerkX","fSTDBodyGyroJerkY","fSTDBodyGyroJerkZ","fSTDBodyAccelerationMagnitude","fSTDBodyAccelerationJerkMagnitude","fSTDBodyGyroMagnitude","fSTDGyroMagnitudeJerk","fMeanBodyAccelerationFrequencyX","fMeanBodyAccelerationFrequencyY","fMeanBodyAccelerationFrequencyZ","fMeanBodyAccelerationJerkX","fMeanBodyAccelerationJerkY","fMeanBodyAccelerationJerkZ","fMeanBodyGyroX","fMeanBodyGyroY","fMeanBodyGyroZ","fMeanBodyGyroFreqX","fMeanBodyGyroFreqY","fMeanBodyGyroFreqZ","fMeanBodyAccelerationMagnitude","fMeanBodyAccelerationMagnitudeFrequency","fMeanBodyAccelerationJerkMagnitude","fMeanBodyAccelerationJerkMagnitudeFrequency","fMeanBodyGyroMagnitude","fMeanBodyGyroMagnitudeFrequency","fMeanBodyGyroJerkMagnitude","fMeanBodyGyroJerkMagnitudeFrequency","activity","subject")
merge(mergedMeansF, mergedMeansT,all=TRUE) -> FT
FT[,-(1)] -> FT
FT[,c(2, 1, 3:41,43:82)] -> FT
write.table(FT, "analysis.txt")


