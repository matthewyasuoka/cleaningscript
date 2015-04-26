
I used R Version 3.4.0 on mac. 
The script requires: data.table and deplyer
 
The script is divided into different parts. 

The first segment error is used to return an error message if the UCI HAR Dataset is not in the WD. 

Next, I set all the file locations in the data set as objects. 

Then, I read the table files “labels_doc” and “activity_labels_doc” respectively. 
The first table I read in was test. This section labeled “##xtest” in the script reads the table using  read.table to read in the doc with the column names, I converted it into data.table using the data.table command into an object called x_test, then y_test was fread in. I then read the two tables into a single merged table. In order to do this, I created an index row in each “a” that would allow the two to be matched using setkey called xy_test. The subject data was added here. I repeated the same process with the XY_train data. 

I then combined the data and set a column for each type of data “test” and “train” in case I needed it later. 

To find the columns that were means or STDs I used the grep command I was put onto this idea by browsing stackoverFlow and found this thread http://stackoverflow.com/questions/19637816/selecting-data-by-the-name-grep-function it was helpful and saved time. 

After selecting the columns and subsetting them. I returned to the test_train emerged data set and used the column with the activity data “V1” and wrote an ifelse function to create a $activity column with the different readable activity names. These were applied. I then created a column in the subset, std_means, for the activity data using “stds_means$activity <- test_train$activity”

I then subset stds_means by the activity type and calculated the mean for each column based on the subject. I used rbind to put the 6 subsets back together. 
Finally, I split it into F and T and wrote all the names. 

Then, I wrote the file.