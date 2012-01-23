library(rpart)
library(e1071)

all_table<-read.table("current_results/all_data")


try <- function(train_range, test_range, features, type, tune, boost) {
        test_table_without_class <- all_table[test_range, -1]
        correct_classes <- all_table[test_range, 1]
        train_table <- all_table[train_range,]
        names <- names(test_table_without_class)[features==1]
        
        formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
      
        if (type=="DT") {
            if (tune==0) {
               classifier<-rpart(
                    formula, 
                    data = train_table, 
                    method = "class")
            } else {
                classifier<-best.rpart(
                    formula,
                    data = train_table,
                    ) 
            }
            found_classes <- predict(classifier, test_table_without_class, type = "class")
        }
        
        same <- found_classes == correct_classes
        correctness<- length(same[same])
        return(correctness/length(test_range))
}


