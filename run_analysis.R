## run_analysis.R
## Author: Brandon Fetters

# Downloads the UCI HAR Dataset and stores it in the data directory. It
# also calls loadData() to merge the different files into a single dataframe.
downloadData <- function() {
    
    # Create folder to store data if it doesn't exist
    if (!file.exists(dataDir)) {
        dir.create(dataDir)
    }
    
    # Only download zip file if it doesn't exist
    zipURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    if (!file.exists(destFile)) {
        download.file(zipURL, destfile=destFile)
    }
    
    # Load features for column naming
    features <- read.table(unzip(destFile, "UCI HAR Dataset/features.txt"))[,2]
    
    # Combine training and test data into single dataframe
    data <- rbind(loadData("train", features), loadData("test", features))
    
}

# Will load and merge all files related to a specific dataset split (train/test)
# Feature names are also loaded and used as column names for X.
loadData <- function(dataset, X_features) {
    
    # Identifies subject who performed the activity 
    filename <- paste("subject_", dataset, ".txt", sep="")
    filepath <- file.path("UCI HAR Dataset", dataset, filename)
    subject <- read.table(unzip(destFile, filepath), col.names="subject")
    
    filename <- paste("X_", dataset, ".txt", sep="")
    filepath <- file.path("UCI HAR Dataset", dataset, filename)
    X <- read.table(unzip(destFile, filepath), col.names=X_features)
    
    filename <- paste("y_", dataset, ".txt", sep="")
    filepath <- file.path("UCI HAR Dataset", dataset, filename)
    y <- read.table(unzip(destFile, filepath), col.names="activity")
    
    # Join each separate file into single dataframe
    data <- cbind(subject, X, y)
}

# Extract only the mean and standard deviation measurement columns.
extractMeanAndStdDev <- function() {
    pattern <- "subject|\\.mean\\.|\\.std\\.|activity"
    valid_columns <- grep(pattern, names(data), value=TRUE)
    data <- data[, valid_columns]
}

# Import Required Libraries
library(plyr);

# Constants
dataDir <- './data'
destFile <- file.path(dataDir, "uci_har_dataset.zip")
outFile <- file.path(dataDir, "uci_har_tidy.txt")

# 1. Merges the training and the test sets to create one data set.
# 4. Appropriately labels the data set with descriptive variable names.
data <- downloadData()

# 2. Extracts only the measurements on the mean and standard deviation
data <- extractMeanAndStdDev()

# 3. Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table(unz(destFile, "UCI HAR Dataset/activity_labels.txt"))[,2]
data <- mutate(data, activity=factor(activity, labels=activity_labels))

# 5. Creates independent tidy data set with the average of each variable
#    for each activity and each subject.
data_avgs <-aggregate(. ~subject + activity, data, mean)
data_avgs <- data_avgs[order(data_avgs$subject, data_avgs$activity), ]
write.table(data_avgs, file=outFile, row.names=FALSE)