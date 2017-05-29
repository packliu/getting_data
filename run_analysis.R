#set up the work directory, "username" is just a notice and need to change to the proper one for your own computer
setwd('/Users/"username"/desktop/UCI HAR Dataset');

# Read in the data from files
features <- read.table('./features.txt',header=FALSE); 
activity <- read.table('./activity_labels.txt',header=FALSE); 

sub_train <- read.table('./train/subject_train.txt',header=FALSE); 
xtrain       <- read.table('./train/x_train.txt',header=FALSE); 
ytrain       <- read.table('./train/y_train.txt',header=FALSE); 

colnames(activity)  <- c('activity_name','activity_type');
colnames(sub_train)  <- "subject_name";
colnames(xtrain)        <- features[,2]; 
colnames(ytrain)        <- "activity_name";

train_data <- cbind(ytrain,sub_train,xtrain);

sub_test <- read.table('./test/subject_test.txt',header=FALSE); 
xtest       <- read.table('./test/x_test.txt',header=FALSE); 
ytest       <- read.table('./test/y_test.txt',header=FALSE); 

colnames(sub_test) <- "subject_name";
colnames(xtest)       <- features[,2]; 
colnames(ytest)       <- "activity_name";

test_data <- cbind(ytest,sub_test,xtest);


# Combine training and test data to create a final data set
comb_data <- rbind(train_data,test_data);
colNames  <- colnames(comb_data); 

# Create a vector that contains TRUE values for the ID, mean() & stddev() columns and FALSE for others
SelectVect <- (grepl("activity..",colNames) | grepl("subject..",colNames) | grepl("-mean..",colNames) & !grepl("-meanFreq..",colNames) & !grepl("mean..-",colNames) | grepl("-std..",colNames) & !grepl("-std()..-",colNames));
comb_data <- comb_data[SelectVect==TRUE];
comb_data <- merge(comb_data,activity,by='activity_name',all.x=TRUE);
colNames  <- colnames(comb_data); 

# Cleaning up the variable names
for (i in 1:length(colNames)) 
{
  colNames[i] = gsub("\\()","",colNames[i])
  colNames[i] = gsub("-std$","StdDev",colNames[i])
  colNames[i] = gsub("-mean","Mean",colNames[i])
  colNames[i] = gsub("^(t)","time",colNames[i])
  colNames[i] = gsub("^(f)","freq",colNames[i])
  colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
  colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
  colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
  colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
  colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
  colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
  colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
};


colnames(comb_data) = colNames;

combdata_noactivity  <- comb_data[,names(comb_data) != 'activity_type'];

tidy_data    <- aggregate(combdata_noactivity[,names(combdata_noactivity) != c('activity_name','subject_name')],by=list(activity_name=combdata_noactivity$activity_name,subject_name = combdata_noactivity$subject_name),mean);
tidy_data    <- merge(tidy_data,activity,by='activity_name)',all.x=TRUE);

write.table(tidy_data, './clean_data.txt',row.names=TRUE,sep='\t');