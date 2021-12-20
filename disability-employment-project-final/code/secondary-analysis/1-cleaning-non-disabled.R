library(tidyverse)

# ~~~~~~~~~~~~~~~~ Load Data ~~~~~~~~~~~~~~~~
#Household Data
cps.h<-tibble(read.csv("data/raw/Household CPS Data.csv"))
#Family Data
cps.f<-tibble(read.csv("data/raw/Family CPS Data.csv"))
#Person Data
cps.p<-tibble(read.csv("data/raw/Person CPS Data.csv"))
#ADA Cases Data
ada<-tibble(read.csv("data/raw/ADA Charges By State.csv"))

# ~~~~~~~~~~~~~~~~ Clean Data Sets~~~~~~~~~~~~~~~~

#Clean household to only have GESTFIPS, GTMETSTA, and H_SEQ
house<- cps.h%>%
  select(GESTFIPS, H_SEQ, GTMETSTA)%>%
  rename(PH_SEQ = H_SEQ)

#Clean family to only have FH_SEQ and FOWNU18
family<- cps.f%>%
  select(FH_SEQ, FOWNU18)%>%
  rename(PH_SEQ = FH_SEQ)

person <- cps.p%>%
  filter(PRDISFLG == 2)%>% #Only people without disabilities
  filter(AGE1 >= 3)%>% #Remove all people below age 18
  select(PH_SEQ, A_HGA, AGE1, A_SEX, PRCITSHP, A_MARITL,
         PEHSPNON, PRDTRACE, PEAFEVER,
         PEPAR1TYP, PEPAR2TYP, PEFNTVTY, PEMNTVTY,
         COV, MIGSAME, PEARNVAL, PRCOW1) 

#Combine Household and Personal Data
disabled<-left_join(person, house, by = c("PH_SEQ"))
disabled<-left_join(disabled, family, by = c("PH_SEQ"))

