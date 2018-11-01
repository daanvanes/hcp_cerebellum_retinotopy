# hcp_cerebellum retmaps

This repo makes use of the cerebellar data in the 'HCP 7T Retinotopy' dataset. This dataset can be downloaded from https://osf.io/83wkp/.

The repo contains four IPython notebooks with the following functions:

1. Downloading the HCP data
2. creating masked niftis
3. creating visual field plots
4. creating surface projected plots

The surface visualizations themselves are made in Matlab ('create_cerflatmaps.m', using the SPM12 SUIT toolbox . This can be done after the second IPython notebook has finished. This requires the following modules in your path:

1. SPM + SUIT toolbox installed (http://www.diedrichsenlab.org/imaging/suit.htm)
2. colorcet.m (https://www.peterkovesi.com/matlabfns/Colourmaps/colorcet.m), 
3. and two custom functions (found in resources/mscript folder of this repo):
    a. circ_mean_adapted: this is adapted from the circstats toolbox to suit with the SUIT toolbox 
    b. interpolate_cvals_rgbspace.m: to hep in creating custom colorbar 

