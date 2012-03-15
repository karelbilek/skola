arguments <- commandArgs(trailingOnly = TRUE);
argument <- arguments[1];
datafile <- arguments[2];
resultfile <- arguments[3];
source("shared.R");

features_to_take <- scan("current_results/feature_took_final")

result <- more_tries(
                features_to_take,
           argument, 0,0
           );
 

write(result, resultfile)
