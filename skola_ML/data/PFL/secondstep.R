arguments <- commandArgs(trailingOnly = TRUE);
model <- arguments[1];
type <- arguments[2];
datafile <- arguments[3];
optionsfile <- arguments[4];

source("shared.R");

features_to_take <- scan("current_results/feature_took_final")

if (type == 0) {

    result <- more_tries(
                features_to_take,
           model, 0,0
           );
} else {
    opts<-read.table( optionsfile);   
    result <- more_tries(
                features_to_take,
           model, 2,0, opts);

}

print(result);
# write(result, resultfile)
