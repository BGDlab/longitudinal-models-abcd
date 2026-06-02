
# %% Import packages
from neuromaps import  nulls, stats
import neuromaps as neuromaps
from nilearn.datasets import fetch_atlas_surf_destrieux
import abagen
import pandas as pd
import nibabel as nib

# %% Define beta df processing function
def process_beta_dataframe(df, df_labels_lh, df_labels_rh, beta_col, hemi_col='hemisphere', label_col='label'):
    """
    Process a DataFrame of beta values by hemisphere and label mapping,
    returning a 1D numpy array of ordered beta values.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame containing at least hemisphere, label, and beta columns.
    labels_lh : dict
        Mapping of left hemisphere labels to keys.
    labels_rh : dict
        Mapping of right hemisphere labels to keys.
    beta_col : str
        Name of the column containing beta values. Default 'bw_beta'.
    hemi_col : str
        Name of the column containing hemisphere info. Default 'hemisphere'.
    label_col : str
        Name of the column containing label info. Default 'label'.

    Returns
    -------
    np.ndarray
        Ordered 1D array of beta values combining left and right hemispheres.
    """
    
    # Split by hemisphere
    df_left = df[df[hemi_col] == 'L'].copy()
    df_right = df[df[hemi_col] == 'R'].copy()
    
    
    # Merge label-Key mapping
    df_left = pd.merge(df_left, df_labels_lh, on=label_col)
    df_right = pd.merge(df_right, df_labels_rh, on=label_col)
    # Sort by Key
    df_left = df_left.sort_values(by='Key')
    df_right = df_right.sort_values(by='Key')
    
    # Combine hemispheres
    df_ordered = pd.concat([df_left, df_right])
    
    # Return 1D vector of beta values
    return df_ordered[beta_col].values

# %%
atlas_files = abagen.fetch_desikan_killiany(surface = True)
atlas_lh = nib.load(atlas_files['image'][0])
atlas_rh = nib.load(atlas_files['image'][1])
labels_lh = atlas_lh.labeltable.get_labels_as_dict()
labels_rh = atlas_rh.labeltable.get_labels_as_dict()
# Convert label dicts into DataFrames
df_labels_lh = pd.DataFrame(list(labels_lh.items()), columns=['Key','label'])
df_labels_rh = pd.DataFrame(list(labels_rh.items()), columns=['Key','label'])

# %% read beta map csvs
#read in the csvs
t1_bw_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_birthweight_all_t1.csv")
t1_ga_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_gestAge_all_t1.csv")
t1_gp_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_gp_all_t1.csv")
t1_psy_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_psy_all_t1.csv")

t2_bw_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_birthweight_all_t2.csv")
t2_ga_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_gestAge_all_t2.csv")
t2_gp_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_gp_all_t2.csv")
t2_psy_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_psy_all_t2.csv")

long_bw_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_birthweight_all_long.csv")
long_ga_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_gestAge_all_long.csv")
long_gp_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_gptwin_all_long.csv")
long_psy_betas = pd.read_csv("/mnt/isilon/bgdlab_processing/Eren/ABCD-braincharts/3.0_results/dkt_betas/dsk_psy_all_long.csv")


# %% process into beta vectors based on atlas
t1_bw_beta_vector = process_beta_dataframe(t1_bw_betas, df_labels_lh, df_labels_rh, 'bw_beta')
t1_ga_beta_vector = process_beta_dataframe(t1_ga_betas, df_labels_lh, df_labels_rh, 'ga_beta')
t1_gp_beta_vector = process_beta_dataframe(t1_gp_betas, df_labels_lh, df_labels_rh, 'gp_beta')
t1_psy_beta_vector = process_beta_dataframe(t1_psy_betas, df_labels_lh, df_labels_rh, 'psy_beta')

t2_bw_beta_vector = process_beta_dataframe(t2_bw_betas, df_labels_lh, df_labels_rh, 'bw_beta')
t2_ga_beta_vector = process_beta_dataframe(t2_ga_betas, df_labels_lh, df_labels_rh, 'ga_beta')
t2_gp_beta_vector = process_beta_dataframe(t2_gp_betas, df_labels_lh, df_labels_rh, 'gp_beta')
t2_psy_beta_vector = process_beta_dataframe(t2_psy_betas, df_labels_lh, df_labels_rh, 'psy_beta')

long_bw_beta_vector = process_beta_dataframe(long_bw_betas, df_labels_lh, df_labels_rh, 'bw_beta')
long_ga_beta_vector = process_beta_dataframe(long_ga_betas, df_labels_lh, df_labels_rh, 'ga_beta')
long_gp_beta_vector = process_beta_dataframe(long_gp_betas, df_labels_lh, df_labels_rh, 'gp_beta')
long_psy_beta_vector = process_beta_dataframe(long_psy_betas, df_labels_lh, df_labels_rh, 'psy_beta')

