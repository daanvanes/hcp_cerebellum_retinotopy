import nibabel as nb
import os
import numpy as np
import matplotlib.pyplot as pl
import seaborn as sn
sn.set_style('ticks')

prf_fn = '/Users/daanvanes/Downloads/prfresults__183.dscalar_data_sub.nii'
atlas_fn = '/Applications/fsl/data/atlases/Cerebellum/Cerebellum-MNIfnirt-maxprob-thr25-2mm.nii.gz'
plot_dir = '/Users/daanvanes/Downloads/'
atlas_img = nb.load(atlas_fn).get_data()
prf_img = nb.load(prf_fn).get_data()


for dim in range(8):
	print '%d min: %.3f'%(dim,np.nanmin(prf_img[:,:,:,dim]))
	print '%d max: %.3f'%(dim,np.nanmax(prf_img[:,:,:,dim]))

# known dimensions:
x_dim = 1 		
y_dim = 0 		
pol_dim = 2 
ecc_dim = 3
unkown = 4 	# guess
n_dim=4       	# guess
amp_dim=5 	 	# guess
r2_dim = 6
size_dim=7# guess

# save new version, but masked
mask = (prf_img[:,:,:,r2_dim]<.1)
# mask *= np.isnan(prf_img[:,:,:,pol_dim])
mask += (prf_img[:,:,:,ecc_dim] < .5)
# mask += (prf_img[:,:,:,ecc_dim] > 8)		
new_data = copy.copy(prf_img)
new_data[mask] = np.nan
new_img = nb.Nifti1Image(new_data,affine=nb.load(prf_fn).affine,header=nb.load(prf_fn).header)
nb.save(new_img,'/Users/daanvanes/Downloads/prfresults__183.dscalar_data_sub_masked.nii')

mask_dir = '/Users/daanvanes/Downloads/'

rois = ['left_central','right_central','left_ventral','right_ventral']

for measure in ['pol','ecc','size','x','y']:
	f = pl.figure()
	for ri, roi in enumerate(rois):
		s = f.add_subplot(2,2,ri+1)
		pl.title(roi)
		mask = nb.load(os.path.join(mask_dir,roi+'.nii.gz')).get_data().astype(bool)
		dim = eval(measure+'_dim')
		sn.distplot(prf_img[mask,dim],bins=25)
		sn.despine(offset=2)
		if measure == 'pol':
			pl.xlim(0,360)
			pl.xticks(np.arange(0,361,90),['right','up','left','down','right'])
		pl.xlabel(measure)
	pl.tight_layout()
	pl.savefig(os.path.join(plot_dir,'%s_hist_masks.pdf'%measure))


f = pl.figure()
for ri, roi in enumerate(rois):
	s = f.add_subplot(2,2,ri+1)
	pl.title(roi)
	mask = nb.load(os.path.join(mask_dir,roi+'.nii.gz')).get_data().astype(bool)
	sn.regplot(prf_img[mask,ecc_dim],prf_img[mask,size_dim])
	pl.xlim(0,8)
	sn.despine(offset=2)
pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'ecc_size_allmasks.pdf'))


f = pl.figure()
for ri, roi in enumerate(rois):
	s = f.add_subplot(2,2,ri+1,aspect='equal')
	pl.axhline(0,color='k')
	pl.axvline(0,color='k')
	pl.title(roi)
	mask = nb.load(os.path.join(mask_dir,roi+'.nii.gz')).get_data().astype(bool)
	x = prf_img[mask,ecc_dim] * np.cos(np.radians(prf_img[mask,pol_dim]))
	y = prf_img[mask,ecc_dim] * np.sin(np.radians(prf_img[mask,pol_dim]))
	pl.plot(x,y,'o',ms=2)
	pl.xlim(-8,8)
	pl.ylim(-8,8)
	sn.despine(offset=2)
pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'coverage.pdf'))

left_hemisphere_regions = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]

rois = {
1: 'Left I-IV',
2:'Right I-IV',
3:'Left V',
4:'Right V',
5:'Left VI',
6:'Vermis VI',
7:'Right VI',
8:'Left Crus I',
9:'Vermis Crus I',
10:'Right Crus I',
11:'Left Crus II',
12:'Vermis Crus II',
13:'Right Crus II',
14:'Left VIIb',
15:'Vermis VIIb',
16:'Right VIIb',
17:'Left VIIIa',x
18:'Vermis VIIIa',
19:'Right VIIIa',
20:'Left VIIIb',x
21:'Vermis VIIIb',
22:'Right VIIIb',
23:'Left IX',x
24:'Vermis IX',
25:'Right IX',
26:'Left X',
27:'Vermis X',
28:'Right X',
}

roi_combs = {
'left_cerebellar_cortex':[1,3,5,8,11,14,17,20,23,26],
'right_cerebellar_cortex':[2,4,7,10,13,16,19,22,25,28],
# 'vermis':[6,9,12,15,18,21,24,27]
}



