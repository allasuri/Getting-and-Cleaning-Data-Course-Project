library(dplyr)
#Download the File from the given website and Unzip it
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"

if (!file.exists(zipFile)) {
  download.file(zipUrl, zipFile, mode = "wb")
}

#DP - data path
DP <- "UCI HAR Dataset"
if (!file.exists(DP)) {
  unzip(zipFile)
}

#Read the data into the respective sets
trainingSubjects <- read.table(file.path(DP, "train", "subject_train.txt"))
trainingValues <- read.table(file.path(DP, "train", "X_train.txt"))
trainingActivity <- read.table(file.path(DP, "train", "y_train.txt"))

testSubjects <- read.table(file.path(DP, "test", "subject_test.txt"))
testValues <- read.table(file.path(DP, "test", "X_test.txt"))
testActivity <- read.table(file.path(DP, "test", "y_test.txt"))

features <- read.table(file.path(DP, "features.txt"), as.is = TRUE)

# read activity labels
activities <- read.table(file.path(DP, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")

#Merge the training and test data
# concatenate individual data tables to make single data table
humanActivity <- rbind(
  cbind(trainingSubjects, trainingValues, trainingActivity),
  cbind(testSubjects, testValues, testActivity)
)

# remove individual data tables to save memory
rm(trainingSubjects, trainingValues, trainingActivity, 
   testSubjects, testValues, testActivity)

# assign column names
colnames(humanActivity) <- c("subject", features[, 2], "activity")

#Extract the mean and standard deviation of each measurement
columnsToKeep <- grepl("subject|activity|mean|std", colnames(humanActivity))
humanActivity <- humanActivity[, columnsToKeep]

humanActivity$activity <- factor(humanActivity$activity, 
                                 levels = activities[, 1], labels = activities[, 2])


#Create a second, independent tidy set with the average of each variable for each activity and each subject
humanActivityMeans <- humanActivity %>% group_by(subject, activity) %>% summarise_each(funs(mean))
write.table(humanActivityMeans, "tidydata.txt", row.names = FALSE, 
                                        quote = FALSE)

