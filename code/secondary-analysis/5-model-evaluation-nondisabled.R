# load libraries
library(glmnetUtils)
library(tidyverse)
library(pROC)

# load test data
nondisab_test = read_csv("data/clean/secondary-analysis/nondisab_test.csv")

nondisab_test = nondisab_test %>% na.omit()

# ~~~~~~~~~~~~~~~~ load data ~~~~~~~~~~~~~~~~

# load ridge fit object
load("results/secondary-analysis/nondis_ridge_fit.Rda")

load("results/secondary-analysis/nondis_logistic_fit.Rda")

load("results/secondary-analysis/nondis_rf_fit.Rda")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# evaluate logistic regression fit

logistic_probabilities = predict(logistic_fit, 
                                 newdata = nondisab_test,
                                 type = "response")           # to get output on probability scale
logistic_predictions = as.numeric(logistic_probabilities > 0.55)

#misclassification rate: 
# make a tibble with the predictions
nondisab_test = nondisab_test %>% 
  mutate(log_unemployment = logistic_predictions)
# then calculate misclassification rate
nondisab_test %>% 
  summarise(mean(Unemployed != log_unemployment))
# rate is 18.1%
logistic_mis_rate <- 0.246

#To get a fuller picture, let's calculate the logistic regression confusion matrix:
nondisab_test %>% 
  select(Unemployed, log_unemployment) %>%
  table()

# ROC curve
roc_data_log = roc(nondisab_test %>% pull(Unemployed), 
                   logistic_probabilities) 
roc_curve_log = tibble(FPR = 1-roc_data_log$specificities,
                       TPR = roc_data_log$sensitivities) %>%
  ggplot(aes(x = FPR, y = TPR)) + 
  geom_line() + 
  geom_abline(slope = 1, linetype = "dashed") +
  theme_bw()
roc_curve_log
# print the AUC
roc_data_log$auc # 0.7264 

ggsave(filename = "results/secondary-analysis/logistic-roc-curve.png", 
       plot = roc_curve_log, 
       device = "png", 
       width = 6, 
       height = 4)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# evaluate ridge fit

ridge_probabilities = predict(ridge_fit, # fit object
                              newdata = nondisab_test, # new data to test on
                              s = "lambda.1se", # which value of lambda to use
                              type = "response") %>% # to output probabilities
  as.numeric() # convert to vector

ridge_predictions = as.numeric(ridge_probabilities > 0.47)

# misclassification rate:
# first add predictions to the tibble
nondisab_test = nondisab_test %>% 
  mutate(ridge_unemployment = ridge_predictions)

# then calculate misclassification rate
nondisab_test %>% 
  summarise(mean(Unemployed != ridge_unemployment))

ridge_mis_rate <- 0.245

#To get a fuller picture, let's calculate the Ridge regression confusion matrix:

nondisab_test %>% 
  select(Unemployed, ridge_unemployment) %>%
  table()

# ridge ROC
roc_data_ridge = roc(nondisab_test %>% pull(Unemployed), 
                     ridge_probabilities) 
roc_curve_ridge = tibble(FPR = 1-roc_data_ridge$specificities,
                         TPR = roc_data_ridge$sensitivities) %>%
  ggplot(aes(x = FPR, y = TPR)) + 
  geom_line() + 
  geom_abline(slope = 1, linetype = "dashed") +
  theme_bw()
roc_curve_ridge
# print the AUC
roc_data_ridge$auc # 0.7257

ggsave(filename = "results/secondary-analysis/ridge-roc-curve.png", 
       plot = roc_curve_ridge, 
       device = "png", 
       width = 6, 
       height = 4)


# ~~~~~~~~~~~~~~~~~~~~

# Random Forest
rf_probabilities = predict(rf_fit, n.trees = 500, mtry = 7,
                           type = "response", newdata = nondisab_test)
#rf_predictions = as.numeric(rf_probabilities > 0.5)

nondisab_test = nondisab_test %>% 
  mutate(rf_unemployment = rf_probabilities)
# then calculate misclassification rate
nondisab_test %>% 
  summarise(mean(Unemployed != rf_unemployment))
# rate is 16%
rf_mis_rate <- 0.232



# print nice table of total
tibble(Method = c("Ridge", "Logistic", "Random Forest"), 
       `Misclassification Rate` = c(ridge_mis_rate, logistic_mis_rate,
                                    rf_mis_rate)) %>%
  write_csv("results/secondary-analysis/nondis-model-evaluation.csv")
