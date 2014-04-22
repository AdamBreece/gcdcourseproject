# Load required libraries here
library(data.table)
library(plyr)

# File paths
# Assumes working directory has "UCI HAR Dataset" directory which
# contains the dataset.

dataDir <- "UCI HAR Dataset"
featuresPath <- paste(dataDir, "features.txt", sep = "/")
labelPath <- paste(dataDir, "activity_labels.txt", sep = "/")

xTrainPath <- paste(dataDir, "train/X_train.txt", sep = "/")
yTrainPath <- paste(dataDir, "train/y_train.txt", sep = "/")
subTrainPath <- paste(dataDir, "train/subject_train.txt", sep = "/")

xTestPath <- paste(dataDir, "test/X_test.txt", sep = "/")
yTestPath <- paste(dataDir, "test/y_test.txt", sep = "/")
subTestPath <- paste(dataDir, "test/subject_test.txt", sep = "/")

#### PART 1: Create a merged, cleaned data set ####
print("Reading dataset, this may take a bit...")

## Step 0: Read and prep metadata

featureNames <- as.character(read.table(featuresPath)[,2])
actLabels <- fread(labelPath)
setkey(actLabels, V1)
actLabels[,V2 := factor(actLabels[,V2])]

## Step 1: Merge the training and the test sets to create one data set.

# The blank line at the start of X_test and X_train breaks fread (known bug) 
# so we read it with read.table first, then make it a data.table.

trainFrame <- read.table(xTrainPath, col.names=featureNames)
testFrame <- read.table(xTestPath, col.names=featureNames)

mergedData <- rbindlist(list(trainFrame, testFrame))	# returns data.table
setnames(mergedData, featureNames)

## Step 2: Extract only the measurements on the mean and 
## 			 standard deviation for each measurement.

# Find column names missing -mean() or -std(), and remove them
# Note: this includes removing meanfreq() columns.
removeThese <- grep("(-mean\\(\\)|-std\\(\\))", names(mergedData), invert=T)
mergedData[,c(removeThese) := NULL]

# use data.table to join activity labels to activities
activities <- rbind(fread(yTrainPath), fread(yTestPath))
setkey(activities,V1)
activities <- activities[actLabels]

subjects <- rbind(fread(subTrainPath), fread(subTestPath))

mergedData[, activity := activities[,V2]]
mergedData[, subject.id := subjects]


# Assumed to mean only use measurements with -mean() and -std() in their name
# in the tidy data set

# Creates a second, independent tidy data set with the average of each variable
# for each activity and each subject. 