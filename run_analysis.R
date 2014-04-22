# Load required libraries here
library(data.table)
library(plyr)

#### PART 1: Create a merged, cleaned data set ####

## Step 0: Read column names
featureNames <- read.table("features.txt")[,2]

## Step 1: Merge the training and the test sets to create one data set.

# The blank line at the start of X_test and X_train breaks fread (known bug) 
# so we read it with read.table first, then make it a data.table.
testFrame <- read.table("test/X_test.txt", col.names=featureNames)
trainFrame <- read.table("train/X_train.txt", col.names=featureNames)

mergedData <- rbindlist(list(trainFrame, testFrame))

activities <- rbind(fread("test/y_test.txt"), fread("train/y_train.txt"))
setnames(activities,"Activity")

## Step 3: Appropriately label the activities. 


## Step 4 (was 2): Extract only the measurements on the mean and 
## 			 standard deviation for each measurement.

# Assumed to mean only use measurements with -mean() and -std() in their name
# in the tidy data set

# Creates a second, independent tidy data set with the average of each variable
# for each activity and each subject. 