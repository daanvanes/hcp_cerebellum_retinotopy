# Cerebellar Retinotopic Maps

## Resource files

In the *resource* dir of this repo, you'll find a couple of heplful files. 

### First, the resource/volume_masks contains:

1. Cerebellum retinotopy atlas files

The cerebellum retinotopic maps file can be found in the resources/volume_masks folder and is named 'cerebellum_retmaps.nii'. This file is in the 2mm MNI format. The indices to each map can be found in the 'cerebellum_retmaps.csv' file.

2. Spillovermask

This mask was used to select voxels that are on the border between the cerebral and cerebellar cortex. This was used to exlude 'smoothed in' voxels that actually belong to ventral visual cortex.

### Second, the resource/mscripts folder contains custom matlab functions:

    * circ_mean_adapted.m: this is adapted from the circstats toolbox to suit with the SUIT toolbox 
    * interpolate_cvals_rgbspace.m: to help in creating custom colorbar 

## Notebooks

The repo contains four IPython notebooks with the following functions:

1. Downloading the HCP data
2. creating masked niftis
3. creating visual field plots
4. creating surface projected plots (note that the surface visualizations in matlab need to created (see below) for this to work first)

The surface visualizations are made in Matlab ('create_cerflatmaps.m', using the SPM12 SUIT toolbox . This can be done after the second IPython notebook has finished. This requires the following modules in your path:

1. SPM + SUIT toolbox installed (http://www.diedrichsenlab.org/imaging/suit.htm)
2. colorcet.m (https://www.peterkovesi.com/matlabfns/Colourmaps/colorcet.m), 
3. and two custom functions (found in resources/mscript folder of this repo)


