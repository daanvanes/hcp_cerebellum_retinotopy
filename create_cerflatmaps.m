%% Introduction

% This matlab script uses the SUIT Toolbox (http://www.diedrichsenlab.org/imaging/suit.htm) in SPM12
% to create flatmap representations of the cerebellar retinotopy data.


% created by: Daan van Es (daan.van.es@gmail.com)


%% base setup

% this dir should point to where the masked niftis are stored:
data_dir = '/Users/daanvanes/disks/Aeneas_Shared/2018/visual/hcp_cerebellum/';
mask_dir = strcat(data_dir,'masked_niftis/');

% for the tsnr maps
tsnr_dir = strcat(data_dir,'timeseries/');

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
 for s = [0:180]%[181,182,183]%,0:4,88:92,176:180,183] % ! sj here refers to subject rank, not original subject id (except for 183, which still refers to avg subject)
    
    for h = [0,1,2]
        if ((s == 183) * (h == 0))
            masks = ["r2","r2_spill","r2_spill_fix"];
            vars = ["ang","ecc","rfsize","r2"];
            sj = num2str(s);
        elseif s > 180
            masks = ["r2_spill_fix"];
            vars = ["ang","ecc","rfsize","r2"];%"ang","ecc"];
            if h > 0
                sj = strcat(num2str(s),'_',num2str(h));             
            else
                sj = num2str(s);
            end       
        else
            masks = ["r2_fix_roi"];
            vars = ["ecc"];
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
                write_data=false;
                if (var == "ang") + (var == "ecc") + (var == "r2")
                    if ((s == 183) * (h == 0))
                        if mask == "r2_spill_fix"
                            write_data = true;
                        end
                    elseif s < 183
                       write_data = true;
                    end
                end
                
                if write_data
                    fn = strcat(flat_dir,var,'_flatdata_',sj,'.csv');
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
   
 end

 close('all')


%% create tsnr maps
 
close('all')
for s = [184,185,186]%[0:4,88:92,176:180]%,181:183]%:180]

    
    % load data:
    dir = char(strcat(tsnr_dir,'sub_rank_',num2str(s),'_tsnr_avg_over_tasks.nii'));
    Data = suit_map2surf(dir,'space','FSL','stats',@nanmean,'depths',0:0.1:1);

    cm = colorcet('L8');             
    
    if (s ==180) + (s ==182) + (s == 183)
        sc = [0,750];    
    else
        sc = [0,75];
    end
                      
    suit_plotflatmap(Data,'cmap',cm,'cscale',sc);     
    hAxes = gca;
    hAxes.XRuler.Axle.LineStyle = 'none';
    axis off
    set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
    fn = strcat(flatmap_dir,'tSNR_',num2str(s),'.pdf');
    print(gcf,fn,'-dpdf','-r300');
    close()

end

%% create tsnr maps
 
close('all')

% load data:
dir = char(strcat(tsnr_dir,'tsnr_rank_corrs.nii'));
Data = suit_map2surf(dir,'space','FSL','stats',@nanmean,'depths',0:0.1:1);

cm = colorcet('L8');             
sc = [-0.5,0];

suit_plotflatmap(Data,'cmap',cm,'cscale',sc);     
hAxes = gca;
hAxes.XRuler.Axle.LineStyle = 'none';
axis off
set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
fn = strcat(flatmap_dir,'tSNR_rank_corrs.pdf');
print(gcf,fn,'-dpdf','-r300');
close()

%% new data 

