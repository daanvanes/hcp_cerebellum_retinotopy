%% Introduction

% This matlab script uses the SUIT Toolbox (http://www.diedrichsenlab.org/imaging/suit.htm) in SPM12
% to create flatmap representations of the cerebellar retinotopy data.


% created by: Daan van Es (daan.van.es@gmail.com)


%% base setup

% this dir should point to where the masked niftis are stored:
data_dir = '/Users/daanvanes/disks/Aeneas_Shared/2018/visual/hcp_cerebellum/';
mask_dir = strcat(data_dir,'masked_niftis/');

% this dir should point to where you want the flatmaps saved
flatmap_dir = '/Users/daanvanes/Documents/Documenten/Research/data/hcp_retinotopy/hcp_data/suit_flatmaps/';
if exist(flatmap_dir,'dir') ~= 7
    mkdir(flatmap_dir)
end

% this is where the flattened data is stored
flat_dir = strcat(data_dir,'flat_data/');
if exist(flat_dir,'dir') ~= 7
    mkdir(flat_dir)
end

% this should be your spm / suit install:
addpath('/Applications/spm12')
addpath('/Applications/spm12/toolbox/suit')

% fsl colormap dir
fsl_cmap_dir = '/Applications/FSLeyes.app/Contents/Resources/assets/colourmaps/';

% this is the git repo (www.github.com/daanvanes/hcp_cerebellum):
resource_dir = '/Users/daanvanes/disks/Aeneas_Home/git/hcp_cerebellum/resources/';
mat_functions = strcat(resource_dir,'mscripts');
addpath(mat_functions)


%% create flattened representation of cerebellar retinotopic masks

fn = strcat(resource_dir,'volume_masks/','cerebellum_retmaps.nii');

Data = int32(suit_map2surf(fn,'depths',0:0.1:1));

% random colors
cm = [
120 ,18 ,134;
255, 0, 0;
70, 130, 180;
42, 204, 164;
74, 155, 60 ;
0, 118, 14;
196, 58, 250;
255, 152, 213;
200, 248, 164;
122, 135, 50;]/255;
            
% save data matrix
fn = strcat(flat_dir,'retmaps_flat.csv');
csvwrite(fn,Data)

% plot flatmap
suit_plotflatmap(Data,'type','label','cmap',cm)
hAxes = gca;
hAxes.XRuler.Axle.LineStyle = 'none';
axis off
set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
fn = strcat(flatmap_dir,'retmaps.pdf');
print(gcf,fn,'-dpdf','-r300');
close()   
%% now create the actual flatmaps

close('all')
 for s = [183]%[0:4,88:92,176:180,183] % ! sj here refers to subject rank, not original subject id (except for 183, which still refers to avg subject)
    
    if s == 183
        masks = ["r2","r2_spill","r2_spill_fix"];
        vars = ["ang","ecc","rfsize","r2"];
        sj = 'avg';       
    else
        masks = ["r2_roi"];
        vars = ["ang"];
        sj = num2str(s);
    end
    
    for mask = masks             
        for var = vars
            
            threshold=0;
            % the standard function to perform across layers:
            func=@nanmean;
            
            if strcmp(var,'ang')
                
                % create a colormap that is more focused on the lower
                % visual fied:
                blue = [45,52,135];
                red = [153,27,68];
                yellow = [250,195,83];
                green = [0,153,74];
                magenta = [223,112,172];
                cyan = [110,207,246];
                rgbs = [yellow;green;green;green;cyan;blue;magenta;red;yellow]/255;                
                cm = interpolate_cvals_rgbspace(rgbs);

                % save cmap as .cmap that can be read by FSLeyes
                fn = strcat(fsl_cmap_dir,'angcmap.cmap');
                fileID = fopen(fn,'w');
                formatSpec = '%1.6f %1.6f %1.6f \n';   
                [nrows,ncols] = size(cm);
                for row = 1:nrows
                    fprintf(fileID,formatSpec,cm(row,:));
                end
                fclose(fileID);
                
                % use circular mean 
                func = @circ_mean_adapted; % adapted such that it is appropriately used in suit toolbox
                sc = [0,pi*2];
                
            elseif strcmp(var,'ecc')
                cm = colorcet('R2');                
                sc = [0,6];

                % save cmap as .cmap that can be read by FSLeyes                
                fn = strcat(fsl_cmap_dir,'ecccmap.cmap');
                fileID = fopen(fn,'w');
                formatSpec = '%1.6f %1.6f %1.6f \n';   
                [nrows,ncols] = size(cm);
                for row = 1:nrows
                    fprintf(fileID,formatSpec,cm(row,:));
                end
                fclose(fileID);

            elseif strcmp(var,'r2')
                cm = colorcet('L8');             
                sc = [9.8,40];

            elseif strcmp(var,'rfsize')
                cm = colorcet('L5');
                sc = [0,6];
            end

            % load data:
            dir = char(strcat(mask_dir,mask,'/','prfresults_subject_rank_',sj,'_',var,'.nii'));
            Data = suit_map2surf(dir,'space','FSL','stats',func,'depths',0:0.1:1);
            
            
            % save data matrix (for later plots along a certain direction
            % on the flatmap)
            if ((sj == "avg") * ((var == "ang") + (var == "ecc")+ (var == "r2")) * strcmp(mask,'r2_spill_fix')) == 1
                fn = strcat(flat_dir,var,'_flatdata_avgsj.csv');
                csvwrite(fn,Data)
            end
            
            % plot flatmap
            suit_plotflatmap(Data,'cmap',cm,'cscale',sc,'threshold',threshold);     
            hAxes = gca;
            hAxes.XRuler.Axle.LineStyle = 'none';
            axis off
            set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
            fn = strcat(flatmap_dir,var,'_',num2str(sj),'flatmap','_',mask,'.pdf');
            print(gcf,fn,'-dpdf','-r300');
            close()


        end
    end
 end

 close('all')
