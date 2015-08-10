url.zip <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
url.desc <- "http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones"

#####################
## Directory Paths ##
#####################
dir.data <- file.path("/Users/abhijitghatak/Documents/Abe_Mac/abe/Study Courses/Getting & Cleaning Data", fsep=.Platform$file.sep) # assignment forces this
dir.input <- file.path(dir.data, "UCI HAR Dataset", fsep=.Platform$file.sep)
dir.output <- file.path(dir.data, "output", fsep=.Platform$file.sep)

#####################
## File Paths ##
#####################
file.zip <- file.path(dir.data, "UCI_HAR_Dataset.zip")
file.downloadstatus <- file.path(dir.data, "download_status.txt")
file.activity_labels <- file.path(dir.input, "activity_labels.txt", fsep=.Platform$file.sep)
file.features <- file.path(dir.input, "features.txt", fsep=.Platform$file.sep)
file.train.subject <- file.path(dir.input, "train", "subject_train.txt", fsep=.Platform$file.sep)
file.train.x <- file.path(dir.input, "train", "X_train.txt", fsep=.Platform$file.sep)
file.train.y <- file.path(dir.input, "train", "y_train.txt", fsep=.Platform$file.sep)
file.test.subject <- file.path(dir.input, "test", "subject_test.txt", fsep=.Platform$file.sep)
file.test.x <- file.path(dir.input, "test", "X_test.txt", fsep=.Platform$file.sep)
file.test.y <- file.path(dir.input, "test", "y_test.txt", fsep=.Platform$file.sep)
file.tidy <- file.path(dir.output, "tidy.txt")
# file.activitymap <- file.path(dir.output, "activitymap.txt")
# file.featuremap <- file.path(dir.output, "featuremap.txt")
file.averages <- file.path(dir.output, "averages.txt")

#####################
## Settings ##
#####################
# setting.display.tidy = TRUE
# setting.display.activitymap = TRUE
# setting.display.featuremap = TRUE

###########################################
## Create data directory (if !not exist) ##
###########################################
if(!file.exists(dir.data)) {
  dir.create(dir.data, recursive=TRUE)
}

#####################
## Download Data ##
#####################
download.file(url.zip, destfile=file.zip, method="curl")
tstamp <- date()
dump(c("url.zip", "file.zip", "tstamp"), file=file.downloadstatus)

#####################
## Unzip Data ##
#####################
unzip(file.zip, exdir=dir.data)

library(data.table)
library(reshape2)
library(dplyr)

###########################################
## Create data directory (if !not exist) ##
###########################################
if(!file.exists(dir.output)) {
  dir.create(dir.output, recursive=TRUE)
}

######################
## Get Subject Data ##
#####################
# Each row identifies the subject who performed the activity for each window sample.
#Its range is from 1 to 30.
data.train.subject <- fread(file.train.subject)
data.test.subject <- fread(file.test.subject)
data.tidy <- rbindlist(list(data.train.subject, data.test.subject))
rm("data.train.subject", "data.test.subject")

#########################
## Get Activity Labels ##
#########################
data.activity_labels <- fread(file.activity_labels)
data.activity_labels$V3 <- strsplit(data.activity_labels$V2, "_")
data.activity_labels$V3 <- sapply(
  data.activity_labels$V3,
  function(x) paste(toupper(substring(x, 1,1)), tolower(substring(x, 2)), sep="", collapse="")
)
setnames(data.activity_labels, c("ActivityId", "OriginalName", "ConvertedName"))
# if(setting.output.activitymap) {
#   write.table(data.activity_labels, file=file.activitymap, row.names=FALSE)
# }

#####################
# Get Y Data ##
#####################
data.train.y <- fread(file.train.y)
data.train.y <- mutate(data.train.y, V1 = factor(V1, levels=data.activity_labels$ActivityId, labels=data.activity_labels$ConvertedName))
data.test.y <- fread(file.test.y)
data.test.y <- mutate(data.test.y, V1 = factor(V1, levels=data.activity_labels$ActivityId, labels=data.activity_labels$ConvertedName))
data.tidy <- cbind(data.tidy,rbindlist(list(data.train.y, data.test.y)))
rm("data.train.y", "data.test.y", "data.activity_labels")

#####################
## Get Features ##
#####################
data.features <- fread(file.features, stringsAsFactors=FALSE)
data.features <- data.features[grep("^[a-zA-Z]+-(mean|std)\\(\\)(-[XYZ])?$", data.features$V2),]
data.features$V3 <- sub("^([a-zA-Z]+)-mean\\(\\)(-([XYZ]))?$", "\\1\\3Mean", data.features$V2)
data.features$V3 <- sub("^([a-zA-Z]+)-std\\(\\)(-([XYZ]))?$", "\\1\\3Std", data.features$V3)
setnames(data.features, c("ColumnNumber", "OriginalFeatureName", "ConvertedFeatureName"))
# if(setting.output.featuremap) {
#   write.table(data.features, file=file.featuremap, row.names=FALSE)
# }

#####################
## Get X Data ##
#####################
data.train.x <- data.table(read.table(file.train.x, stringsAsFactors=FALSE)[,data.features$ColumnNumber])
data.test.x <- data.table(read.table(file.test.x, stringsAsFactors=FALSE)[,data.features$ColumnNumber])
data.tidy <- cbind(data.tidy,rbindlist(list(data.train.x, data.test.x)))
rm("data.train.x", "data.test.x")

#######################
## Set Column Names ##
#######################
setnames(data.tidy, c("Subject", "Activity", data.features$ConvertedFeatureName))
rm("data.features")

###############################################################
## Calculate Mean of Each Feature per Activity per Subject ##
###############################################################
data.averages <- dcast(
  melt(data.tidy, c("Subject", "Activity")),
  Subject + Activity ~ variable,
  mean
)

#####################
## Save Results ##
#####################
# if(setting.output.tidy) {
#   write.table(data.tidy, file=file.tidy, row.names=FALSE)
# }
write.table(data.averages, file=file.averages, row.names=FALSE)

################### END #####################