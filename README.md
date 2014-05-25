gettingandcleaningdata
======================

Coursera-getting and cleaning data
Filename: run_analysis.R

Pre-processing:
	* The feature name file was gloabally cleaned up to make variable names more readable.
		- removed "()" 
		- replaced commas with _
		- expanded Acc to Acceleration
		- reformated the angular variables for better readability
		- replaced "-" with "_"
		- Rationale to keep _ instead of commmas and dashes is to avoid messing with querying latter either using sqldf or otherwise on data frames
		- the file was saved as features_names_modified.txt and used in the program

Main Function: getTidyData()
	1. Main function to prepare the data from training and test data sets
	2. Calls the getMergedData() function.
	3. Melts the data frames and aggregates to produce the tidyData set needed for the project

Function: getMergedData()
	1. Loads and creates activity, feature files for train and test data
	2. Selects only features that we care about (mean and std deviation ones) - using features_names_modified.txt
	3. calls function getTrainTestDataFrames()
	4. calls combineDataFrames() with test/train data frames got in step 3 and merges with selected features, activities
	5. Returns the combined test/train data frames with all features and activities

Function: getTrainTestDataFrame()
	1. Loads the test and train data frames
	2. makes their columns numeric
	3. rbinds them and returns

Function: combineDataFrame()
	1. takes merged test/train data set, feature data frame, activity data frame as parameters
	2. rbinds the y_data loaded for test and train first
	3. Replaces activity ID with name using sqldf library using a join an activity and y_data files
	4. drops id column and retains only the text activity name
	5. column binds test/train data frame with subject and activity data frames and returns
	
