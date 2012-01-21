library(rpart)

all_table<-read.table("current_results/all_data")

working_table<-all_table[1:220,]
heldout_table<-all_table[221:250,]

features_to_take <- scan("current_results/feature_took_final")

#tohle by 100% slo pres objekty, ale ty jsou v R nejak hrozne divne

get_opts <- function() {
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

pokus<-0;

try <- function(opts) {

    correctness <- 0
    pokus<<-pokus+1;
    for (cross_validation_number in (0:10)) {


        starting_line<-cross_validation_number*20+1;
        ending_line<-starting_line+19;

        train_table<-working_table[-starting_line:-ending_line,]
        test_table_with_class<-working_table[starting_line:ending_line, ]
        test_table_without_class <- test_table_with_class[, -1]
        correct_classes <- test_table_with_class[, 1]

        names <- names(test_table_without_class)[features_to_take==1]
        formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
        
        found_classes <- classify(
            formula, 
            train_table,
            test_table_without_class,
            opts);
        
        same <- found_classes == correct_classes
        correctness<-correctness + length(same[same])
    }

    return(correctness/220)
}


opts_grid <- get_opts()

correctnesses <- apply(opts_grid, 1, try);

best<-which.max(correctnesses);

opts_grid[best,]
write.table(opts_grid[best,], "current_results/best_possibilities");
write(max(correctnesses), "current_results/k_fold__result");

