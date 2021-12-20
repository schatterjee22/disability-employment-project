# load libraries
library(glmnetUtils)
library(tidyverse)
library(pROC)

# load test data
disab_test = read_csv("data/clean/primary-analysis/disab_test.csv")


# ~~~~~~~~~~~~~~~~ load fits ~~~~~~~~~~~~~~~~

load("results/primary-analysis/logistic_fit.Rda")

load("results/primary-analysis/ridge_fit.Rda")

load("results/primary-analysis/rf_fit.Rda")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# evaluate logistic regression fit

logistic_probabilities = predict(logistic_fit, 
                               newdata = disab_test,
                               type = "response")  # to get output on probability scale
logistic_predictions = as.numeric(logistic_probabilities > 0.5)

# misclassification rate: 
# make a tibble with the predictions
disab_test = disab_test %>% 
  mutate(log_unemployment = logistic_predictions)
# then calculate misclassification rate
disab_test %>% 
  summarise(mean(Unemployed != log_unemployment))

logistic_mis_rate <- 0.181

#Logistic regression confusion matrix:
disab_test %>% 
  select(Unemployed, log_unemployment) %>%
  table()

# ROC curve
roc_data_log = roc(disab_test %>% pull(Unemployed), 
               logistic_probabilities) 
roc_curve_log = tibble(FPR = 1-roc_data_log$specificities,
       TPR = roc_data_log$sensitivities) %>%
  ggplot(aes(x = FPR, y = TPR)) + 
  geom_line() + 
  geom_abline(slope = 1, linetype = "dashed") +
  #  geom_point(x = fpr, y = 1-fnr, colour = "red") +
  theme_bw()

# print the AUC
roc_data_log$auc # 0.8036, pretty good

# save logistic ROC curve
ggsave(filename = "results/primary-analysis/logistic-roc-curve.png", 
       plot = roc_curve_log, 
       device = "png", 
       width = 6, 
       height = 4)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# evaluate ridge fit

set.seed(1)
ridge_probabilities = predict(ridge_fit, # fit object
                              newdata = disab_test, # new data to test on
                              s = "lambda.1se", # which value of lambda to use
                              type = "response") %>% # to output probabilities
  as.numeric() # convert to vector

# vary threshold, found that 0.56 was the best
ridge_predictions = as.numeric(ridge_probabilities > 0.56)

# misclassification rate:
# first add predictions to the tibble
disab_test = disab_test %>% 
  mutate(ridge_unemployment = ridge_predictions)
# then calculate misclassification rate
disab_test %>% 
  summarise(mean(Unemployed != ridge_unemployment))

ridge_mis_rate <- 0.180

#Ridge regression confusion matrix:
disab_test %>% 
  select(Unemployed, ridge_unemployment) %>%
  table()

# ridge ROC
roc_data_ridge = roc(disab_test %>% pull(Unemployed), 
                     ridge_probabilities) 
roc_curve_ridge = tibble(FPR = 1-roc_data_ridge$specificities,
                         TPR = roc_data_ridge$sensitivities) %>%
  ggplot(aes(x = FPR, y = TPR)) + 
  geom_line() + 
  geom_abline(slope = 1, linetype = "dashed") +
  #  geom_point(x = fpr, y = 1-fnr, colour = "red") +
  theme_bw()
# print the AUC
roc_data_ridge$auc # 0.8071, pretty good

# save ridge ROC
ggsave(filename = "results/primary-analysis/ridge-roc-curve.png", 
       plot = roc_curve_ridge, 
       device = "png", 
       width = 6, 
       height = 4)

# ~~~~~~~~~~~~~~~~~~~~
# Random Forest
rf_probabilities = predict(rf_fit, n.trees = 500, mtry = 7,
                            type = "response", newdata = disab_test)
rf_probabilities # already 0s and 1s

# add to tibble
disab_test = disab_test %>% 
  mutate(rf_unemployment = rf_probabilities)
# then calculate misclassification rate
disab_test %>% 
  summarise(mean(Unemployed != rf_unemployment))

rf_mis_rate <- 0.158

# print nice table of total
tibble(Method = c("Ridge", "Logistic", "Random Forest"), 
       `Misclassification Rate` = c(ridge_mis_rate, logistic_mis_rate,
                                    rf_mis_rate)) %>%
  write_csv("results/primary-analysis/model-evaluation.csv")
