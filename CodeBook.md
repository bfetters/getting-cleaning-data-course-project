# Instructions

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

[http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Here are the data for the project:

[https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Download Data
Download the USI HAR data as a .zip file from the url referenced above.

```r
# Import Required Libraries
library(plyr);

# Constants
dataDir <- './data'
destFile <- file.path(dataDir, "uci_har_dataset.zip")
outFile <- file.path(dataDir, "uci_har_tidy.txt")

# 1. Merges the training and the test sets to create one data set.
# 4. Appropriately labels the data set with descriptive variable names.
data <- downloadData()
```

```r
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
```

# Load and Merge Data
Once the data is downloaded the relevant data files (X, y, and subject) for both training and test are merged to form a single dataframe. This ensures all transformations are performed against the entire dataset.

```r
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
```
 
# Extract the mean and standard deviation for each measurement
For the purpose of this project we only want to use the mean and standard deviation measurements for each variable.

```r
# 2. Extracts only the measurements on the mean and standard deviation
data <- extractMeanAndStdDev()
```

```r
# Extract only the mean and standard deviation measurement columns.
extractMeanAndStdDev <- function() {
    pattern <- "subject|\\.mean\\.|\\.std\\.|activity"
    valid_columns <- grep(pattern, names(data), value=TRUE)
    data <- data[, valid_columns]
}
```

# Use activity names instead of numerical values
To make the activity values more interpretable use the activity names in place of the numerical values.

```r
# 3. Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table(unz(destFile, "UCI HAR Dataset/activity_labels.txt"))[,2]
data <- mutate(data, activity=factor(activity, labels=activity_labels))
```
# Create a new tidy dataset with the average of each variable for each activity and each subject.
```r
# 5. Creates independent tidy data set with the average of each variable
#    for each activity and each subject.
data_avgs <-aggregate(. ~subject + activity, data, mean)
data_avgs <- data_avgs[order(data_avgs$subject, data_avgs$activity), ]
```

# Write new tidy dataset to file
```r
write.table(data_avgs, file=outFile, row.names=FALSE)
```