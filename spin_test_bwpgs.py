from neuromaps import  nulls, stats
import neuromaps as neuromaps
from nilearn.datasets import fetch_atlas_surf_destrieux
import abagen
import pandas as pd
import nibabel as nib

atlas_files = abagen.fetch_desikan_killiany(surface = True)
atlas_lh = nib.load(atlas_files['image'][0])
atlas_rh = nib.load(atlas_files['image'][1])
labels_lh = atlas_lh.labeltable.get_labels_as_dict()
labels_rh = atlas_rh.labeltable.get_labels_as_dict()

#timepoint 1
#read in the betas
t1_bw_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/2.0_results/dkt_betas/dsk_birthweight_all_t1.csv")
t1_pgs_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/2.0_results/dkt_betas/dsk_birthweightt1_pgs_all_t1.csv")


#Split by hemisphere, which also removes non-cortical. Should be 34 for each hemisphere
t1_bw_left = t1_bw_betas[t1_bw_betas['hemisphere'] == 'L'].copy()
t1_bw_right = t1_bw_betas[t1_bw_betas['hemisphere'] == 'R'].copy()
t1_pgs_left = t1_pgs_betas[t1_pgs_betas['hemisphere'] == 'L'].copy()
t1_pgs_right = t1_pgs_betas[t1_pgs_betas['hemisphere'] == 'R'].copy()

# Convert label dicts into DataFrames
df_labels_lh = pd.DataFrame(list(labels_lh.items()), columns=['Key', 'label'])
df_labels_rh = pd.DataFrame(list(labels_rh.items()), columns=['Key', 'label'])

# Merge label-Key mapping with betas
t1_bw_left = pd.merge(t1_bw_left, df_labels_lh, on='label')
t1_bw_right = pd.merge(t1_bw_right, df_labels_rh, on='label')
t1_pgs_left = pd.merge(t1_pgs_left, df_labels_lh, on='label')
t1_pgs_right = pd.merge(t1_pgs_right, df_labels_rh, on='label')

# Sort by Key
t1_bw_left = t1_bw_left.sort_values(by='Key')
t1_bw_right = t1_bw_right.sort_values(by='Key')
t1_pgs_left = t1_pgs_left.sort_values(by='Key')
t1_pgs_right = t1_pgs_right.sort_values(by='Key')

# Combine hemispheres
t1_bw_betas_ordered = pd.concat([t1_bw_left, t1_bw_right])
t1_pgs_betas_ordered = pd.concat([t1_pgs_left, t1_pgs_right])

# Get 1D vectors of beta values
t1_bw_beta_vector = t1_bw_betas_ordered['t1_bw_beta'].values
t1_pgs_beta_vector = t1_pgs_betas_ordered['t1_bw_t1_pgs_beta'].values


#Generating indices of null spins instead of rotating data, so can apply indices to the map being rotated
nulls_idx = nulls.alexander_bloch(data=None, atlas='fsaverage', density='10k', parcellation=[atlas_lh, atlas_rh], n_perm=10000, seed=1234)

#Using the indices to rotate the maps
rotated_t1_bw = t1_bw_beta_vector[nulls_idx]

#Test t1_bw-t1_bwt1_pgs
t1_bw_t1_bwt1_pgs_corr, t1_bw_t1_bwt1_pgs_pval = stats.compare_images(t1_bw_beta_vector, t1_pgs_beta_vector, nulls=rotated_t1_bw, metric='spearmanr')


#timepoint 2
#read in the betas
t2_bw_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/2.0_results/dkt_betas/dsk_birthweight_all_t2.csv")
t2_pgs_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/2.0_results/dkt_betas/dsk_birthweightt2_pgs_all_t2.csv")


#Split by hemisphere, which also removes non-cortical. Should be 34 for each hemisphere
t2_bw_left = t2_bw_betas[t2_bw_betas['hemisphere'] == 'L'].copy()
t2_bw_right = t2_bw_betas[t2_bw_betas['hemisphere'] == 'R'].copy()
t2_pgs_left = t2_pgs_betas[t2_pgs_betas['hemisphere'] == 'L'].copy()
t2_pgs_right = t2_pgs_betas[t2_pgs_betas['hemisphere'] == 'R'].copy()

# Convert label dicts into DataFrames
df_labels_lh = pd.DataFrame(list(labels_lh.items()), columns=['Key', 'label'])
df_labels_rh = pd.DataFrame(list(labels_rh.items()), columns=['Key', 'label'])

# Merge label-Key mapping with betas
t2_bw_left = pd.merge(t2_bw_left, df_labels_lh, on='label')
t2_bw_right = pd.merge(t2_bw_right, df_labels_rh, on='label')
t2_pgs_left = pd.merge(t2_pgs_left, df_labels_lh, on='label')
t2_pgs_right = pd.merge(t2_pgs_right, df_labels_rh, on='label')

# Sort by Key
t2_bw_left = t2_bw_left.sort_values(by='Key')
t2_bw_right = t2_bw_right.sort_values(by='Key')
t2_pgs_left = t2_pgs_left.sort_values(by='Key')
t2_pgs_right = t2_pgs_right.sort_values(by='Key')

# Combine hemispheres
t2_bw_betas_ordered = pd.concat([t2_bw_left, t2_bw_right])
t2_pgs_betas_ordered = pd.concat([t2_pgs_left, t2_pgs_right])

# Get 1D vectors of beta values
t2_bw_beta_vector = t2_bw_betas_ordered['t2_bw_beta'].values
t2_pgs_beta_vector = t2_pgs_betas_ordered['t2_bw_t2_pgs_beta'].values


#Generating indices of null spins instead of rotating data, so can apply indices to the map being rotated
nulls_idx = nulls.alexander_bloch(data=None, atlas='fsaverage', density='10k', parcellation=[atlas_lh, atlas_rh], n_perm=10000, seed=1234)

#Using the indices to rotate the maps
rotated_t2_bw = t2_bw_beta_vector[nulls_idx]

#Test t2_bw-t2_bwt2_pgs
t2_bw_t2_bwt2_pgs_corr, t2_bw_t2_bwt2_pgs_pval = stats.compare_images(t2_bw_beta_vector, t2_pgs_beta_vector, nulls=rotated_t2_bw, metric='spearmanr')

