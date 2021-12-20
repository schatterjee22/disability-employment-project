# read in the cleaned data
nondisabled = read_csv("data/clean/secondary-analysis/Final_Non_Disabled_Data.csv")


# split into train and test (set seed here if applicable)
set.seed(471)
n = nrow(nondisabled)
train_samples = sample(1:n, round(0.8*n))
nondisab_train = nondisabled[train_samples,]
nondisab_test = nondisabled[-train_samples,]


# save the train and test data
write_csv(x = nondisab_train, file = "data/clean/secondary-analysis/nondisab_train.csv")
write_csv(x = nondisab_test, file = "data/clean/secondary-analysis/nondisab_test.csv")
