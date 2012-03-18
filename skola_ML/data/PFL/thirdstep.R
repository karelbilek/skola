arguments <- commandArgs(trailingOnly = TRUE);
model <- arguments[1];
type <- arguments[2];
datafile <- arguments[3];
optionsfile <- arguments[4];
resultfile <- arguments[5];
featurefile <- arguments[6];
modelfile <- arguments[7]

source("shared.R");

features_to_take <- scan(featurefile)

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

#print(result);
write(result, resultfile);
save(result, file=modelfile)
