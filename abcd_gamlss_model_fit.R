#Load libraries
library(dplyr)
library(magrittr)
library(gamlss) #to fit model
library(mgcv) # helps with the gam models
library(tidygam) # helps with the gam models
library(tidyr)

#Display warnings as they occur, as opposed to at the end.
options(warn = 1)

#read in the arguments passed on from the shell script
args <- commandArgs(trailingOnly = TRUE)

# Is argument length > 1?
if (length(args) > 1) {
  n <- as.numeric(args[1])
  models_folder <- args[2]
  data_filename <- args[3]
  out_folder <- args[4]
  output_file <- args[5]
  model_type <- args[6]
}else{
  n = 1
  models_folder <- "/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/gamlss_models_t1t2"
  data_filename <- "/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/CSV/process_tables_5.1/abcd5.1_t1t2_wide_sTwo_train.csv"
  out_folder <- "/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/gamlss_fits_long_global_TWO/"
  output_file <- "/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/gamlss_fits_long_global_TWO/gamlss_fits_stats"
  model_type <- "t1"
}

#save individual .csv stats file for each model
#the wrapper shell script combines them at the end to avoid over-writing the same .csv file when parallel processes are running.
output_file <- paste0(output_file,"_", n, ".csv")

#read in the dataframe and set variable types, subset for appropriate eventname based on model_type specified
df <- read.csv(data_filename)
if (model_type == "t1"){
  #rename some of the variables
  rename_vec <- c(age = "interview_age", sex = "sex_baseline", site = "site_id_l", nonSingleton = "nonSingleton")
  df <- df %>% select(-1) %>% rename(., all_of(rename_vec)) %>% 
    filter(eventname == "t1")
} else if (model_type == "t2") {
  #rename some of the variables
  rename_vec <- c(age = "interview_age", sex = "sex_baseline", site = "site_id_l", nonSingleton = "nonSingleton")
  df <- df %>% select(-1) %>% rename(., all_of(rename_vec)) %>% 
    filter(eventname == "t2")
} else if (model_type == "long"){
  stopifnot("interscan_months_t1t2" %in% names(df))
  #rename some of the variables
  rename_vec <- c(age = "interview_age.t2", sex = "sex_baseline", site = "site_id_l.t2", nonSingleton = "nonSingleton")
  df <- df %>% select (-1) %>% rename(., all_of(rename_vec))
}
df$sex <- as.factor(df$sex)
df$site <- as.factor(df$site)
df$age <- as.numeric(df$age)

#get list of models and choose the one specified
models_list <-  list.files(models_folder, pattern = "\\.rds$", full.names = TRUE)
print(models_list[n])
model <- readRDS(models_list[n])
print(paste0("family:", model$fam))
print(paste0("mu_formula:",Reduce(paste, deparse(model$mu.formula))))
print(paste0("sigma_formula:",Reduce(paste, deparse(model$sigma.formula))))
print(paste0("nu_formula:",Reduce(paste, deparse(model$nu.formula))))

#select variables for gamlss, including phenotype specified by the loaded model
if (model_type == "long"){
  ph.t1 <- model$phenotype %>% gsub(".t2", ".t1", .)
  df <- df %>% 
    select(sex, age, site, nonSingleton, model$phenotype, interscan_months_t1t2, ph.t1) %>% 
    drop_na()
  df[,model$phenotype] <- as.numeric(df[,model$phenotype])
  df[,ph.t1] <- as.numeric(df[,ph.t1])
} else {
  df <- df %>% 
    select(sex, age, site, nonSingleton, model$phenotype) %>% 
    drop_na()
}

  modelname <- (paste("gamlssFIT", n, sep = "_"))

gamlss <- gamlss (formula = model$mu.formula,
                  sigma.formula = model$sigma.formula,
                  nu.formula = model$nu.formula,
                  family = model$fam,
                  method = RS(),
                  data = df,
                  control = gamlss.control(n.cyc = eval(model$n_crit)))

output <- data.frame(mu_formula = Reduce(paste, deparse(model$mu.formula)),
                     sigma_formula = Reduce(paste, deparse(model$sigma.formula)),
                     nu_formula = Reduce(paste, deparse(model$nu.formula)),
                     family_abbr = gamlss$family[1],
                     family = gamlss$family[2],
                     method = as.character(gamlss$method),
                     logLik = logLik(gamlss), 
                     AIC = AIC(gamlss), 
                     BIC = BIC(gamlss),
                     n_cyc = model$n_crit,
                     data = basename(data_filename),
                     warning = NA)

#Create new table for each model, will be combined in wrapper shell script when array is done.
write.table(output, file = output_file, sep = ",", row.names = FALSE, col.names = TRUE, append = FALSE)
print(paste0("Creating new stats table: ", output_file))

#Old code -- when for writing into the same .csv file, not good when running parallel processes.
# if (!file.exists(output_file)) {
#   write.table(output, file = output_file, sep = ",", row.names = FALSE, col.names = TRUE, append = FALSE)
#   print(paste0("Creating new stats table: ", output_file))
# } else {
#   write.table(output, file = output_file, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
#   print("New line in fits stats table.")
# }
#   

filename <- paste0(out_folder,modelname,".rds")
#Saving the model only
print(filename)
saveRDS(gamlss, file = filename)
