arguments <- commandArgs(trailingOnly = TRUE);
model <- arguments[1];
type <- arguments[2];
datafile <- arguments[3];
optionsfile <- arguments[4];
featurefile <- arguments[5];
modelfile <- arguments[6]

source("shared.R");

features_to_take <- scan(featurefile)

train_range = c(1:250);
test_range = c(-1,-1);


   opts<-read.table( optionsfile);  
   final <- more_tries( features_to_take,
           model, 2,0, opts);

    result <- try(
                train_range, test_range,
                features_to_take,
           model, 2,0, opts);


print(result);
save(result, file=modelfile)
