## Load packages
library(downloader)
library(tidyverse)

## Create data directory
if(!file.exists("./projectata")){
  dir.create("./projectData")
  }

## Download dataset and unzip file
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./projectData/Dataset.zip")){
  download(zipUrl, destfile = "./projectData/Dataset.zip")
  }
   
if(!file.exists("./projectData/UCI HAR Dataset")){
  unzip(zipfile = "./projectData/Dataset.zip",exdir = "./projectData")
  }

## Read feature.txt and save as vector of variable names
features <- read_delim("./projectData/UCI HAR Dataset/features.txt", delim = " ", col_names = c("id", "variable"))
varNames <- features %>%
  select(variable) %>%
  sapply(as.character) %>%
  as.vector

## Clean-up variable names
varNames <- varNames %>%
  str_replace("BodyBody", "Body")

## Read activity labels
activityLabels <- read_table("./projectData/UCI HAR Dataset/activity_labels.txt", col_names = c("activity_id", "activity"))

## Download train data and bind into one dataset
xTrain <- read_table("./projectData/UCI HAR Dataset/train/X_train.txt", col_names = varNames)
yTrain <- read_table("./projectData/UCI HAR Dataset/train/Y_train.txt", col_names = "activity_id")
subjectTrain <- read_table("./projectData/UCI HAR Dataset/train/subject_train.txt", col_names = "subject")
dataTrain <- bind_cols(subjectTrain, yTrain, xTrain)

## Download test data and bind into one dataset
xTest <- read_table("./projectData/UCI HAR Dataset/test/X_test.txt", col_names = varNames)
yTest <- read_table("./projectData/UCI HAR Dataset/test/Y_test.txt", col_names = "activity_id")
subjectTest <- read_table("./projectData/UCI HAR Dataset/test/subject_test.txt", col_names = "subject")
dataTest <- bind_cols(subjectTest, yTest, xTest)

## Combine into one dataset, label with descriptive activity names, and narrow dataset to only means and std deviation
data <- bind_rows(dataTrain, dataTest) %>%
  left_join(activityLabels) %>%
  select(subject, activity, -activity_id, contains("mean"), contains("std"))
  
## Summarize and return the mean of every measurement.
subjectActivityMean <- data %>%
  group_by(subject, activity) %>%
  summarize_each(funs(mean))

## Write summarized dataset to a txt file
write_csv(subjectActivityMean, "./subjectActivityMean.csv", append = FALSE)