f = pl.figure(figsize=(4,4))
mask = (prf_img[:,:,:,r2_dim] > .05)
mask *= (prf_img[:,:,:,ecc_dim] > .1)
mask *= np.invert(np.isnan(prf_img[:,:,:,pol_dim]))
sn.distplot(prf_img[mask,pol_dim],bins=25)
pl.xlim(0,360)
sn.despine(offset=2)
pl.xticks(np.arange(0,361,90),['right','up','left','down','right'])
pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'polhistall.pdf'))

f = pl.figure(figsize=(10,10))
for ri in rois.keys():

	s = f.add_subplot(6,5,ri)
	pl.title(rois[ri])
	mask = (atlas_img==ri)
	mask *= (prf_img[:,:,:,r2_dim] > .1)
	mask *= (prf_img[:,:,:,ecc_dim] > .25)
	mask *= np.invert(np.isnan(prf_img[:,:,:,pol_dim]))
	try:
		pl.hist(prf_img[mask,pol_dim],bins=20)
		pl.xlim(0,360)
		sn.despine(offset=2)
		pl.xticks(np.arange(0,361,90),['right','up','left','down','right'])
	except:
		pass

pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'polhist.pdf'))


f = pl.figure(figsize=(6,6));k=0
for ri in roi_combs.keys():

	k+=1
	# s = f.add_subplot(1,3,k)
	# pl.title(ri)
	mask = np.zeros_like(prf_img[:,:,:,0]).astype(bool)
	for subroi in roi_combs[ri]:
		mask += (atlas_img==subroi)
	mask *= (prf_img[:,:,:,r2_dim] > .1)
	mask *= np.invert(np.isnan(prf_img[:,:,:,pol_dim]))
	mask *= (prf_img[:,:,:,ecc_dim] > .5)
	mask *= (prf_img[:,:,:,ecc_dim] < 8)		
	pl.hist(prf_img[mask,pol_dim],bins=20,alpha=0.5,label=ri)
	pl.legend()
	pl.xlim(0,360)
	sn.despine(offset=2)
	pl.xticks(np.arange(0,361,90))

pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'polhist_groups.pdf'))


f = pl.figure(figsize=(6,6));k=0
for ri in roi_combs.keys():

	k+=1
	# s = f.add_subplot(1,3,k)
	# pl.title(ri)
	mask = np.zeros_like(prf_img[:,:,:,0]).astype(bool)
	for subroi in roi_combs[ri]:
		mask += (atlas_img==subroi)
	mask *= (prf_img[:,:,:,r2_dim] > .3)
	mask *= (prf_img[:,:,:,ecc_dim] > .5)
	mask *= (prf_img[:,:,:,ecc_dim] < 8)	
	mask *= np.invert(np.isnan(prf_img[:,:,:,pol_dim]))
	pl.hist(prf_img[mask,size_dim],bins=20,alpha=0.5,label=ri)
	pl.legend()
	# pl.xlim(0,360)
	sn.despine(offset=2)
	# pl.xticks(np.arange(0,361,90))

pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'sizehist_groups.pdf'))



f = pl.figure(figsize=(6,6));k=0
for ri in roi_combs.keys():

	k+=1
	# s = f.add_subplot(1,3,k)
	# pl.title(ri)
	mask = np.zeros_like(prf_img[:,:,:,0]).astype(bool)
	for subroi in roi_combs[ri]:
		mask += (atlas_img==subroi)
	mask *= (prf_img[:,:,:,r2_dim] > .1)
	mask *= np.invert(np.isnan(prf_img[:,:,:,pol_dim]))
	mask *= (prf_img[:,:,:,ecc_dim] > .5)
	mask *= (prf_img[:,:,:,ecc_dim] < 8)
	sn.regplot(prf_img[mask,ecc_dim],prf_img[mask,size_dim])#bins=20,alpha=0.5,label=ri)
	pl.legend()
	# pl.xlim(0,360)
	sn.despine(offset=2)
	# pl.xticks(np.arange(0,361,90))

pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'ecc_size_groups.pdf'))



f = pl.figure()
# guess dimensions:
for ri in np.unique(atlas_img):

	print min_angle = np.min(prf_img[mask,pol_dim],

	s = f.add_subplot(6,5,ri+1)
	mask = (atlas_img==ri)
	mask *= (prf_img[:,:,:,r2_dim] > .1)
	mask *= (prf_img[:,:,:,pol_dim] > .25)
	try:
		pl.hist(prf_img[mask,pol_dim],bins=20)
		pl.xlim(0,np.pi*2)
		sn.despine(offset=2)
	except:
		pass

pl.tight_layout()
pl.savefig(os.path.join(plot_dir,'eccsize.pdf'))
