library(sqldf)
library(reshape2)


getTrainTestDataFrame <- function(){
  ## The train and test files
  x_train_file = "UCI HAR Dataset\\train\\X_train.txt"
  x_test_file = "UCI HAR Dataset\\test\\X_test.txt"
  
  ## Read the files into data frames 
  x_train = read.table(x_train_file, header=FALSE, sep="", row.names=NULL)
  x_test = read.table(x_test_file, header=FALSE, sep="", row.names=NULL)
  
  a <- x_test[1:nrow(x_test),]
  b <- x_train[1:nrow(x_train),]
  
  apply(a, 1,as.numeric)
  apply(b, 1,as.numeric)
  
  merged = rbind(x_train, x_test)
  ## return the rbinded test and training data frames.
  merged
}


combineDataFrames <- function(df_train_test, df_feature_names, df_activity_labels) {
  ## Assuming we downloaded the entire project files to the directory where this is run
  ## set variables for file names
  ## Depending on type of load asked, set file names from training or test as below
  ## Ex: x_data_file becomes the file for training or test. Same applies to y_file and subject files.
  ## ie. load the appropriate files for test/training as the case may be.
  
  y_data_file = ""
  subject_data_file = ""


  y_train_file = "UCI HAR Dataset\\train\\y_train.txt"  
  subject_train_file = "UCI HAR Dataset\\train\\subject_train.txt"    
  y_test_file = "UCI HAR Dataset\\test\\y_test.txt"  
  subject_test_file = "UCI HAR Dataset\\test\\subject_test.txt"
  
     
  y_train = read.table(y_train_file, header=FALSE, sep="")
  y_test = read.table(y_test_file, header=FALSE, sep="")
    
  subject_train = read.table(subject_train_file, header=FALSE, sep="", stringsAsFactors = TRUE)
  subject_test = read.table(subject_test_file, header=FALSE, sep="", stringsAsFactors = TRUE)
  
  
  ## row bind the y_data from test and train
  y_data = rbind(y_train, y_test)
  names(y_data) = c('id')
  
  ## row bind the subject data from test and train
  subject_data = rbind(subject_train, subject_test)
  names(subject_data) = c('subject')
  
  subject_data$subject = as.factor(subject_data$subject)
  
  ## knock off features we dont care and keep only selected features passed in.
  df_train_test = subset(df_train_test, select=df_feature_names$feature)
  ## Now, name the columns with the selected feature names passed in.
  names(df_train_test) = df_feature_names$feature
   
  ## join activity frame with y_data and set activity column for the id. 
  
  y_data$activity = sqldf("select df_activity_labels.activity from y_data, df_activity_labels where y_data.id=df_activity_labels.id")
  ## once activity is added, drop id column. We have a more descriptive named column instead now.
  y_data=subset(y_data, select=-c(id))
  
  ## Finally, stich the test_train data with subject and y_data and return
  df_train_test = cbind(df_train_test, subject_data, y_data$activity)
  df_train_test
}

getMergedData <- function() {
  ## load features and activity labels (common to both training and test data frames)
  
  ## Common files like activity and feature files to be used for both test and training
  activity_labels_file = "UCI HAR Dataset\\activity_labels.txt"
  feature_name_file = "UCI HAR Dataset\\features_names_modified.txt"
  
  ## load the modified feature names file into a data frame and lable the x_train with it
  feature_names = read.table(feature_name_file, header=FALSE, sep="")
  activity_labels = read.table(activity_labels_file, header=FALSE, sep="", stringsAsFactors = TRUE)
  
  names(activity_labels) = c('id', 'activity')
  names(feature_names) = c('id', 'feature')
  
  activity_labels$activity = as.factor(activity_labels$activity)

  ## select only features with mean and std in the attribute name
  selected_features = sqldf("select feature from feature_names where feature like '%mean%' or feature like '%std%'")
  
  trainTest = getTrainTestDataFrame()
  
  final = combineDataFrames(trainTest, selected_features, activity_labels)
  final
}

getTidyData <- function(){
  ## get merged data -- The main call to merge test and train, bind subject, activities together and return
  f = getMergedData()
  ## melt on subject and activity
  fMelt <- melt(f, id=c('subject','activity'))
  ## agregate and return
  tidyData <- dcast(fMelt, subject + activity ~ variable, fun.aggregate=mean)
  tidyData
}