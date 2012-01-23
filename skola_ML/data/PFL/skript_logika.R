library(rpart)

all_table<-read.table("current_results/all_data")


try <- function(train_range, test_range, features, opts) {
        test_table_without_class <- all_table[test_range, -1]
        correct_classes <- all_table[test_range, 1]
        train_table <- all_table[train_range,]
        names <- names(test_table_without_class)[features==1]
        
        formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
       
        tuneobj <- tune.rpart(formula, train_table);
        classifier <- best.rpart(formula, tuneobj)

        found_classes <- predict(classifier, test_table_without_class, 
                    type = "class")


        
        same <- found_classes == correct_classes
        correctness<- length(same[same])
        return(correctness/length(test_range))
}

working_range<- 1:220
test_range<- 221:250

features_to_take <- scan("current_results/feature_took_final")

result <- try(
            working_range, test_range,
                features_to_take,
                opts
            );
 

write(result, "test_result")
