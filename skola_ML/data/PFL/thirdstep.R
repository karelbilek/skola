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


if (type == 0) {

    

    result <- try(
                train_range, test_range
                ,
                features_to_take,
           model, 0,0
           );
} else {
    opts<-read.table( optionsfile);   
    result <- try(
                train_range, test_range,
                features_to_take,
           model, 2,0, opts);

}

print(modelfile);
save(result, file=modelfile)
print(result);
