arguments <- commandArgs(trailingOnly = TRUE);
argument <- arguments[1];
datafile <- arguments[2];
featurefile <- arguments[3];
resultfile <- arguments[4];
source("shared.R");

features_to_take <- scan(featurefile)

result <- more_tries(
                features_to_take,
           argument, 1,0
           );
 

write(result, resultfile); 
