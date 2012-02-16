argument <- commandArgs(trailingOnly = TRUE);
source("shared.R");
working_range<- 1:220
test_range<- 221:250

features_to_take <- scan("current_results/feature_took_final")


result <- try(
            working_range, test_range,
                features_to_take,
           "baseline", 0,0
           );
 

print(result)

se<-sqrt(result*(1-result)/30)
print (result-1.96*se)
print (result+1.96*se)
