argument <- commandArgs(trailingOnly = TRUE);
source("shared.R");

#working_range<- 1:220
#heldout_range<- 221:250

features_to_take <- scan("current_results/feature_took_final")

opts_grid <- get_opts_grid(argument)

do_more_tries <- function(opts) {
    return(more_tries(argument, 2, 0, opts));
}

results <- apply(opts_grid, 1, do_more_tries);
means <- results[1,];
errors <- results[2,];

best<-which.max(means);

write.table(opts_grid[best,], "current_results/best_options");
write(max(means), "current_results/test_result");

