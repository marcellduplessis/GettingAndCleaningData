setwd("C:\\Users\\mduplessis\\Desktop\\DataScience_Studies\\GettingAndCleaningData")

if(dir.exists("./UCI HAR Dataset")==FALSE) {
        stop("The 'UCI HAR Dataset' folder could not be found in the current Working Directory.
             \n  Please set your working directory or, save the folder to it.")
}

# Package check
# TODO: write as anon function in apply.
if (!require("dplyr")) {install.packages("dplyr");require("dplyr") }
if (!require("data.table")) {install.packages("data.table"); require("data.table")}
if (!require("reshape2")) {install.packages("reshape2"); require("reshape2")}


# load data
        # load the features data.....(variables reported by the devices)
        features <- read.table("./UCI HAR Dataset/features.txt",stringsAsFactors = F)[,2]
        
        # load activity label....(walking, sitting, standing etc)....
        activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

        # Load subject training and Test data
        subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
        subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

        # Load X training and Test data
        x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
        x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")

        # Load Y training and Test data
        y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
        y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

# merge the 3 datasets.
        subject_all <- rbind(subject_train, subject_test)
        x_all <- rbind(x_train, x_test)
        y_all <- rbind(y_train, y_test)
        
        # cleanup some mem.
        rm("subject_train","subject_test","x_train", "x_test","y_train", "y_test")
        
# transform X
        # name the features of X based on the features dataset.
        names(x_all) <- features 
        
        # keep only columns for mean and std
        # we could do this with which or grep(l).
        x_all <- x_all[,grep("-mean|-std", names(x_all))]
        

# transform Y
        # join the Descriptive activity name from activity labels.
        # keep only the named
        y_all <- merge(y_all, activity_labels, by="V1")[2]
        
        # name the fields
        names(y_all) <- c("activity")
        

# transform SUBJECT datasets
        # Create a second data set with the average of each variable for each 
        # activity and subject.
        
        # name the V1 column
        names(subject_all) <- "subject"

        # merge all datasets with cbind. ensure that the ALL* datasets were made 
        # with training and testing setsin the correct order
        all_data <- cbind(subject_all, y_all, x_all)

# unpivot the data using melt (reshape2)
all_data_unpivot = melt(all_data, id.var = c("subject", "activity"))

# add and mean of each variable as a new field and cast using dcat (reshape2)
output = dcast(all_data_unpivot , subject + activity ~ variable, mean)

# write the results to a file called tidy_data.txt
write.table(output, file="./tidy_data.txt", row.name=FALSE)