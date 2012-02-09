tune <- commandArgs(trailingOnly = TRUE)[1];
type <- commandArgs(trailingOnly = TRUE)[2];

if (tune==2) {
    opts<-read.table("current_results/second_options");
} else {
    opts <- NULL; 
}

source("shared.R");

working_range<- 1:250

features_to_take <- scan("current_results/second_features");

pokus <- 1;
more_tries <- function(opts) {
    average_correctness <- 0
   
   print(pokus);
   pokus <<- pokus +1;


    for (cross_validation_number in (0:9)) {
        starting_line<-cross_validation_number*25+1;
        ending_line<-starting_line+24;
        average_correctness<-average_correctness +
            try(
                working_range[ -starting_line : -ending_line],
                working_range[ starting_line : ending_line],
                features_to_take,
                type, tune, 0, 
                opts
            );
   }

   print (average_correctness/10);
   return(average_correctness/10)
}

res <- more_tries(opts);

write(res, "current_results/second_result");

