# Load required libraries here
library(plyr)
library(reshape2)
library(data.table)

# File paths assume working directory has "UCI HAR Dataset" directory which
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
print("Reading UCI HAR dataset, this may take a bit...")

## Step 0: Read and prep metadata

featureNames <- as.character(read.table(featuresPath)[,2])
actLabels <- fread(labelPath)
setnames(actLabels, c("activity.id", "activity"))
setkey(actLabels, activity.id)
actLabels[,activity := factor(actLabels[,activity])]

## Step 1: Merge the training and the test sets to create one data set.

# The blank line at the start of X_test and X_train breaks fread (known bug) 
# so we read it with read.table first, then make it a data.table.

trainFrame <- read.table(xTrainPath, col.names=featureNames)
testFrame <- read.table(xTestPath, col.names=featureNames)

mergedData <- rbindlist(list(trainFrame, testFrame))	# returns data.table
setnames(mergedData, featureNames)

## Step 2: Extract only the measurements on the mean and 
## 			 standard deviation for each measurement.
print("Extracting mean() and std() features...")

# Find column names missing -mean() or -std(), and remove them.
# Note: columns with meanfreq() are NOT kept.

removeThese <- grep("(-mean\\(\\)|-std\\(\\))", names(mergedData), invert=T)
mergedData[,c(removeThese) := NULL]

activities <- rbind(fread(yTrainPath), fread(yTestPath))
subjects <- (rbind(fread(subTrainPath), fread(subTestPath)))

print("Adding activity and subject.id columns...")
mergedData[, activity.id := activities]
mergedData[, subject.id := subjects]

# use data.table to join activity labels to activities column
print("Labeling activities...")
setkey(mergedData,activity.id)
mergedData <- mergedData[actLabels]
mergedData[,activity.id := NULL]

print("Done merging and cleaning. Merged dataset available as data.table mergedData")

#### PART 1: Create second, independent tidy data set with the average 
####         of each variable for each activity and each subject.

print("Creating independent tidy data set with mean of each variable for each activity and subject...")

melted <- data.table:::melt.data.table(mergedData, id.vars=c("activity","subject.id"))
tidyData <- data.table::dcast.data.table(melted, activity + subject.id ~ variable, mean)

print("Tidy dataset available as data.table tidyData")

print("Saving tidy dataset as tidy.csv")
write.csv(tidyData,file="tidy.csv")

# 

## should return 53
## length(mergedData[activity.id == 5 & subject.id == 1, activity.id])
## length(mergedData[activity == "STANDING" & subject.id == 1, activity.id])
