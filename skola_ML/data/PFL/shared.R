library(rpart)
library(e1071)
library(adabag)

all_table<-read.table("current_results/all_data")

get_opts_grid <- function(type) {
    if (type=="bagging") {
        return (expand.grid( 
            min_split = c( 2, 10, 50, 100),
            c_p = c( 0.002,0.01,0.05,0.2),
            mfinal = c(10,20,50,100,200)            
        ));
    }
    if (type=="boosting") {
        return (expand.grid( 
            min_split = c( 10, 50, 100),
            c_p = c( 0.01,0.05,0.2),
            mfinal = c(10,50,100,200),            
            boos = c(TRUE, FALSE),
            coeflearn = c("Breiman", "Freund", "Zhu")
        ));
    }

    if (type=="DT") {
        return (expand.grid( 
            should_prune = c(0,0.001, 0.002,0.005,0.01,0.02,0.05, 0.1, 0.2, 0.5) , 
            splitting_type = c("gini", "information"),
            min_split = c(1, 2, 5, 10, 20, 50, 100),
            c_p = c(0.001, 0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5)
        ));
    }
    if (type=="SVM") {
        grid <- (expand.grid(
            scale = c(TRUE, FALSE),
            kernel = c("linear", "polynomial", "radial basis", "sigmoid"),
            degree = c(1,2,3),
            gamma = c(0, 1/50,1/20,1/10, 1/5, 1/2),
            coef0 = c(0,1,2,5,10,20),
            cost = c(0.1,0.2,0.5,1),
            shrinking = c(TRUE,FALSE),
            probability = c(TRUE,FALSE)
        ))
        grid <- grid[
            (grid["kernel"]!="linear" | grid["gamma"]==1/50)
            &
            (grid["kernel"]=="polynomial" | grid["kernel"]=="sigmoid" | grid["coef0"]==0 ) 
            &
            ( grid["kernel"] == "polynomial" | grid["degree"]==1),];
        return (grid);
    }
}

my_as_logical<-function(string) {
    if (string == " TRUE") {
        
        return(TRUE);
    }
    return (FALSE);
}

custom_classifier <- function(type, formula, train_data, opts) {
    if (type=="bagging") {
        control = rpart.control(
            cp = as.numeric(opts["c_p"]),
            minsplit = as.numeric(opts["min_split"])
        )
        classifier<-bagging(
            formula,
            data = train_data, 
            mfinal = as.numeric(opts["mfinal"]));


    }
    if (type=="boosting") {
        control = rpart.control(
            cp = as.numeric(opts["c_p"]),
            minsplit = as.numeric(opts["min_split"])
        )
        classifier<-boosting(
            formula,
            data = train_data, 
            mfinal = as.numeric(opts["mfinal"]),
            boos = my_as_logical(opts["boos"]),
            coeflearn = opts["coeflearn"]);
    }


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

    }
    if (type == "SVM") {
        if (opts["kernel"]=="linear") {
            classifier <- svm(formula,
                            data=train_data,
                            scale = my_as_logical(opts["scale"]),
                            cost = as.numeric(opts["cost"]),
                            shrinking = my_as_logical(opts["shrinking"]),
                            probability = my_as_logical(opts["probability"]))
            
        }
        if (opts["kernel"]=="polynomial") {
            if (opts["gamma"]==0) {
                classifier <- svm(formula,
                                data=train_data,
                                scale = my_as_logical(opts["scale"]),
                                cost = as.numeric(opts["cost"]),
                                shrinking = my_as_logical(opts["shrinking"]),
                                coef0 = as.numeric(opts["coef0"]),
                                probability = my_as_logical(opts["probability"]),
                                degree = as.numeric(opts["degree"]))
             } else {
                classifier <- svm(formula,
                                data=train_data,
                                scale = my_as_logical(opts["scale"]),
                                cost = as.numeric(opts["cost"]),
                                shrinking = my_as_logical(opts["shrinking"]),
                                coef0 = as.numeric(opts["coef0"]),
                                probability = my_as_logical(opts["probability"]),
                                gamma = as.numeric(opts["gamma"]),
                                degree = as.numeric(opts["degree"]))
             }
        }
        if (opts["kernel"]=="radial basis") {
            if (opts["gamma"]==0) {
                classifier <- svm(formula,
                                data=train_data,
                                scale = my_as_logical(opts["scale"]),
                                cost = as.numeric(opts["cost"]),
                                shrinking = my_as_logical(opts["shrinking"]),
                                probability = my_as_logical(opts["probability"]),
                                degree = as.numeric(opts["degree"]))
             } else {
                classifier <- svm(formula,
                                data=train_data,
                                scale = my_as_logical(opts["scale"]),
                                cost = as.numeric(opts["cost"]),
                                shrinking = my_as_logical(opts["shrinking"]),
                                probability = my_as_logical(opts["probability"]),
                                gamma = as.numeric(opts["gamma"]),
                                degree = as.numeric(opts["degree"]))
             }
        }    
        if (opts["kernel"]=="") {
            if (opts["gamma"]==0) {
                classifier <- svm(formula,
                                data=train_data,
                                scale = my_as_logical(opts["scale"]),
                                cost = as.numeric(opts["cost"]),
                                shrinking = my_as_logical(opts["shrinking"]),
                                probability = my_as_logical(opts["probability"]),
                                degree = as.numeric(opts["degree"]))
             } else {
                classifier <- svm(formula,
                                data=train_data,
                                scale = my_as_logical(opts["scale"]),
                                cost = as.numeric(opts["cost"]),
                                shrinking = my_as_logical(opts["shrinking"]),
                                probability = my_as_logical(opts["probability"]),
                                gamma = as.numeric(opts["gamma"]));
             }
        }
     }
    
        return (classifier);
}