new_flat_dir = '/Users/daanvanes/disks/Aeneas_Shared/2018/visual/cerebellum_prf/derivatives/pp/prf/';
ses = '01020304';
postFix = 'hrf075_nongcv';
for r2thresh = [0.05,0.1,0.2]%0.05,0.1,0.2,0.3,0.4,0.5]
    for sub = [2]%["01"]%,"02","03"]

        fn = strcat(new_flat_dir,'sub-0',num2str(sub),'/sub-0',num2str(sub),'_new_prf_results_zscore_ses_',ses,postFix,'thresh_ang_',sprintf('%0.2f',r2thresh),'_cmask_pos.nii');

        blue = [45,52,135];
        red = [153,27,68];
        yellow = [250,195,83];
        green = [0,153,74];
        magenta = [223,112,172];
        cyan = [110,207,246];
        rgbs = [yellow;green;green;green;cyan;blue;magenta;red;yellow]/255;                
        cm = interpolate_cvals_rgbspace(rgbs);
    %     % use circular mean 
        func = @circ_mean_adapted; % adapted such that it is appropriately used in suit toolbox
        sc = [0,pi*2];
        threshold=0;
        % load data:
        Data = suit_map2surf(fn,'space','FSL','stats',func,'depths',0:0.1:1);

        % plot flatmap
        suit_plotflatmap(Data,'cmap',cm,'cscale',sc,'threshold',threshold);     
        hAxes = gca;
        hAxes.XRuler.Axle.LineStyle = 'none';
        axis off
        set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
        fn = strcat(new_flat_dir,'sub-0',num2str(sub),'/sub-0',num2str(sub),'_new_prf_results_zscore_ses_',ses,postFix,'thresh_ang_',sprintf('%0.2f',r2thresh),'_pos_flatmap.pdf');
        print(gcf,fn,'-dpdf','-r300');
        close()
    end
end
%% new data 2

new_flat_dir = '/Users/daanvanes/disks/Aeneas_Shared/2018/visual/cerebellum_prf/derivatives/pp/prf/';
for sub = [1,2]%,3]%1,2,3]%["01"]%,"02","03"]
    for var = ["r2"]%"ang","ecc","size"]
        if (sub == 1) + (sub ==3)
            ses = '010203';
        elseif sub ==2
            ses = '01020304';
        end
        fn = strcat(new_flat_dir,'sub-0',num2str(sub),'/sub-0',num2str(sub),'_new_prf_results_zscore_ses_',ses,'_cartfit_hrf0.75_gray_matter_cv_thresh_',var,'__spillmask_pos.nii');
        
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

            % use circular mean 
            func = @circ_mean_adapted; % adapted such that it is appropriately used in suit toolbox
            sc = [0,pi*2];
            threshold=0;

        elseif strcmp(var,'ecc')
            cm = colorcet('R2');                
            sc = [0,15];
            func=@nanmean;

        elseif strcmp(var,'r2')
            cm = colorcet('L8');
            sc = [0.098,0.6];
            threshold = 0.05;
            func=@nanmean;

        elseif strcmp(var,'size')
            cm = colorcet('L5');
            sc = [0,15];
            func=@nanmean;
        end
        
        % load data:
        Data = suit_map2surf(char(fn),'space','FSL','stats',func,'depths',0:0.1:1);

        % plot flatmap
        suit_plotflatmap(Data,'cmap',cm,'cscale',sc,'threshold',threshold);     
        hAxes = gca;
        hAxes.XRuler.Axle.LineStyle = 'none';
        axis off
        set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
        fn = strcat(new_flat_dir,'sub-0',num2str(sub),'/sub-0',num2str(sub),'_new_prf_results_zscore_thresh_',var,'_pos_flatmap.pdf');
        print(gcf,fn,'-dpdf','-r300');
        close()
    end
end

%% Brissenden CV R2

brissenden_dir = '/Users/daanvanes/Documents/Documenten/Research/data/hcp_retinotopy/brissenden_data/';
sc = [0.05,0.25];
threshold=0.05;
for s = [1,2,3,4,5]
    


    fn = char(strcat(brissenden_dir,'S',num2str(s),'.xvalcorr.nii'));

    Data = suit_map2surf(fn,'depths',0:0.1:1);

    % plot flatmap
    suit_plotflatmap(Data,'cmap',colorcet('coolwarm'),'cscale',sc,'threshold',threshold)%,'type','label')
    hAxes = gca;
    hAxes.XRuler.Axle.LineStyle = 'none';
    axis off
    set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
    fn = strcat(brissenden_dir,'S',num2str(s),'.pdf');
    print(gcf,fn,'-dpdf','-r300');
    close() 
    
end

fn = char(strcat(brissenden_dir,'avg_over_subs.nii'));

Data = suit_map2surf(fn,'depths',0:0.1:1);

% plot flatmap
suit_plotflatmap(Data,'cmap',colorcet('L8'),'cscale',sc,'threshold',threshold)%,'type','label')
hAxes = gca;
hAxes.XRuler.Axle.LineStyle = 'none';
axis off
set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])
fn = strcat(brissenden_dir,'avg_over_subs.pdf');
print(gcf,fn,'-dpdf','-r300');
close() 
