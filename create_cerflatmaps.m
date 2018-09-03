%% base setup

data_dir = '/Users/daanvanes/Documents/Documenten/Research/data/hcp_retinotopy/hcp_data/masked_niftis/';
flatmap_dir = '/Users/daanvanes/Documents/Documenten/Research/data/hcp_retinotopy/hcp_data/suit_flatmaps/';

addpath('/Applications/spm12')
addpath('/Applications/spm12/toolbox/suit')
addpath('/Users/daanvanes/disks/Aeneas_Home/git/hcp_cerebellum')

%% own masks

fn = '/Users/daanvanes/Documents/Documenten/Research/data/hcp_retinotopy/atlases/all_masks_together.nii';
Data = suit_map2surf(fn);
cm = [120,  18, 134; 
70, 130, 180  ;
0, 118,  14,  ;
196,  58, 250;  
220, 248, 164  ;
230, 148,  34  ;
 205,  62,  78]/255;

suit_plotflatmap(Data,'type','label','cmap',cm)

hAxes = gca;
hAxes.XRuler.Axle.LineStyle = 'none';
axis off

set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])

fn = strcat(flatmap_dir,'figs/retmaps.pdf');
print(gcf,fn,'-dpdf','-r300');
close()
%% 7 network map

cd /Applications/spm12/toolbox/suit/atlas;
Data = suit_map2surf('Buckner_7Networks.nii','stats',@mode);
cm = [120,  18, 134; 
70, 130, 180  ;
0, 118,  14,  ;
196,  58, 250;  
220, 248, 164  ;
230, 148,  34  ;
 205,  62,  78]/255;


suit_plotflatmap(Data,'type','label','cmap',cm)

hAxes = gca;
hAxes.XRuler.Axle.LineStyle = 'none';
axis off

set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])

fn = strcat(flatmap_dir,'Buckner7.pdf');
print(gcf,fn,'-dpdf','-r300');
close()

%% buck 3

cd /Applications/spm12/toolbox/suit/atlas;
Data = suit_map2surf('buckner3_edited.nii','stats',@mode);
cm = [0, 118,  14,  ;
    120,  18, 134; 
70, 130, 180  ;

196,  58, 250;  
220, 248, 164  ;
230, 148,  34  ;
 205,  62,  78]/255;
% cm = [1,1,1; 
% 1,1,1;
% 0,0,0;
% 1,1,1;
% 1,1,1;
% 1,1,1;
% 1,1,1];

suit_plotflatmap(Data,'type','label','cmap',cm)

hAxes = gca;
hAxes.XRuler.Axle.LineStyle = 'none';
axis off

set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])

fn = strcat(flatmap_dir,'Buckner3.pdf');
print(gcf,fn,'-dpdf','-r300');
close()
%% 17 network map

Data = suit_map2surf('Buckner_17Networks.nii','stats',@mode);
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
122, 135, 50;
119, 140, 176; 
230, 148, 34;
135, 50, 74; 
12, 48, 255;
0, 0, 130;
255, 255, 0; 
205, 62, 78;]/255;
suit_plotflatmap(Data,'type','label','cmap',cm)

hAxes = gca;
hAxes.XRuler.Axle.LineStyle = 'none';
axis off

set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])

fn = strcat(flatmap_dir,'figs/Buckner17.pdf');
print(gcf,fn,'-dpdf','-r300');
close()
           
%% 

close('all')
 for s = [80:181]%[184]%[10:20]%,184]%[0:10]%[183]%,184,0:10]
    
    if s == 183
        masks = ["r2","r2_spill","r2_spill_fix"];%","r2_spill_ecc"];%,"r2high_spill","r2_buck"];"r2",
        sj = 'avg';
    elseif s == 184
        sj = 'wavg';
        masks = ["r2_roi"];%"r2","r2_spill","r2_spill_fix"];%["r2_roi"];
    elseif s == 185
        sj = 'wavgmask';
        masks = ["r2_roi"];%["r2_roi"];        
    else
        masks = ["r2_roi"];%["r2_roi"];
        sj = num2str(s);
    end
    
    for mask = masks
                
    
        for var = ["r2","ang","ecc","ecc2","rfsize"]%["ecc","ecc2","polar","size","r2"]%,"dist","instim"]
            
%             cm = hot(100);
            threshold=0;
            func=@nanmean;
            if strcmp(var,'ang')
%                   % remake from hcp paper:
%                 hues = [linspace(144,193,100),linspace(193,232,100),linspace(232,268,100),linspace(268,303,100),linspace(303,330,100),linspace(330,357,100),linspace(357,55,100),linspace(55,144,100)]/360;
%                 n = size(hues);
%                 saturations = ones(1,n(2))*0.9;
%                 brightnesses = ones(1,n(2))*0.9;
%                 hsvs = vertcat([hues;saturations;brightnesses]);
%                 cm =hsv2rgb(hsvs');  

                % perceptually uniform:
%                 cm = colorcet('C1');
                
                cm = hsv(100);
                sc = [0,pi*2];
                func = @circ_mean_adapted;
            elseif strcmp(var,'ecc')
                cm = colorcet('L3');
%                 cm = [[0.05;0.4;0.7;0.9;1], zeros(5,2)];
%                 colormap(cm);
                
%                 cm = jet(100);
                sc = [0,6];
%                 threshold=0.075
            elseif strcmp(var,'ecc2')
                if sj == 183
                    sc = [0,0.5];
                else
                    sc = [0,3];
                end
                cm = colorcet('L3');                
                    
            elseif strcmp(var,'bck')
                sc = [0,100];                
                threshold = 100;
            elseif strcmp(var,'r2')
                cm = colorcet('L6');
                
%                 cm = cool(100);   
                if sj == 183
                    sc = [9.8,40];
                elseif sj == 184
                    sc = [3.7,15];
                else
                    sc = [2.2,10];
                end
            elseif strcmp(var,'rfsize')
                cm = colorcet('L5');
                sc = [0,6];
%                 threshold=0.1;
            elseif strcmp(var,'dist')
                sc = [0,1];
%                 threshold = 0.1;
            elseif strcmp(var,'instim')
                sc = [0,1];
            end
            
            if var == "ecc2"
                var = "ecc";
                savevar = "ecc2";
            else
                savevar = var;
            end
            
            if var == "bck"
                var = "ecc";
                savevar = "bck";
            end
            
            dir = char(strcat(data_dir,mask,'/','prfresults_subject_rank_',sj,'_',var,'.nii'));
            Data = suit_map2surf(dir,'space','FSL','stats',func,'depths',0:0.1:1);
            suit_plotflatmap(Data,'cmap',cm,'cscale',sc,'threshold',threshold);
                
%             colorbar;

            hAxes = gca;
            hAxes.XRuler.Axle.LineStyle = 'none';
            axis off
                        
%             set(gcf,'units','inch','position',[0,0,5,5]);
            set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])

            fn = strcat(flatmap_dir,savevar,'_',num2str(sj),'flatmap','_',mask,'.pdf');
            print(gcf,fn,'-dpdf','-r300');
            close()


        end
    end
 end

 close('all')
