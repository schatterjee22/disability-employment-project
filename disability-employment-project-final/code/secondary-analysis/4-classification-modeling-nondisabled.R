# load libraries
library(tidyverse)
library(randomForest)
library(glmnetUtils)
source("code/functions/plot_glmnet.R")
library(randomForest)


# read in the training data
nondisab_train = read_csv("data/clean/secondary-analysis/nondisab_train.csv")
nondisab_train = nondisab_train %>% na.omit()

# ~~~~~~~~~~~~~~~ Logistic Regression ~~~~~~~~~~~~~~~

# logistic regression
set.seed(471)
logistic_fit <- glm(Unemployed ~ .,
                    family = "binomial",
                    data = nondisab_train)

summary(logistic_fit)
save(logistic_fit, file = "results/secondary-analysis/nondis_logistic_fit.Rda")

# ~~~~~~~~~~~~~~~ Ridge Regression ~~~~~~~~~~~~~~~

set.seed(471)
ridge_fit = cv.glmnet(Unemployed ~ ., # formula notation, as usual
                      alpha = 0, # alpha = 0 means ridge
                      nfolds = 10, # number of CV folds
                      family = "binomial", # to specify logistic regression
                      type.measure = "class", # use misclassification error in CV
                      data = nondisab_train)

summary(ridge_fit)

ridge.plot<-plot(ridge_fit)

ggsave(filename = "results/secondary-analysis/ridge_plot.png", 
       plot = ridge.plot, 
       device = "png", 
       width = 6, 
       height = 4)

glmnet.nondis<-plot_glmnet(ridge_fit, nondisab_train, features_to_plot = 5)

ggsave(filename = "results/secondary-analysis/ridge_glmnet.png", 
       plot = glmnet.nondis, 
       device = "png", 
       width = 6, 
       height = 4)

save(ridge_fit, file = "results/secondary-analysis/nondis_ridge_fit.Rda")

# ~~~~~~~~~~~~~~~ Random Forest ~~~~~~~~~~~~~~~

set.seed(471)
rf_3 = randomForest(factor(Unemployed) ~ ., mtry = 3, data = nondisab_train)
rf_7 = randomForest(factor(Unemployed) ~ ., mtry = 7, data = nondisab_train)
rf_13 = randomForest(factor(Unemployed) ~ ., mtry = 13, data = nondisab_train)
oob_errors = bind_rows(
  tibble(ntree = 1:500, oob_err = rf_3$err.rate[,"OOB"], m = 3),
  tibble(ntree = 1:500, oob_err = rf_7$err.rate[,"OOB"], m = 7),
  tibble(ntree = 1:500, oob_err = rf_13$err.rate[,"OOB"], m = 13)
)
oob_errors %>%
  ggplot(aes(x = ntree, y = oob_err, colour = factor(m))) +
  geom_line() + theme_bw()
# looks like mtry = 7 is the best

# make rf_fit
set.seed(471)
rf_fit = randomForest(factor(Unemployed) ~ ., mtry = 7, importance = TRUE, data = nondisab_train)

# plot OOB error
tibble(oob_error = rf_fit$err.rate[,"OOB"],
       trees = 1:500) %>%
  ggplot(aes(x = trees, y = oob_error)) + geom_line() + theme_bw()

# see variable importance
varImpPlot(rf_fit)

save(rf_fit, file = "results/secondary-analysis/nondis_rf_fit.Rda")

ggsave(filename = "results/secondary-analysis/rf-var-imp-chart.png", 
       plot = implot, 
       device = "png", 
       width = 6, 
       height = 4)
varImpPlot(rf_fit)
dev.off()
