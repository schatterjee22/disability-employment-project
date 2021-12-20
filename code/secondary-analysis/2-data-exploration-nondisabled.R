# Load in training data for both data sets
nondisab_train = read_csv("data/clean/secondary-analysis/nondisab_train.csv")

#Training Data Evaluation
library(tidyverse)
#Make bar plot of employment for training set
bar.nondis<-nondisab_train%>%
  ggplot() +
  geom_bar(aes(x = factor(Unemployed)))+
  labs(x = "Employment (Unemployed If = 1)", y = "Count")+
  theme_bw()+ 
  ggtitle("Training Data Distribution on Response Variable\n(Without Disabilities)")

ggsave(filename = "results/secondary-analysis/training_barplot.png", 
       plot = bar.nondis, 
       device = "png", 
       width = 6, 
       height = 4)
bar.nondis

#Overall Correlations
library(psych)
corr<- nondisab_train%>%
  select(-Unemployed)
corplot_nondis<-corPlot(corr,cex = 0.3, xlas = 2, cex.axis=0.6)

ggsave(filename = "results/secondary-analysis/training_correlation.png", 
       plot = corplot_nondis, 
       device = "png", 
       width = 6, 
       height = 4)
dev.off()
