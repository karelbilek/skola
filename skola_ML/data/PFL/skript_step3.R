library(rpart)

all_table<-read.table("all_data")

working_table<-all_table[1:220,]
test_table<-all_table[221:250,]

features_to_take <- scan("feature_took_final")
possibilities<-read.table( "best_possibilities");

try <- function(should_prune, splitting_type, min_split, c_p) {

print(should_prune)

    correctness <- 0



        test_table_without_class <- test_table[, -1]
        correct_classes <- test_table[, 1]

        names <- names(test_table_without_class)[features_to_take==1]
        formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
        classifier<-rpart(formula, data=working_table, method="class",
            parms=list(split=splitting_type), control=rpart.control(cp=c_p,
                minsplit=min_split))
        
        if (should_prune>0) {
            classifier<-prune(classifier, cp=should_prune)
        }

        

        
        found_classes <- predict(classifier, test_table_without_class, type="class")
        
        same <- found_classes == correct_classes
        correctness<-correctness + length(same[same])

    return(correctness/30)
}

result<-try(as.numeric(possibilities[1]), possibilities[2], possibilities[3], possibilities[4])
write(result, "test_result")
