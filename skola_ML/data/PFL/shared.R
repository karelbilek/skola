library(rpart)

all_table<-read.table("current_results/all_data")

default_opts <- function(type) {
        wat = c(min_split=20, 
                splitting_type = "gini",
                should_prune=0,
                c_p=0.01);
        return (wat);
}
get_opts_grid <- function() {
    return (expand.grid( 
        should_prune = c(0,0.001, 0.002,0.005,0.01,0.02,0.05, 0.1, 0.2, 0.5) , 
        splitting_type = c("gini", "information"),
        min_split = c(1, 2, 5, 10, 20, 50, 100),
        c_p = c(0.001, 0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5)
    ));
}

classify <- function(formula, train_data, test_data, opts) {

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

    found_classes <- predict(classifier, test_data, type = "class")
    
    return(found_classes);
}

try <- function(train_range, test_range, features, opts) {
        test_table_without_class <- all_table[test_range, -1]
        correct_classes <- all_table[test_range, 1]
        train_table <- all_table[train_range,]
        names <- names(test_table_without_class)[features==1]
        
        formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
       
        found_classes <- classify(formula, train_table, test_table_without_class, opts)
        
        same <- found_classes == correct_classes
        correctness<- length(same[same])
        return(correctness/length(test_range))
}


