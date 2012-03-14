argument <- commandArgs(trailingOnly = TRUE);

argument <- arguments[1];
datafile <- arguments[2];
resultfile <- arguments[3];
optionsfile <- arguments[4];

source("shared.R");

#working_range<- 1:220
#heldout_range<- 221:250

features_to_take <- scan("current_results/feature_took_final")

opts_grid <- get_opts_grid(argument)
gridsize <- length(opts_grid[,1])

pokus <-1
do_more_tries <- function(opts) {
    pokus<<-pokus+1
    print("pokus");
    
    print(pokus);
    print("ze");
    print(gridsize)
    return(more_tries(features_to_take, argument, 2, 0, opts));
}



results <- apply(opts_grid, 1, do_more_tries);
means <- results[1,];
errors <- results[2,];

best<-which.max(means);

write.table(opts_grid[best,], optionsfile);
write(c(max(means), errors[best]), resultfile);