#Change FIPS Values to States
disabled$GESTFIPS[disabled$GESTFIPS == 1]<-"Alabama"
disabled$GESTFIPS[disabled$GESTFIPS == 2]<-"Alaska"
disabled$GESTFIPS[disabled$GESTFIPS == 4]<-"Arizona"
disabled$GESTFIPS[disabled$GESTFIPS == 5]<-"Arkansas"
disabled$GESTFIPS[disabled$GESTFIPS == 6]<-"California"
disabled$GESTFIPS[disabled$GESTFIPS == 8]<-"Colorado"
disabled$GESTFIPS[disabled$GESTFIPS == 9]<-"Connecticut"
disabled$GESTFIPS[disabled$GESTFIPS == 10]<-"Delaware"
disabled$GESTFIPS[disabled$GESTFIPS == 11]<-"Washington, D.C."
disabled$GESTFIPS[disabled$GESTFIPS == 12]<-"Florida"
disabled$GESTFIPS[disabled$GESTFIPS == 13]<-"Georgia"
disabled$GESTFIPS[disabled$GESTFIPS == 15]<-"Hawaii"
disabled$GESTFIPS[disabled$GESTFIPS == 16]<-"Idaho"
disabled$GESTFIPS[disabled$GESTFIPS == 17]<-"Illinois"
disabled$GESTFIPS[disabled$GESTFIPS == 19]<-"Iowa"
disabled$GESTFIPS[disabled$GESTFIPS == 20]<-"Kansas"
disabled$GESTFIPS[disabled$GESTFIPS == 21]<-"Kentucky"
disabled$GESTFIPS[disabled$GESTFIPS == 22]<-"Louisiana"
disabled$GESTFIPS[disabled$GESTFIPS == 23]<-"Maine"
disabled$GESTFIPS[disabled$GESTFIPS == 24]<-"Maryland"
disabled$GESTFIPS[disabled$GESTFIPS == 25]<-"Massachusetts"
disabled$GESTFIPS[disabled$GESTFIPS == 26]<-"Michigan"
disabled$GESTFIPS[disabled$GESTFIPS == 27]<-"Minnesota"
disabled$GESTFIPS[disabled$GESTFIPS == 28]<-"Mississippi"
disabled$GESTFIPS[disabled$GESTFIPS == 29]<-"Missouri"
disabled$GESTFIPS[disabled$GESTFIPS == 30]<-"Montana"
disabled$GESTFIPS[disabled$GESTFIPS == 31]<-"Nebraska"
disabled$GESTFIPS[disabled$GESTFIPS == 32]<-"Nevada"
disabled$GESTFIPS[disabled$GESTFIPS == 33]<-"New Hampshire"
disabled$GESTFIPS[disabled$GESTFIPS == 34]<-"New Jersey"
disabled$GESTFIPS[disabled$GESTFIPS == 35]<-"New Mexico"
disabled$GESTFIPS[disabled$GESTFIPS == 36]<-"New York"
disabled$GESTFIPS[disabled$GESTFIPS == 37]<-"North Carolina"
disabled$GESTFIPS[disabled$GESTFIPS == 38]<-"North Dakota"
disabled$GESTFIPS[disabled$GESTFIPS == 39]<-"Ohio"
disabled$GESTFIPS[disabled$GESTFIPS == 40]<-"Oklahoma"
disabled$GESTFIPS[disabled$GESTFIPS == 41]<-"Oregon"
disabled$GESTFIPS[disabled$GESTFIPS == 42]<-"Pennsylvania"
disabled$GESTFIPS[disabled$GESTFIPS == 44]<-"Rhode Island"
disabled$GESTFIPS[disabled$GESTFIPS == 45]<-"South Carolina"
disabled$GESTFIPS[disabled$GESTFIPS == 46]<-"South Dakota"
disabled$GESTFIPS[disabled$GESTFIPS == 47]<-"Tennessee"
disabled$GESTFIPS[disabled$GESTFIPS == 48]<-"Texas"
disabled$GESTFIPS[disabled$GESTFIPS == 49]<-"Utah"
disabled$GESTFIPS[disabled$GESTFIPS == 50]<-"Vermont"
disabled$GESTFIPS[disabled$GESTFIPS == 53]<-"Washington"
disabled$GESTFIPS[disabled$GESTFIPS == 54]<-"West Virginia"
disabled$GESTFIPS[disabled$GESTFIPS == 55]<-"Wisconsin"
disabled$GESTFIPS[disabled$GESTFIPS == 56]<-"Wyoming"

disabled<-disabled%>%
  rename(State = GESTFIPS)

final<-left_join(disabled, ada, by = c("State"))
final<-final%>%
  select(-X, -PH_SEQ)%>%
  filter(GTMETSTA != 3) # Filter out unidentified metropolitan/non-metropolitan location

# ~~~~~~~~~~~~~~~~ Dummy Variables ~~~~~~~~~~~~~~~~

#Political Affiliations of the State Governor in 2019
#https://ballotpedia.org/List_of_governors_of_the_American_states
#Republican Dummy
final$Republican_Governor<- ifelse(final$State == "Alabama" | 
                                     final$State == "Alaska" |
                                     final$State == "Arizona" |
                                     final$State == "Arkansas" |
                                     final$State == "Florida" |
                                     final$State == "Georgia" | 
                                     final$State == "Idaho" | 
                                     final$State == "Indiana" | 
                                     final$State == "Iowa" |
                                     final$State == "Maryland" | 
                                     final$State == "Massachusetts" |
                                     final$State == "Mississippi" |
                                     final$State == "Missouri" |
                                     final$State == "Nebraska" |
                                     final$State == "New Hampshire" |
                                     final$State == "North Dakota" |
                                     final$State == "Ohio" | 
                                     final$State == "Oklahoma" |
                                     final$State == "South Carolina"|
                                     final$State == "South Dakota"|
                                     final$State == "Tennessee"|
                                     final$State == "Texas"|
                                     final$State == "Utah"|
                                     final$State == "Vermont"|
                                     final$State == "West Virginia"|
                                     final$State == "Wyoming", 1, 0)

