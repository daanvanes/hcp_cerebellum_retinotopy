%% base setup

data_dir = '/Users/daanvanes/Documents/Documenten/Research/data/hcp_retinotopy/hcp_data/best_subjects/';
flatmap_dir = '/Users/daanvanes/Documents/Documenten/Research/data/hcp_retinotopy/hcp_data/suit_flatmaps/';

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

fn = strcat(flatmap_dir,'figs/Buckner7.pdf');
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
 for s = [183]%,184,0:10]
    
    if s == 183
        masks = ["r2_spill_size"];%","r2_spill_ecc"];%,"r2high_spill","r2_buck"];"r2",
        sj = 'avg';
    elseif s == 184
        sj = 'wavg';
        masks = ["r2_roi"];%["r2_roi"];
    else
        masks = ["r2_roi"];%["r2_roi"];
        sj = num2str(s);
    end
    
    for mask = masks
    
        for var = ["ecc2"]%["ecc","ecc2","polar","size","r2"]%,"dist","instim"]
            


            cm = hot(100);
            threshold=0;
            if strcmp(var,'polar')
                cm = hsv(100);
                sc = [0,360];
            elseif strcmp(var,'ecc')
%                 cm = [[0.05;0.4;0.7;0.9;1], zeros(5,2)];
%                 colormap(cm);
                
%                 cm = jet(100);
                sc = [0,8];
%                 threshold=0.075
            elseif strcmp(var,'ecc2')
                sc = [0,0.15];
            elseif strcmp(var,'bck')
                sc = [0,100];                
                threshold = 100
            elseif strcmp(var,'r2')
                sc = [9.8,40]; 
            elseif strcmp(var,'size')
                sc = [2,8];
                threshold=0.1;
            elseif strcmp(var,'dist')
                sc = [0,1];
                threshold = 0.1;
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
            Data = suit_map2surf(dir,'space','FSL','stats',@nanmean);
            suit_plotflatmap(Data,'cmap',cm,'cscale',sc,'threshold',threshold);
                
%             colorbar;

            hAxes = gca;
            hAxes.XRuler.Axle.LineStyle = 'none';
            axis off
                        
%             set(gcf,'units','inch','position',[0,0,5,5]);
            set(gcf,'paperunits','inches','papersize',[3,3],'paperposition',[-1.1,-1.1,5,5])

            fn = strcat(flatmap_dir,'figs/',savevar,'_',num2str(sj),'flatmap','_',mask,'.pdf');
            print(gcf,fn,'-dpdf','-r300');
            close()


        end
    end
 end

 close('all')