more_tries <- function(features_to_take, type, tune, boost, opts) {
   average_correctness <- 0
  
    working_range <- 1:250;


    results <- c();

#pomohl jsem si http://www.cyclismo.org/tutorial/R/confidence.html#t
   
   for (cross_validation_number in (0:9)) {
        print(cross_validation_number);
        starting_line<-cross_validation_number*25+1;
        ending_line<-starting_line+24;
        
        results <- c( results,
            try(
                working_range[ -starting_line : -ending_line],
                working_range[ starting_line : ending_line],
                features_to_take,
                type, tune, boost, 
                opts
            ));
   }

   m<-mean(results);
   error <- qt(0.975,df=length(results)-1)*sd(results)/sqrt(length(results));


   return(c(m,error));
}


try <- function(train_range, test_range, features, type,tune, boost,
                custom_options=NULL) {
        test_table_without_class <- all_table[test_range, -1]
        correct_classes <- all_table[test_range, 1]
        train_table <- all_table[train_range,]
        names <- names(test_table_without_class)[features==1]
        
        formula <- as.formula(paste("semantic_class ~ ", paste(names, collapse= "+")))
      
        formula <- as.formula("semantic_class ~ .");
        if (type=="baseline") {
       
            most_freq <- which.max(table(train_table[,1]))
            found_classes <- rep(most_freq, length(correct_classes))
 
        }
        if (type=="bayes") {
            #no options
            levels = levels(all_table[, "semantic_class"])
            train_table[, "semantic_class"] =
                   factor(train_table[,"semantic_class"], levels=levels);

           test_copy = test_table_without_class;
           test_copy[, "semantic_class"] = 
                factor(levels[0], levels=levels)

            classifier <- naiveBayes(train_table[,-1], train_table[,1]);
            found_classes <- predict(classifier, test_copy,
                            type="class");
        }

        if (type=="bagging" | type=="boosting") {
           #this is absolutely weird, but R is weird, I can't help it
           #first, I make train_table into factor

            train_table[, "semantic_class"] =
                   factor(train_table[,"semantic_class"]);
            levels = levels(train_table[, "semantic_class"])

            test_copy = test_table_without_class;
            test_copy[, "semantic_class"] = 
                factor(levels[0], levels=levels)

            if (type == "bagging") {
                if (tune==0) {
                    classifier<-bagging(formula, train_table);
                } else if (tune==2) {
                    classifier <- custom_classifier("bagging", formula,
                                            train_table, custom_options);

                }
            


                found_classes <- predict.bagging(classifier,
                                    newdata = test_copy);
            } else {
                if (tune==0) {
                    classifier<-boosting(formula, train_table);
                } else if (tune==2) {
                    classifier <- custom_classifier("boosting", formula,
                                            train_table, custom_options);

                }
            


                found_classes <- predict.boosting(classifier,
                                    newdata = test_copy);
                 
 
            }
            found_classes <- found_classes$class;
        }

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
            if (tune==0) {
                classifier <- svm(
                    formula,
                    data = train_table,
                    type = "C-classification"
                )
            }
            if (tune == 1) {
                classifier<-best.svm(
                    formula,
                    data = train_table,
                    type = "C-classification"
                    ) ;
            }
            if (tune == 2) {
                classifier <- custom_classifier("SVM", formula, train_table,
                                                    custom_options);
            }
            found_classes <- predict(classifier, test_table_without_class)

        }
       

        same <- found_classes == correct_classes
        correctness<- length(same[same])
        return(correctness/length(test_range))
}