#A_HGA Dummy
#Some College or Higher Dummy
final$Higher_Education <- ifelse(final$A_HGA == '40' | final$A_HGA == '41' |
                                   final$A_HGA == '42' | final$A_HGA == '43' | 
                                   final$A_HGA == '44' | final$A_HGA == '45' | 
                                   final$A_HGA == '46', 1, 0)

#AGE1 Dummy
#Ages 18 to 49 Dummy
final$Age_18_49 <- ifelse(final$AGE1 == '3' | final$AGE1 == '4' |
                            final$AGE1 == '5' | final$AGE1 == '6' | 
                            final$AGE1 == '7' | final$AGE1 == '8' |
                            final$AGE1 == '9' | final$AGE1 == '10', 1, 0)

#A_SEX Dummy
#Gender
final$Male <- ifelse(final$A_SEX == '1', 1, 0)

#PRCITSHP Dummy
#Native Citizen Dummy
final$US_Native <- ifelse(final$PRCITSHP == '1' | final$PRCITSHP == '2' |
                            final$PRCITSHP == '3', 1, 0)

#A_MARITL Dummy
#Married Dummy
final$Married <- ifelse(final$A_MARITL == '1' | final$A_MARITL == '2' |
                          final$A_MARITL == '3', 1, 0)

#PEFNTVTY Dummies
final$Father_us <- ifelse(final$PEFNTVTY == '57', 1, 0)

#PEMNTVTY Dummies
final$Mother_us <- ifelse(final$PEMNTVTY == '57', 1, 0)

#PEPAR1TYP Dummies
final$Parent1_Live_yes <- ifelse(final$PEPAR1TYP == -1, 0, 1)

#PEPAR2TYP Dummies
final$Parent2_Live_yes <- ifelse(final$PEPAR2TYP == -1, 0, 1)

#PEHSPNON Dummies
final$Hispanic_yes <- ifelse(final$PEHSPNON == '1', 1, 0)

#PRDTRACE Dummies
#White/Caucasian Only Dummy
#Baseline: Black, Asian, Native Hawaiian/Pacific Islander
final$Race_white <- ifelse(final$PRDTRACE == '1', 1, 0)

#PEAFEVER Dummies
final$Armed_Forces_yes <- ifelse(final$PEAFEVER == '1', 1, 0)

#MIGSAME Dummy
#Did Not Move In Past Year Dummy
final$Same_Address_yes <- ifelse(final$MIGSAME == '1', 1, 0)

#GTMETSTA Dummy
#Metropolitan Dummy
final$Metropolitan_yes <- ifelse(final$GTMETSTA == '1', 1, 0)

#COV Dummy
final$Health_Coverage_yes <- ifelse(final$COV == '1', 1, 0)

#PRCOW1 Dummy
final$Unemployed <- ifelse(final$PRCOW1 == '0' | final$PRCOW1 == '6', 1, 0)

#Omit variables without dummies
final1<- final%>%
  select(-c(A_HGA, AGE1, A_SEX, PRCITSHP, A_MARITL, 
            PEHSPNON, PRDTRACE, PEAFEVER, 
            PEFNTVTY, PEMNTVTY, PEPAR1TYP, PEPAR2TYP, COV, 
            MIGSAME, PRCOW1, State, GTMETSTA))%>%
  relocate(Unemployed, .after = last_col())

#Throw away individuals who have personal income but unemployed and who have no personal income but employed

#Dummy
final1$Throw<- ifelse(final1$Unemployed == 0 & final1$PEARNVAL == 0, 1, 0)
final1$Throw2<- ifelse(final1$Unemployed == 1 & final1$PEARNVAL>0, 1, 0)

#Final Cleanings
final.var<-final1%>%
  filter(Throw == 0)%>%
  filter(Throw2 == 0)%>%
  select(-Throw)%>%
  select(-Throw2)%>%
  select(-PEARNVAL)%>%
  rename(Children_Under_18 = FOWNU18)

#Write CSV File of Cleaned Data
write_csv(final.var, 'Final_Disability_Data.csv')
