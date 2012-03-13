argument <- commandArgs(trailingOnly = TRUE);
source("shared.R");

features_to_take <- scan("current_results/feature_took_final")

result <- more_tries(
                features_to_take,
           argument, 1,0
           );
 

write(result, "current_results/test_result")
