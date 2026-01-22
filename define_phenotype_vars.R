setwd("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/CSV/")
#define variable vectors
abcd <- read.csv("process_tables_5.1_2.0/update/abcd_long_Onetrain2025-09-26.csv")
vol_vars <- names(abcd)[grepl("vol", names(abcd))]
sa_vars <- names(abcd)[grepl("area", names(abcd))]
th_vars <- names(abcd)[grepl("thick", names(abcd))]

write.csv(vol_vars, "vol_vars.csv")
write.csv(sa_vars, "sa_vars.csv")
write.csv(th_vars, "th_vars.csv")

#df to map variable names onto names displayed on figures
name_mapping <- data.frame(
  abbreviation = c(
    "smri_vol_cdk_totallh", "smri_vol_cdk_totalrh", "smri_vol_cdk_total",   
    "totalWM_cb", "totalWM_crb", "totalGM_crb",
    
    "smri_vol_scs_cbwmatterlh", "smri_vol_scs_ltventriclelh", "smri_vol_scs_inflatventlh",
    "smri_vol_scs_crbwmatterlh", "smri_vol_scs_crbcortexlh", "smri_vol_scs_tplh",
    "smri_vol_scs_caudatelh", "smri_vol_scs_putamenlh", "smri_vol_scs_pallidumlh",
    "smri_vol_scs_3rdventricle", "smri_vol_scs_4thventricle", "smri_vol_scs_bstem",
    "smri_vol_scs_hpuslh", "smri_vol_scs_amygdalalh", "smri_vol_scs_csf",
    "smri_vol_scs_lesionlh", "smri_vol_scs_aal", "smri_vol_scs_vedclh",
    
    "smri_vol_scs_cbwmatterrh", "smri_vol_scs_ltventriclerh", "smri_vol_scs_inflatventrh",
    "smri_vol_scs_crbwmatterrh", "smri_vol_scs_crbcortexrh", "smri_vol_scs_tprh",
    "smri_vol_scs_caudaterh", "smri_vol_scs_putamenrh", "smri_vol_scs_pallidumrh",
    "smri_vol_scs_hpusrh", "smri_vol_scs_amygdalarh", "smri_vol_scs_lesionrh",
    "smri_vol_scs_aar", "smri_vol_scs_vedcrh", 
    
    "smri_vol_scs_wmhint",
    "smri_vol_scs_wmhintlh", "smri_vol_scs_wmhintrh", 
    
    "smri_vol_scs_ccps",
    "smri_vol_scs_ccmidps", "smri_vol_scs_ccct", "smri_vol_scs_ccmidat",
    "smri_vol_scs_ccat", 
    
    "smri_vol_scs_wholeb", "smri_vol_scs_latventricles",
    "smri_vol_scs_allventricles", "smri_vol_scs_intracranialv", "smri_vol_scs_suprateialv",
    "smri_vol_scs_subcorticalgv",
    
    "smri_vol_cdk_banksstslh", "smri_vol_cdk_cdacatelh", "smri_vol_cdk_cdmdfrlh",
    "smri_vol_cdk_cuneuslh", "smri_vol_cdk_ehinallh", "smri_vol_cdk_fusiformlh",
    "smri_vol_cdk_ifpllh", "smri_vol_cdk_iftmlh", "smri_vol_cdk_ihcatelh",
    "smri_vol_cdk_locclh", "smri_vol_cdk_lobfrlh", "smri_vol_cdk_linguallh",
    "smri_vol_cdk_mobfrlh", "smri_vol_cdk_mdtmlh", "smri_vol_cdk_parahpallh",
    "smri_vol_cdk_paracnlh", "smri_vol_cdk_parsopclh", "smri_vol_cdk_parsobislh",
    "smri_vol_cdk_parstgrislh", "smri_vol_cdk_pericclh", "smri_vol_cdk_postcnlh",
    "smri_vol_cdk_ptcatelh", "smri_vol_cdk_precnlh", "smri_vol_cdk_pclh",
    "smri_vol_cdk_rracatelh", "smri_vol_cdk_rrmdfrlh", "smri_vol_cdk_sufrlh",
    "smri_vol_cdk_supllh", "smri_vol_cdk_sutmlh", "smri_vol_cdk_smlh",
    "smri_vol_cdk_frpolelh", "smri_vol_cdk_tmpolelh", "smri_vol_cdk_trvtmlh",
    "smri_vol_cdk_insulalh",
    
    "smri_vol_cdk_banksstsrh", "smri_vol_cdk_cdacaterh", "smri_vol_cdk_cdmdfrrh",
    "smri_vol_cdk_cuneusrh", "smri_vol_cdk_ehinalrh", "smri_vol_cdk_fusiformrh",
    "smri_vol_cdk_ifplrh", "smri_vol_cdk_iftmrh", "smri_vol_cdk_ihcaterh",
    "smri_vol_cdk_loccrh", "smri_vol_cdk_lobfrrh", "smri_vol_cdk_lingualrh",
    "smri_vol_cdk_mobfrrh", "smri_vol_cdk_mdtmrh", "smri_vol_cdk_parahpalrh",
    "smri_vol_cdk_paracnrh", "smri_vol_cdk_parsopcrh", "smri_vol_cdk_parsobisrh",
    "smri_vol_cdk_parstgrisrh", "smri_vol_cdk_periccrh", "smri_vol_cdk_postcnrh",
    "smri_vol_cdk_ptcaterh", "smri_vol_cdk_precnrh", "smri_vol_cdk_pcrh",
    "smri_vol_cdk_rracaterh", "smri_vol_cdk_rrmdfrrh", "smri_vol_cdk_sufrrh",
    "smri_vol_cdk_suplrh", "smri_vol_cdk_sutmrh", "smri_vol_cdk_smrh",
    "smri_vol_cdk_frpolerh", "smri_vol_cdk_tmpolerh", "smri_vol_cdk_trvtmrh",
    "smri_vol_cdk_insularh"
  ),
  region_name = c(
    "Left-Cerebral_Cortex", "Right-Cerebral-Cortex", "Total-Cerebral-Cortex",
    "Total_Cerebral-WM", "Total_Cerebellum-WM", "Total-Cerebellum-Cortex",
    
    "Left-Cerebral-White-Matter", "Left-Lateral-Ventricle", "Left-Inf-Lat-Vent",
    "Left-Cerebellum-White-Matter", "Left-Cerebellum-Cortex", "Left-Thalamus-Proper",
    "Left-Caudate", "Left-Putamen", "Left-Pallidum",
    "x3rd-ventricle", "x4th-ventricle", "Brain-Stem",
    "Left-Hippocampus", "Left-Amygdala", "Cerebrospinal-Fluid",
    "Left-Lesion", "Left-Accumbens-Area", "Left-VentralDC",
    
    "Right-Cerebral-White-Matter", "Right-Lateral-Ventricle", "Right-Inf-Lat-Vent",
    "Right-Cerebellum-White-Matter", "Right-Cerebellum-Cortex", "Right-Thalamus-Proper",
    "Right-Caudate", "Right-Putamen", "Right-Pallidum",
    "Right-Hippocampus", "Right-Amygdala",
    "Right-Lesion", "Right-Accumbens-Area", "Right-VentralDC",
    
    "WM-Hypointensities","Left-WM-Hypointensities", "Right-WM-Hypointensities",
    
    "CC_Posterior","CC_Mid_Posterior", "CC_Central", "CC_Mid_Anterior",
    "CC_Anterior", 
    
    "WholeBrain", "LatVentricles","AllVentricles", "IntracranialVolume", 
    "SupratentorialVolume", "SubcorticalGrayVolume",
    
    "lh_bankssts", "lh_caudalanteriorcingulate", "lh_caudalmiddlefrontal",
    "lh_cuneus", "lh_entorhinal", "lh_fusiform",
    "lh_inferiorparietal", "lh_inferiortemporal", "lh_isthmuscingulate",
    "lh_lateraloccipital", "lh_lateralorbitofrontal", "lh_lingual",
    "lh_medialorbitofrontal", "lh_middletemporal", "lh_parahippocampal",
    "lh_paracentral", "lh_parsopercularis", "lh_parsorbitalis",
    "lh_parstriangularis", "lh_pericalcarine", "lh_postcentral",
    "lh_posteriorcingulate", "lh_precentral", "lh_precuneus", "lh_rostralanteriorcingulate",
    "lh_rostralmiddlefrontal", "lh_superiorfrontal", "lh_superiorparietal",
    "lh_superiortemporal", "lh_supramarginal", "lh_frontalpole",
    "lh_temporalpole", "lh_transversetemporal", "lh_insula",
    
    "rh_bankssts", "rh_caudalanteriorcingulate", "rh_caudalmiddlefrontal",
    "rh_cuneus", "rh_entorhinal", "rh_fusiform",
    "rh_inferiorparietal", "rh_inferiortemporal", "rh_isthmuscingulate",
    "rh_lateraloccipital", "rh_lateralorbitofrontal", "rh_lingual",
    "rh_medialorbitofrontal", "rh_middletemporal", "rh_parahippocampal",
    "rh_paracentral", "rh_parsopercularis", "rh_parsorbitalis",
    "rh_parstriangularis", "rh_pericalcarine", "rh_postcentral",
    "rh_posteriorcingulate", "rh_precentral", "rh_precuneus", "rh_rostralanteriorcingulate",
    "rh_rostralmiddlefrontal", "rh_superiorfrontal", "rh_superiorparietal",
    "rh_superiortemporal", "rh_supramarginal", "rh_frontalpole",
    "rh_temporalpole", "rh_transversetemporal", "rh_insula"
  )
)

