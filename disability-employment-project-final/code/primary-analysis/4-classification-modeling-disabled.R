# load libraries
library(tidyverse)
library(randomForest) # for random forest

# read in the training data
disab_train = read_csv("data/clean/primary-analysis/disab_train.csv")


# ~~~~~~~~~~~~~~~ Logistic Regression ~~~~~~~~~~~~~~~

# logistic regression
set.seed(1)
logistic_fit <- glm(Unemployed ~ .,
    family = "binomial",
    data = disab_train)

summary(logistic_fit)
save(logistic_fit, file = "results/primary-analysis/logistic_fit.Rda")

# ~~~~~~~~~~~~~~~ Ridge Regression ~~~~~~~~~~~~~~~
# run regression
set.seed(1)
ridge_fit = cv.glmnet(Unemployed ~ ., # formula notation, as usual
                      alpha = 0, # alpha = 0 means ridge
                      nfolds = 10, # number of CV folds
                      family = "binomial", # to specify logistic regression
                      type.measure = "class", # use misclassification error in CV
                      data = disab_train)

summary(ridge_fit)

# cv plot
plot(ridge_fit)

# trace plot
plot_glmnet(ridge_fit, disab_train, features_to_plot = 10)

# save fit for eval
save(ridge_fit, file = "results/primary-analysis/ridge_fit.Rda")

# save cv plot
png(width = 8, 
    height = 4,
    res = 300,
    units = "in", 
    filename = "results/primary-analysis/ridge-cv-plot.png")
plot(ridge_fit)
dev.off()

# save trace plot
png(width = 8, 
    height = 4,
    res = 300,
    units = "in", 
    filename = "results/primary-analysis/ridge-trace-plot.png")
plot_glmnet(ridge_fit, disab_train, features_to_plot = 5)
dev.off()

# ~~~~~~~~~~~~~~~ Random Forest ~~~~~~~~~~~~~~~
# run mtry selection
set.seed(1)
rf_3 = randomForest(factor(Unemployed) ~ ., mtry = 3, data = disab_train)
rf_7 = randomForest(factor(Unemployed) ~ ., mtry = 7, data = disab_train)
rf_13 = randomForest(factor(Unemployed) ~ ., mtry = 13, data = disab_train)
oob_errors = bind_rows(
  tibble(ntree = 1:500, oob_err = rf_3$err.rate[,"OOB"], m = 3),
  tibble(ntree = 1:500, oob_err = rf_7$err.rate[,"OOB"], m = 7),
  tibble(ntree = 1:500, oob_err = rf_13$err.rate[,"OOB"], m = 13)
)
# plot mtry options
mtry_plot = oob_errors %>%
  ggplot(aes(x = ntree, y = oob_err, colour = factor(m))) +
  geom_line() + theme_bw()
# looks like mtry = 7 is the best

# save mtry plot
png(width = 5, 
    height = 4,
    res = 300,
    units = "in", 
    filename = "results/primary-analysis/rf-mtry-plot.png")
mtry_plot
dev.off()

# make rf_fit
set.seed(1)
rf_fit = randomForest(factor(Unemployed) ~ ., mtry = 7, importance = TRUE, data = disab_train)

# plot OOB error
rf_oob_error = tibble(oob_error = rf_fit$err.rate[,"OOB"],
       trees = 1:500) %>%
  ggplot(aes(x = trees, y = oob_error)) + geom_line() + theme_bw()

# save OOB error
png(width = 6, 
    height = 4,
    res = 300,
    units = "in", 
    filename = "results/primary-analysis/rf-oob-error.png")
rf_oob_error
dev.off()

# see variable importance
varImpPlot(rf_fit)

# save rf fit
save(rf_fit, file = "results/primary-analysis/rf_fit.Rda")

# save variable importance
png(width = 7, 
    height = 6,
    res = 300,
    units = "in", 
    filename = "results/primary-analysis/rf-var-imp-chart.png")
varImpPlot(rf_fit)
dev.off()
