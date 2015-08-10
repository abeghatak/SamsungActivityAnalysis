(I) The R script, run_analysis.R can be run on the Samsung Dataset and accomplishes the following-
      (1) Merges the training and the test sets to create one data set.
      (2) Extracts only the measurements on the mean and standard deviation for each measurement. 
      (3) Uses descriptive activity names to name the activities in the data set
      (4) Appropriately labels the data set with descriptive variable names. 
      (5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

(II) dir.data (under Para- Directory Paths) needs to be modified as per the user directory path.

(III) The program downloads the following output files-
      (a) file.downloadstatus records-
          (i)   time stamp- Download date & time
          (ii)  url.zip-URL of the data source (.zip)
          (iii) file.zip- Name of the local file where the file was downloaded
      (b) averages.txt-
          (i) The average of each activity per user, per feature (variable)
     The file is stored in the 'output' folder, which was created by the program
(IV) The Code Book for Variables is located in the sheet titled 'Feature Selection', in the file- 'codebookForVariables.xlsx' 