phenotypes_for_MC <- c(
  "smri_vol_scs_ltventriclelh", "smri_vol_scs_inflatventlh",
  "smri_vol_scs_crbwmatterlh", "smri_vol_scs_crbcortexlh", "smri_vol_scs_tplh",
  "smri_vol_scs_caudatelh", "smri_vol_scs_putamenlh", "smri_vol_scs_pallidumlh",
  "smri_vol_scs_3rdventricle", "smri_vol_scs_4thventricle", "smri_vol_scs_bstem",
  "smri_vol_scs_hpuslh", "smri_vol_scs_amygdalalh", "smri_vol_scs_aal", "smri_vol_scs_vedclh",
  
  "smri_vol_scs_ltventriclerh", "smri_vol_scs_inflatventrh",
  "smri_vol_scs_crbwmatterrh", "smri_vol_scs_crbcortexrh", "smri_vol_scs_tprh",
  "smri_vol_scs_caudaterh", "smri_vol_scs_putamenrh", "smri_vol_scs_pallidumrh",
  "smri_vol_scs_hpusrh", "smri_vol_scs_amygdalarh",
  "smri_vol_scs_aar", "smri_vol_scs_vedcrh", 
  
  "smri_vol_scs_ccps",
  "smri_vol_scs_ccmidps", "smri_vol_scs_ccct", "smri_vol_scs_ccmidat",
  "smri_vol_scs_ccat",
  
  "smri_vol_cdk_banksstslh", "smri_vol_cdk_cdacatelh", "smri_vol_cdk_cdmdfrlh",
  "smri_vol_cdk_cuneuslh", "smri_vol_cdk_ehinallh", "smri_vol_cdk_fusiformlh",
  "smri_vol_cdk_ifpllh", "smri_vol_cdk_iftmlh", "smri_vol_cdk_ihcatelh",
  "smri_vol_cdk_locclh", "smri_vol_cdk_lobfrlh", "smri_vol_cdk_linguallh",
  "smri_vol_cdk_mobfrlh", "smri_vol_cdk_mdtmlh", "smri_vol_cdk_parahpallh",
  "smri_vol_cdk_paracnlh", "smri_vol_cdk_parsopclh", "smri_vol_cdk_parsobislh",
  "smri_vol_cdk_parstgrislh", "smri_vol_cdk_pericclh", "smri_vol_cdk_postcnlh",
  "smri_vol_cdk_ptcatelh", "smri_vol_cdk_precnlh", "smri_vol_cdk_pclh",
  "smri_vol_cdk_rracatelh", "smri_vol_cdk_rrmdfrlh", "smri_vol_cdk_sufrlh",
  "smri_vol_cdk_supllh", "smri_vol_cdk_sutmlh", "smri_vol_cdk_smlh",
  "smri_vol_cdk_frpolelh", "smri_vol_cdk_tmpolelh", "smri_vol_cdk_trvtmlh",
  "smri_vol_cdk_insulalh",
  
  "smri_vol_cdk_banksstsrh", "smri_vol_cdk_cdacaterh", "smri_vol_cdk_cdmdfrrh",
  "smri_vol_cdk_cuneusrh", "smri_vol_cdk_ehinalrh", "smri_vol_cdk_fusiformrh",
  "smri_vol_cdk_ifplrh", "smri_vol_cdk_iftmrh", "smri_vol_cdk_ihcaterh",
  "smri_vol_cdk_loccrh", "smri_vol_cdk_lobfrrh", "smri_vol_cdk_lingualrh",
  "smri_vol_cdk_mobfrrh", "smri_vol_cdk_mdtmrh", "smri_vol_cdk_parahpalrh",
  "smri_vol_cdk_paracnrh", "smri_vol_cdk_parsopcrh", "smri_vol_cdk_parsobisrh",
  "smri_vol_cdk_parstgrisrh", "smri_vol_cdk_periccrh", "smri_vol_cdk_postcnrh",
  "smri_vol_cdk_ptcaterh", "smri_vol_cdk_precnrh", "smri_vol_cdk_pcrh",
  "smri_vol_cdk_rracaterh", "smri_vol_cdk_rrmdfrrh", "smri_vol_cdk_sufrrh",
  "smri_vol_cdk_suplrh", "smri_vol_cdk_sutmrh", "smri_vol_cdk_smrh",
  "smri_vol_cdk_frpolerh", "smri_vol_cdk_tmpolerh", "smri_vol_cdk_trvtmrh",
  "smri_vol_cdk_insularh"
)

