library(rpart)

all_table<-read.table("all_data")

working_table<-all_table[1:220,]
heldout_table<-all_table[221:250,]

features_to_take <- scan("feature_took")

correctness <- 0
for (cross_validation_number in (0:10)) {


    starting_line<-cross_validation_number*20+1;
    ending_line<-starting_line+19;

    train_table<-working_table[-starting_line:-ending_line,]
    test_table_with_class<-working_table[starting_line:ending_line, ]
    test_table_without_class <- test_table_with_class[, -1]
    correct_classes <- test_table_with_class[, 1]

    names <- names(test_table_without_class)[features_to_take==1]
    formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
    classifier<-rpart(formula, data=train_table, method="class")
    
    found_classes <- predict(classifier, test_table_without_class, type="class")
    same <- found_classes == correct_classes
    correctness<-correctness + length(same[same])
}

write(correctness/220, "experiment_output")

