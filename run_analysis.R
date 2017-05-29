library(dplyr)

feature <- read.table("UCI HAR Dataset/features.txt")
activitylabel <- read.table("UCI HAR Dataset/activity_labels.txt")

# only extract columns for mean() and std()
extract <- feature[grepl("mean()",feature[,2],fixed=TRUE)|grepl("std()",feature[,2],fixed=TRUE),1]

# combine test and train dataset
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_activity <- read.table("UCI HAR Dataset/train/y_train.txt")
train_feature <- read.table("UCI HAR Dataset/train/X_train.txt")
train_feature <- select(train_feature, extract)
train_data <- cbind(train_subject, train_activity, train_feature)

test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_activity <- read.table("UCI HAR Dataset/test/y_test.txt")
test_feature <- read.table("UCI HAR Dataset/test/X_test.txt")
test_feature <- select(test_feature, extract)
test_data <- cbind(test_subject, test_activity, test_feature)

comb_data <- rbind(train_data, test_data)
names(comb_data) <- c("subject", "activity", feature[extract,2])
m <- factor(as.factor(comb_data[,2]), levels=activitylabel[,1],labels=activitylable[,2])
comb_data$activitylabel <- m
comb_data <- select(comb_data,-activitylabel)

# creat the tidy dataset
g_col <- c("subject", "activity_labels")
dots <- laaply(g_col, as.symbol)
g_data <- group_by_(comb_data,.dots=dots)
tidy_data <- summarise_each(g_data, funs(mean))
write.table(tidy_data, file="tidydata.txt", row.names=FALSE)