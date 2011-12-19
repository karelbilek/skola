library(rpart)

all_table<-read.table("all_data")

working_table<-all_table[1:220,]
test_table<-all_table[221:250,]




    correctness <- 0



        test_table_without_class <- test_table[, -1]
        correct_classes <- test_table[, 1]
       
        most_freq <- which.max(table(working_table[,1]))
      
        max(table(working_table[,1]))
        which.max(table(working_table[,1]))
        working_table[,1]

        same <- most_freq == correct_classes
        correctness<-correctness + length(same[same])

    correctness/30

write(correctness/30, "baseline_result")
