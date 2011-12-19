library(rpart)

all_table<-read.table("all_data")

working_table<-all_table[1:220,]
heldout_table<-all_table[221:250,]

features_to_take <- scan("feature_took_final")

pokus<-0;

try <- function(should_prune, splitting_type, min_split, c_p) {


    correctness <- 0
    pokus<<-pokus+1;
    print(pokus);
    for (cross_validation_number in (0:10)) {


        starting_line<-cross_validation_number*20+1;
        ending_line<-starting_line+19;

        train_table<-working_table[-starting_line:-ending_line,]
        test_table_with_class<-working_table[starting_line:ending_line, ]
        test_table_without_class <- test_table_with_class[, -1]
        correct_classes <- test_table_with_class[, 1]

        names <- names(test_table_without_class)[features_to_take==1]
        formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
        classifier<-rpart(formula, data=train_table, method="class",
            parms=list(split=splitting_type), control=rpart.control(cp=c_p,
                minsplit=min_split))
        
        if (should_prune>0) {
            classifier<-prune(classifier, cp=should_prune)
        }

        

        
        found_classes <- predict(classifier, test_table_without_class, type="class")
        same <- found_classes == correct_classes
        correctness<-correctness + length(same[same])
    }

    return(correctness/220)
}

possibilities <- expand.grid( c(0,0.002,0.005,0.01,0.02,0.05) , c("gini", "information"),
                    c(2, 5, 10, 20, 50, 100),
                    c(0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5))

correctnesses <- apply(possibilities, 1, 
                function(a) try(as.numeric(a[1]), a[2], as.numeric(a[3]),
                as.numeric(a[4])));

best<-which.max(correctnesses);

possibilities[best,]
max(correctnesses);
write.table(possibilities[best,], "best_possibilities");

