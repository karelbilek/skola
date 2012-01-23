argument <- commandArgs(trailingOnly = TRUE);
source("shared.R");

working_range<- 1:220
heldout_range<- 221:250

features_to_take <- scan("current_results/feature_took")

correctness <- 
    try(working_range, heldout_range, features_to_take, "DT",0,0);

write(correctness, "current_results/experiment_output");

