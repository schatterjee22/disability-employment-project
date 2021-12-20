# The Effect of Disability on Within-Group Employment<br/>STAT  471 Final Project<br/>Emma Ronzetti and Shivani Chatterjee <br/>December 2021

In the three decades since the enactment of the Americans with Disabilities Act of 1990, economic outcomes for people with disabilities have remained lower than those for people without disabilities. While the Act contains provisions for the protection of disabled employment, the employment of people with disabilities still falls behind its non-disabled counterpart. Thus, in this project we seek to understand the predictive factors behind unemployment among people with disabilities as well as people without disabilities. Better understanding these factors can inform policy makers about the best ways to address the employment gap, and related economic outcomes, between the abled and disabled at a large scale.

Our data set extracted data and predictors from four data sets, primarily from the Annual Social and Economic supplement (ASEC) of the U.S. Census Bureau’s Current Population Survey (CPS) and the Equal Employment Commission’s yearly report of Americans with Disabilities Act violations, to determine which demographic factors may be contributing to the outsized unemployment people with disabilities face. To have a better understanding of the unique challenges people with disabilities face, we compare our findings with a secondary analysis of the same non-disability demographic predictors of employment for people without disabilities.

We began with exploratory analysis of correlations among our features and also examined the observations for class imbalance. After doing so, we began the analysis of each subset (disabled and non-disabled) by splitting the data observations into training and test sets, then training a logistic regression, ridge regression, and random forest fit on each of the training sets. After calculating misclassification rates for each of the models on each of the subsets, we found that for both data subsets, the random forest fit produced the lowest misclassification rate and was the overall best prediction method. Within each subset analysis, the logistic and ridge regressions produced similar misclassification rates.

All three models suggested a similar set of important predictors of unemployment, for both people with disabilities and without. We focused on the findings of the random forest fits for comparison, since we deemed random forest to be the best prediction method. We found that age, educational attainment, having minor children, and the total number of ADA violations in the state of residence were the most important factors affecting unemployment among both subsets. For the disabled-only subset, disabilities related to certain physical difficulties as well as mental and other disabilities were also important predictors for unemployment.

Policies aimed at addressing the struggles of individuals with young children, supporting individuals seeking higher education, and eliminating employment discrimination, especially that against people with disabilities, can assist individuals seeking employment in the U.S. To specifically aid the disabled community, our analysis suggests policymakers understand that people with some disabilities, such as mental, physical, mental health, and learning disabilities, face a higher risk of unemployment than others, and thus should search for opportunities to best support this underserved subset of society. Finally, we suggest some limitations of our study, such as the limited scope of disability survey collection and analysis. 

## Data Sources

Data was sourced from 3 different websites.

ASEC of the CPI: U.S. Census Bureau

The csv files for household, family, and person level data can be accessed here: https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.2019.html
Please click on the "CSV Data File (includes Replicate Weights)" to download.
*Household and Person Level Data from the ASEC was not uploaded (see gitignore) due to file size. Please download the data and name it "Household CPS Data" and "Person CPS Data" to follow the code. Thank you.*

Americans with Disabilities Act Violations (2019) Per State : EEOC

The csv file was created based on the data found here: https://www.eeoc.gov/statistics/americans-disabilities-act-1990-ada-charges-charges-filed-eeoc-includes-concurrent

Political Affliations of U.S. State Governors: Ballotopedia

Political affiliations of governors were found here: https://ballotpedia.org/List_of_governors_of_the_American_states
