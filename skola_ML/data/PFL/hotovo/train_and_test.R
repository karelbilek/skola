library(rpart)
library(e1071)
library(adabag)

type <- commandArgs(trailingOnly = TRUE);
train_table<-read.table("train_data")
test_table<-read.table("test_data")

train_table[, "semantic_class"] =
        factor(train_table[,"semantic_class"]);
levels = levels(train_table[, "semantic_class"])

test_table_copy = test_table;

test_table_copy[, "semantic_class"] = 
    factor(levels[0], levels=levels)

if (type == "bagging") {

    classifier<-bagging("semantic_class ~ .", train_table);
    
    found_classes <- predict.bagging(classifier,
                        newdata = test_table_copy);
} else {
    classifier<-boosting("semantic_class ~ .", train_table);


    found_classes <- predict.boosting(classifier,
                        newdata = test_table_copy);
}

found_classes <- found_classes$class;
correct_classes <- test_table[, 1]

same <- found_classes == correct_classes

correctness<- length(same[same])
        
res <- (correctness/length(same))

res
