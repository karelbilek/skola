argument <- commandArgs(trailingOnly = TRUE);
source("shared.R");

working_range<- 1:220

features_to_take <- scan("current_results/feature_took")

if (argument == "bagging") {
    argument = "DT"
}

average_correctness<-0;
for (cross_validation_number in (0:10)) {
    starting_line<-cross_validation_number*20+1;
    ending_line<-starting_line+19;
    average_correctness<-average_correctness +
        try(
            working_range[ -starting_line : -ending_line],
            working_range[ starting_line : ending_line],
            features_to_take,
            argument, 0, 0);
}

write(average_correctness/10, "current_results/experiment_output");

