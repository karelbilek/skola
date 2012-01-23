library(rpart)
library(e1071)

all_table<-read.table("current_results/all_data")

get_opts_grid <- function(type) {
    if (type=="DT") {
        return (expand.grid( 
            should_prune = c(0,0.001, 0.002,0.005,0.01,0.02,0.05, 0.1, 0.2, 0.5) , 
            splitting_type = c("gini", "information"),
            min_split = c(1, 2, 5, 10, 20, 50, 100),
            c_p = c(0.001, 0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5)
        ));
    }



}

custom_classifier <- function(type, formula, train_data, opts) {
    
    if (type=="DT") {
        classifier<-rpart(
            formula, 
            data = train_data, 
            method = "class",
            parms = list (
                split = opts["splitting_type"]
            ), 
            control = rpart.control(
                cp = as.numeric(opts["c_p"]),
                minsplit = as.numeric(opts["min_split"])
            )
        )
        
        if (as.numeric(opts["should_prune"]) > 0) {
            classifier<-prune(
                classifier , 
                cp = as.numeric(opts["should_prune"])
            )
        }

        return (classifier);
    }

    
    
}

try <- function(train_range, test_range, features, type,tune, boost,
                custom_options=NULL) {
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
            } else if (tune==1){
                classifier<-best.rpart(
                    formula,
                    data = train_table,
                    ) 
            } else if (tune == 2) {
                classifier <- custom_classifier("DT", formula, train_table,
                                                    custom_options);
            }
            found_classes <- predict(classifier, test_table_without_class, type = "class")
        }
        if (type=="SVM") {
            classifier <- svm(
                formula,
                data = train_table,
                type = "C-classification"
            )
            found_classes <- predict(classifier, test_table_without_class)
        }
        
        same <- found_classes == correct_classes
        correctness<- length(same[same])
        return(correctness/length(test_range))
}


