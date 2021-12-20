# read in the cleaned data
disability = read_csv("data/clean/primary-analysis/Final_Disability_Data.csv")

# split into train and test (set seed here if applicable)
set.seed(1)
n = nrow(disability)
train_samples = sample(1:n, round(0.8*n))
disab_train = disability[train_samples,]
disab_test = disability[-train_samples,]
disab_train = disab_train %>% na.omit()
disab_test = disab_test %>% na.omit()


# save the train and test data
write_csv(x = disab_train, file = "data/clean/primary-analysis/disab_train.csv")
write_csv(x = disab_test, file = "data/clean/primary-analysis/disab_test.csv")
