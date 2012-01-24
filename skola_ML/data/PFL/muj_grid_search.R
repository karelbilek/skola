argument <- commandArgs(trailingOnly = TRUE);
source("shared.R");

working_range<- 1:220
heldout_range<- 221:250

features_to_take <- scan("current_results/feature_took_final")

more_tries <- function(opts) {
    average_correctness <- 0
    
    for (cross_validation_number in (0:10)) {
        starting_line<-cross_validation_number*20+1;
        ending_line<-starting_line+19;
        average_correctness<-average_correctness +
            try(
                working_range[ -starting_line : -ending_line],
                working_range[ starting_line : ending_line],
                features_to_take,
                argument, 2, 0, 
                opts
            );
   }

   return(average_correctness/10)
}


opts_grid <- get_opts_grid(argument)

correctnesses <- apply(opts_grid, 1, more_tries);

best<-which.max(correctnesses);

write.table(opts_grid[best,], "current_results/best_options");
write(max(correctnesses), "current_results/k_fold__result");

