argument <- commandArgs(trailingOnly = TRUE);
source("shared.R");
working_range<- 1:220
test_range<- 221:250

features_to_take <- scan("current_results/feature_took_final")

result <- try(
            working_range, test_range,
                features_to_take,
           argument, 1,0
           );
 

write(result, "current_results/test_result")