# %% General null indices
#Generating indices of null spins instead of rotating data, so can apply indices to the map being rotated
nulls_idx = nulls.alexander_bloch(data=None, atlas='fsaverage', density='10k', parcellation=[atlas_lh, atlas_rh], n_perm=10000, seed=1234)

# %% Rotate Maps
rotated_t1_bw = t1_bw_beta_vector[nulls_idx]
rotated_t2_bw = t2_bw_beta_vector[nulls_idx]
rotated_long_bw = long_bw_beta_vector[nulls_idx]

rotated_t1_ga = t1_ga_beta_vector[nulls_idx]
rotated_t2_ga = t2_ga_beta_vector[nulls_idx]
rotated_long_ga = long_ga_beta_vector[nulls_idx]

rotated_t1_gp = t1_gp_beta_vector[nulls_idx]
rotated_t2_gp = t2_gp_beta_vector[nulls_idx]
rotated_long_gp = long_gp_beta_vector[nulls_idx]

rotated_t1_psy = t1_psy_beta_vector[nulls_idx]
rotated_t2_psy = t2_psy_beta_vector[nulls_idx]
rotated_long_psy = long_psy_beta_vector[nulls_idx]

# %% Test between t1
t1_bw_ga_corr, t1_bw_ga_pval = stats.compare_images(t1_bw_beta_vector, t1_ga_beta_vector, nulls=rotated_t1_bw, metric='spearmanr')
print("BW GA T1", t1_bw_ga_corr, t1_bw_ga_pval)

t1_bw_gp_corr, t1_bw_gp_pval = stats.compare_images(t1_bw_beta_vector, t1_gp_beta_vector, nulls=rotated_t1_bw, metric='spearmanr')
print("BW GP T1",t1_bw_gp_corr, t1_bw_gp_pval)

t1_gp_ga_corr, t1_gp_ga_pval = stats.compare_images(t1_gp_beta_vector, t1_ga_beta_vector, nulls=rotated_t1_gp, metric='spearmanr')
print("GA GP T1",t1_gp_ga_corr, t1_gp_ga_pval)

t1_gp_psy_corr, t1_gp_psy_pval = stats.compare_images(t1_gp_beta_vector, t1_psy_beta_vector, nulls=rotated_t1_gp, metric='spearmanr')
print("GP PSY T1",t1_gp_psy_corr, t1_gp_psy_pval)

# %% Test between t2
t2_bw_ga_corr, t2_bw_ga_pval = stats.compare_images(t2_bw_beta_vector, t2_ga_beta_vector, nulls=rotated_t2_bw, metric='spearmanr')
print("BW GA T2",t2_bw_ga_corr, t2_bw_ga_pval)

t2_bw_gp_corr, t2_bw_gp_pval = stats.compare_images(t2_bw_beta_vector, t2_gp_beta_vector, nulls=rotated_t2_bw, metric='spearmanr')
print("BW GP T2",t2_bw_gp_corr, t2_bw_gp_pval)

t2_gp_ga_corr, t2_gp_ga_pval = stats.compare_images(t2_gp_beta_vector, t2_ga_beta_vector, nulls=rotated_t2_gp, metric='spearmanr')
print("GA GP T2",t2_gp_ga_corr, t2_gp_ga_pval)

t2_gp_psy_corr, t2_gp_psy_pval = stats.compare_images(t2_gp_beta_vector, t2_psy_beta_vector, nulls=rotated_t2_gp, metric='spearmanr')
print("GP PSY T2",t2_gp_psy_corr, t2_gp_psy_pval)

# %% Test between long
long_bw_ga_corr, long_bw_ga_pval = stats.compare_images(long_bw_beta_vector, long_ga_beta_vector, nulls=rotated_long_bw, metric='spearmanr')
print("BW GA LONG",long_bw_ga_corr, long_bw_ga_pval)

long_bw_gp_corr, long_bw_gp_pval = stats.compare_images(long_bw_beta_vector, long_gp_beta_vector, nulls=rotated_long_bw, metric='spearmanr')
print("BW GP LONG", long_bw_gp_corr, long_bw_gp_pval)

long_gp_ga_corr, long_gp_ga_pval = stats.compare_images(long_gp_beta_vector, long_ga_beta_vector, nulls=rotated_long_gp, metric='spearmanr')
print("GA GP LONG",long_gp_ga_corr, long_gp_ga_pval)

long_gp_psy_corr, long_gp_psy_pval = stats.compare_images(long_gp_beta_vector, long_psy_beta_vector, nulls=rotated_long_gp, metric='spearmanr')
print("GP PSY LONG",long_gp_psy_corr, long_gp_psy_pval)