global_phenotypes <- c("smri_vol_cdk_total", "totalWM_cb", "smri_vol_scs_allventricles", "smri_vol_scs_subcorticalgv")

all_global_phenotypes <- c("smri_vol_cdk_total", "totalWM_cb", "smri_vol_scs_allventricles", "smri_vol_scs_subcorticalgv", "smri_vol_cdk_totallh", "smri_vol_cdk_totalrh", "totalWM_crb", "totalGM_crb", "smri_vol_scs_cbwmatterlh", "smri_vol_scs_crbwmatterlh", "smri_vol_scs_crbcortexlh","smri_vol_scs_cbwmatterrh", "smri_vol_scs_crbwmatterrh","smri_vol_scs_crbcortexrh", "smri_vol_scs_wholeb", "smri_vol_scs_latventricles", "smri_vol_scs_intracranialv", "smri_vol_scs_suprateialv")

phenotypes_to_fit <- c(phenotypes_for_MC, global_phenotypes, "smri_vol_scs_wholeb", "smri_vol_scs_intracranialv", "totalWM_crb", "totalGM_crb", "smri_vol_scs_csf", "smri_vol_cdk_totallh", "smri_vol_cdk_totalrh", "smri_vol_scs_cbwmatterlh", "smri_vol_scs_cbwmatterrh")