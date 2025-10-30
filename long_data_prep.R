##This script formats abcd split-half dataframes to fit the longitudinal models, which model timepoint 2 (t2)
##measures, conditioned on timepoint 1 (t1) measures.

#Load libraries
library(dplyr)
library(magrittr)
library(ggplot2)
library(tidyr)
setwd("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/")
source("ABCD_premie_code/data_functions.R")
out_folder <- "/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/CSV/process_tables_5.1_2.0/update/"

#Read in wide-format abcd data saved in abcd_5.1_cleanup
abcd_wide <- read.csv(paste0(out_folder, "abcd5.1_wide_imaging_2.02025-09-26.csv")) %>%
  select(-1)

#Read in IDs for split halves test/train
splitOne_train_IDs <- read.csv(paste0(out_folder,"splitOne_train_IDs_2.02025-09-26.csv")) %>% select(-1)
splitOne_test_IDs <- read.csv(paste0(out_folder,"splitOne_test_IDs_2.02025-09-26.csv")) %>% select(-1)
splitTwo_train_IDs <- read.csv(paste0(out_folder,"splitTwo_train_IDs_2.02025-09-26.csv")) %>% select(-1)
splitTwo_test_IDs <- read.csv(paste0(out_folder,"splitTwo_test_IDs_2.02025-09-26.csv")) %>% select(-1)

#Define variable for months between timepoint 1 and timepoint 2 (covariate to be tested in the models)
abcd_wide$interscan_months_t1t2 <- abcd_wide$interview_age.t2 - abcd_wide$interview_age.t1 
sum(is.na(abcd_wide$interscan_months_t1t2))#3702 NA
sum(is.na(abcd_wide$interview_age.t2))#3702 NA
sum(abcd_wide$site_id_l.t1 != abcd_wide$site_id_l.t2, na.rm = TRUE)#74

#Remove measures from timepoint 3
#Remove subjects without interview age recorded at timepoint 2 (do not have timepoint 2 measures)
#Remove subjects where site is different between timepoint 1 and timepoint 2 (longitudinal models use random effect for site)
abcd_wide <- abcd_wide %>% select(-names(abcd_wide)[grep(".t3", names(abcd_wide))]) %>% 
  filter(!is.na(interview_age.t2)) %>%
  filter(site_id_l.t1 == site_id_l.t2)

#Select based on split-half IDs
abcd_wide_Onetrain <- abcd_wide %>% filter(src_subject_id %in% splitOne_train_IDs$x)
abcd_wide_Twotrain <- abcd_wide %>% filter(src_subject_id %in% splitTwo_train_IDs$x)

abcd_wide_Onetest <- abcd_wide %>% filter(src_subject_id %in% splitOne_test_IDs$x)
abcd_wide_Twotest <- abcd_wide %>% filter(src_subject_id %in% splitTwo_test_IDs$x)


#Save datatables for model fitting and downstream analyses
write.csv(abcd_wide_Onetrain, file = paste0(out_folder,
                                            "abcd_wide_Onetrain", 
                                            Sys.Date(),".csv"))
write.csv(abcd_wide_Twotrain, file = paste0(out_folder,
                                            "abcd_wide_Twotrain", 
                                            Sys.Date(),".csv"))

write.csv(abcd_wide_Onetest, file = paste0(out_folder,
                                            "abcd_wide_Onetest", 
                                            Sys.Date(),".csv"))
write.csv(abcd_wide_Twotest, file = paste0(out_folder,
                                            "abcd_wide_Twotest", 
                                            Sys.Date(),".csv"))