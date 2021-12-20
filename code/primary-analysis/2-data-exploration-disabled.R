# Load in training data for both data sets
disab_train = read_csv("data/clean/primary-analysis/disab_train.csv")


#Training Data Evaluation
library(tidyverse)
#Make bar plot of employment for training set
dis.bar<-disab_train%>%
  ggplot() +
  geom_bar(aes(x = factor(Unemployed)))+
  labs(x = "Employment (Unemployed If = 1)", y = "Count")+
  theme_bw()+
  ggtitle("Training Data Distribution on Response Variable\n(With Disabilities)")

ggsave(filename = "results/primary-analysis/training_barplot.png", 
       plot = dis.bar, 
       device = "png", 
       width = 6, 
       height = 4)


#Overall Correlations
library(psych)
corr<- disab_train%>%
  select(-Unemployed)
corPlot(corr,cex = 0.3, xlas = 2, cex.axis=0.6)
dev.off()