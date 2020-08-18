%% ANA SCRIPT
%%
liste=importdata ('D:\Program Files\MATLAB\fieldtrip-20200109\go_grup_data\subject_names.txt');
%%
agg_condition = [1	1	2	1	1	1	1	2	2	1	1	1	2	1	1	1	2	2	2	2	2	2]; %% 1 = low, 2 = high
phy_condition = [1	1	2	1	1	1	1	1	2	1	1	1	2	1	1	1	2	1	2	2	2	1];
all_subjects = [];
for i=1:length(liste)  
all_subjects{i} = fieldtrip_transformer(liste{i});
all_subjects{i}.agg_condition = agg_condition(i);
all_subjects{i}.phy_condition = phy_condition(i);
end  
load ('D:\Program Files\MATLAB\fieldtrip-20200109\go_grup_data\yeni_subjects.mat');
for k = 1:22
    for i = 1:150
        all_subjects{k}.trial{i}=yeni_subjects{k}.trial{i};
    end
end
%% preprocessing ve visualization
cd('D:\Program Files\MATLAB\fieldtrip-20200109');
load ('layout_capa');
load ('neighbours');
ft_defaults
for i=1:length(liste)
all_subjects{i}.cfg.preproc = [];
all_subjects{i}.cfg.preproc.hpfilter= 'yes' ;
all_subjects{i}.cfg.preproc.hpfilter=[0.1]; % 0.1
all_subjects{i}.cfg.preproc.lpfilter = 'yes';
all_subjects{i}.cfg.preproc.lpfreq = [30];
all_subjects{i}.cfg.preproc.cfg.dftfreq = [50 100 150 200 250];
all_subjects{i}.cfg.preproc.baselinewindow  = [-0.2 0]; %0.2
all_subjects{i}.cfg.preproc.cfg.detrend = 'yes';
all_subjects{i}.cfg.preproc.cfg.demean = 'yes';
[all_subjects{i}.preprocessed_data] = ft_preprocessing(all_subjects{i}.cfg, all_subjects{i} );
end 
%% Düzeltilmesi gereken trialinfolarý bulma 
Trial_infos = {}; 
for i = 1:22; 
 Trial_infos{1,i} =  all_subjects{1, i}.trialinfo.Names; 
end
% Subjets 8, 9 ve 10 için trial infolarýn satýr sýrasý yanlýþ. Doðru
% sýralama = artfree, nogo, go, buttonpress olmalý. Averaj alýnacaðý zaman
% triallarý seçmek gerekiyor ve bu durum yanlýþlýða sebep oluyor.
%Subject 8 donusum
all_subjects{1, 8}.trialinfo.Data(5,:) = all_subjects{1, 8}.trialinfo.Data(1,:); 
all_subjects{1, 8}.trialinfo.Data(1,:) =  all_subjects{1, 8}.trialinfo.Data(2,:);
all_subjects{1, 8}.trialinfo.Data(2,:) = all_subjects{1, 8}.trialinfo.Data(3,:); 
all_subjects{1, 8}.trialinfo.Data(3,:) = all_subjects{1, 8}.trialinfo.Data(4,:); 
all_subjects{1, 8}.trialinfo.Data(4,:) = all_subjects{1, 8}.trialinfo.Data(5,:);
%Subject 9 donusum
all_subjects{1, 9}.trialinfo.Data(5,:) = all_subjects{1, 9}.trialinfo.Data(2,:); 
all_subjects{1, 9}.trialinfo.Data(2,:) = all_subjects{1, 9}.trialinfo.Data(3,:); 
all_subjects{1, 9}.trialinfo.Data(3,:) = all_subjects{1, 9}.trialinfo.Data(4,:); 
all_subjects{1, 9}.trialinfo.Data(4,:) = all_subjects{1, 9}.trialinfo.Data(5,:); 
% Subject 10 donusum 
all_subjects{1, 10}.trialinfo.Data(5,:) = all_subjects{1, 10}.trialinfo.Data(2,:); 
all_subjects{1, 10}.trialinfo.Data(2,:) = all_subjects{1, 10}.trialinfo.Data(3,:); 
all_subjects{1, 10}.trialinfo.Data(3,:) = all_subjects{1, 10}.trialinfo.Data(4,:); 
all_subjects{1, 10}.trialinfo.Data(4,:) = all_subjects{1, 10}.trialinfo.Data(5,:);

%% Manuel Visual Artifact Rejection (TRIAL REJECT ETMEK SELEC TRIAL OPSÝYONUNU BOZUYOR!)
cfg        = [];
cfg.method = 'trial';
cfg.keepchannel = 'repair'; 
cfg.neighbours = neighbours;
cfg.layout = layout_capa; 
ft_databrowser(cfg,all_subjects{1, 6}.selected_trials_agg_nogo)
all_subjects{1, 6}.selected_trials_agg_nogo = ft_rejectvisual(cfg, all_subjects{1, 6}.selected_trials_agg_nogo);
save ALL_SUBJECTS_artfree all_subjects
%% Bad channel repair sj 16 ch 02
cfg=[];
cfg.method         = 'weighted';
cfg.badchannel     = {'O2'};
cfg.neighbours     = neighbours;
cfg.layout = layout_capa;
cfg.trials         = 'all' ;
cfg.lambda         = 1e-5 ;
cfg.order          = 4;
all_subjects{16}.preprocessed_data= ft_channelrepair(cfg, all_subjects{16}.preprocessed_data);
%High agg nogo grupta sj 2 6 9 F4 kanal gürültüsü??
cfg=[];
cfg.method         = 'weighted';
cfg.badchannel     = {'F4'};
cfg.neighbours     = neighbours;
cfg.layout = layout_capa;
cfg.trials         = 'all' ;
cfg.lambda         = 1e-5 ;
cfg.order          = 4;
for i = [8 18 21 ]
all_subjects{1,i}.preprocessed_data= ft_channelrepair(cfg, all_subjects{1,i}.preprocessed_data);
end
%check rejection
cfg=[]; 
cfg.viewmode = 'vertical';
cfg.layout = layout_capa;
cfg.channel     = {'all', '-eog', '-emg'};
ft_databrowser(cfg, all_subjects{1, 9}.selected_trials_agg_nogo)
hold on
ft_databrowser(cfg,grandavg_low_agg_nogo)
% %% %% ICA 
% cfg = [];
% cfg.channel = {'all' '-emg' '-eog'};
% cfg.method = 'runica';
% all_subjects{22}.ica = ft_componentanalysis(cfg,all_subjects{22}.preprocessed_data);
% % plot the components for visual inspection
% figure
% cfg = [];
% cfg.component = 1:14;       % specify the component(s) that should be plotted
% cfg.layout    = layout_capa; % specify the layout file that should be used for plotting
% cfg.comment   = 'no';
% ft_topoplotIC(cfg, all_subjects{22}.ica);
% cfg.viewmode = 'component';
% ft_databrowser(cfg, all_subjects{22}.ica);
% %Reject components if necessary
% cfg.component = [1]; % to be removed component(s)
% all_subjects{22}.preprocessed_data = ft_rejectcomponent(cfg, all_subjects{22}.ica);
% % % ARTIK ICA SONUCUNU KAYET ALLAHIN CEZASI DANGALAK HERÝF!!!
% save ALL_SUBJECTS_artfree all_subjects
%% Trial Selection based on experimental condition and groups (SUBJECTLERIN TRIAL SAYILARINI CHECK ET)
ft_defaults
for i=1:22
all_subjects{1,i}.cfg=[];
all_subjects{1,i}.cfg.trials   = find(all_subjects{1,i}.trialinfo.Data(1,:) == 1 & all_subjects{1,i}.trialinfo.Data(2,:) == 1 & all_subjects{1,i}.trialinfo.Data(4,:) == 0  );
[all_subjects{1,i}.selected_trials_agg_nogo] = ft_selectdata(all_subjects{1,i}.cfg,all_subjects{1, i}.preprocessed_data);
end
for i=1:22
all_subjects{i}.cfg.trials   = find(all_subjects{1,i}.trialinfo.Data(1,:) == 1 & all_subjects{i}.trialinfo.Data(3,:) == 1 & all_subjects{1,i}.trialinfo.Data(4,:) == 1 );
[all_subjects{i}.selected_trials_agg_go] = ft_selectdata(all_subjects{i}.cfg,all_subjects{1, i}.preprocessed_data);
end
for i=1:22
all_subjects{i}.cfg.trials   = find(all_subjects{1,i}.trialinfo.Data(1,:) == 1 & all_subjects{i}.trialinfo.Data(2,:) == 1 & all_subjects{1,i}.trialinfo.Data(4,:) == 0 );
[all_subjects{i}.selected_trials_phy_nogo] = ft_selectdata(all_subjects{i}.cfg,all_subjects{1, i}.preprocessed_data);
end
for i=1:22
all_subjects{i}.cfg.trials   = find(all_subjects{1,i}.trialinfo.Data(1,:) == 1 & all_subjects{i}.trialinfo.Data(3,:) == 1 & all_subjects{1,i}.trialinfo.Data(4,:) == 1 );
[all_subjects{i}.selected_trials_phy_go] = ft_selectdata(all_subjects{i}.cfg,all_subjects{1, i}.preprocessed_data);
end

save all_subjects all_subjects
%% Inter-trial averaging per subject

for i=1:22;
all_subjects{i}.cfg=[];
[all_subjects{i}.timelocked_data_agg_nogo] = ft_timelockanalysis(all_subjects{i}.cfg,all_subjects{i}.selected_trials_agg_nogo);
end
for i=1:22;
       all_subjects{i}.cfg=[];
[all_subjects{i}.timelocked_data_agg_go] = ft_timelockanalysis(all_subjects{i}.cfg,all_subjects{i}.selected_trials_agg_go);
end
for i=1:22;
   all_subjects{i}.cfg=[];
[all_subjects{i}.timelocked_data_phy_nogo] = ft_timelockanalysis(all_subjects{i}.cfg,all_subjects{i}.selected_trials_phy_nogo);
end
for i=1:22;
       all_subjects{i}.cfg=[];
[all_subjects{i}.timelocked_data_phy_go] = ft_timelockanalysis(all_subjects{i}.cfg,all_subjects{i}.selected_trials_phy_go);
end
%% Behavioral dataya (agresyona göre) ve deney koþuluna (go - nogo) göre  subjectleri gruplama
% Total agresyona göre
high_aggr_go = {};
for i=1:22 
    if all_subjects{1, i}.agg_condition == 2
        high_aggr_go{i}= all_subjects{1, i}.timelocked_data_agg_go;
    end
end 
low_aggr_go = {};
for i=1:22 
    if all_subjects{1, i}.agg_condition == 1
        low_aggr_go{i}= all_subjects{1, i}.timelocked_data_agg_go;
    end
end
low_aggr_nogo = {};
for i=1:22
    if all_subjects{1, i}.agg_condition == 1
        low_aggr_nogo{i}= all_subjects{1, i}.timelocked_data_agg_nogo;
    end
end
high_aggr_nogo = {};
for i=1:22
    if all_subjects{1, i}.agg_condition == 2
        high_aggr_nogo{i}= all_subjects{1, i}.timelocked_data_agg_nogo;  
    end
end

%Physical agresyona göre
high_phyaggr_go = {};
for i=1:22 
    if all_subjects{1, i}.phy_condition == 2
        high_phyaggr_go{i}= all_subjects{1, i}.timelocked_data_phy_go;
    end
end 
low_phyaggr_go = {};
for i=1:22 
    if all_subjects{1, i}.phy_condition == 1
        low_phyaggr_go{i}= all_subjects{1, i}.timelocked_data_phy_go;
    end
end
low_phyaggr_nogo = {};
for i=1:22 
    if all_subjects{1, i}.phy_condition == 1
        low_phyaggr_nogo{i}= all_subjects{1, i}.timelocked_data_phy_nogo;
    end
end
high_phyaggr_nogo = {};
for i=1:22 
    if all_subjects{1, i}.phy_condition == 2
        high_phyaggr_nogo{i}= all_subjects{1, i}.timelocked_data_phy_nogo;  
    end
end
%Bos celleri silme 
empties = find(cellfun(@isempty,  high_phyaggr_nogo)); % identify the empty cells
high_phyaggr_nogo(empties) = [] ; 
empties = find(cellfun(@isempty,  high_phyaggr_go)); % identify the empty cells
high_phyaggr_go(empties) = [] ; 
empties = find(cellfun(@isempty,  low_phyaggr_go)); % identify the empty cells
low_phyaggr_go(empties) = [] ; 
empties = find(cellfun(@isempty,  low_phyaggr_nogo)); % identify the empty cells
low_phyaggr_nogo(empties) = [] ; 
empties = find(cellfun(@isempty,  high_aggr_nogo)); % identify the empty cells
high_aggr_nogo(empties) = [] ; 
empties = find(cellfun(@isempty,  high_aggr_go)); % identify the empty cells
high_aggr_go(empties) = [] ; 
empties = find(cellfun(@isempty,  low_aggr_nogo)); % identify the empty cells
low_aggr_nogo(empties) = [] ; 
empties = find(cellfun(@isempty,  low_aggr_go)); % identify the empty cells
low_aggr_go(empties) = [] ; 
%% Grand Average 
cfg=[];
[grandavg_low_agg_go] = ft_timelockgrandaverage(cfg, low_aggr_go{:});
[grandavg_high_agg_go] = ft_timelockgrandaverage(cfg, high_aggr_go {:});
[grandavg_low_agg_nogo] = ft_timelockgrandaverage(cfg, low_aggr_nogo {:});
[grandavg_high_agg_nogo] = ft_timelockgrandaverage(cfg, high_aggr_nogo {:});

[grandavg_low_phyagg_go] = ft_timelockgrandaverage(cfg, low_phyaggr_go {:});
[grandavg_high_phyagg_go] = ft_timelockgrandaverage(cfg, high_phyaggr_go {:});
[grandavg_high_phyagg_nogo] = ft_timelockgrandaverage(cfg, high_phyaggr_nogo {:});
[grandavg_low_phyagg_nogo] = ft_timelockgrandaverage(cfg, low_phyaggr_nogo {:});
save grandavg_high_agg_go grandavg_high_agg_go
save grandavg_high_agg_nogo grandavg_high_agg_nogo
save grandavg_low_agg_go grandavg_low_agg_go
save grandavg_low_agg_nogo grandavg_low_agg_nogo
save grandavg_high_phyagg_go grandavg_high_phyagg_go
save grandavg_high_phyagg_nogo grandavg_high_phyagg_nogo
save grandavg_low_phyagg_go grandavg_low_phyagg_go
save grandavg_low_phyagg_nogo grandavg_low_phyagg_nogo
%% Visualize the results 
cfg=[];
cfg.channel= {'all','-eog','-emg'}  ; 
cfg.layout = layout_capa;
ft_multiplotER(cfg,grandavg_low_agg_nogo,grandavg_high_agg_nogo)
plot(grandavg_low_agg_nogo.time,mean(grandavg_low_agg_go.avg(:,:)),'color','b');
hold on
plot(grandavg_high_agg_nogo.time,mean(grandavg_high_agg_go.avg(:,:)),'color','r');

%%High agg nogo F4 kanalýnda yüksek amplitude var
for i = 1:5 
    figure(1)
    subplot(5,1,i)
    plot(high_aggr_nogo{1, i}.time(:),high_aggr_nogo{1, i}.avg(3,:))
end
for i = 6:10
    figure(2)
    subplot(5,1,i-5)
    plot(high_aggr_nogo{1, i}.time(:),high_aggr_nogo{1, i}.avg(3,:))
end


%% ISTATISTIK 
%For total aggression
cfg = [];
cfg.correcttail = 'alpha';
cfg.channel     = {'all', '-eog', '-emg'};
cfg.layout = layout_capa;
cfg.neighbours  = neighbours; % defined as above
cfg.latency     = [0.2 0.5];
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_indepsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.clusteralpha = 0.05; 

cfg.numrandomization = 1000; 
cfg.minnbchan        = 2;
cfg.clusterstatistic = 'maxsum';
design = zeros(1,size(high_aggr_nogo(:),1) + size(low_aggr_nogo(:),1));
design(1,1:size(high_aggr_nogo(:),1)) = 1;
design(1,(size(high_aggr_nogo(:),1)+1):(size(high_aggr_nogo(:),1) + size(low_aggr_nogo(:),1)))= 2;
% design = [1 2];
cfg.design = design;             % design matrix
cfg.ivar  = 1;  

stat_agg_nogo = ft_timelockstatistics(cfg,high_aggr_nogo{:}, low_aggr_nogo{:});
stat_agg_go = ft_timelockstatistics(cfg, high_aggr_go{:}, low_aggr_go{:});

% For physical agression 
cfg = [];
cfg.channel     = {'all', '-eog', '-emg'};
cfg.layout = layout_capa;
cfg.neighbours  = neighbours; % defined as above
cfg.latency     = 'all';
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_indepsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.clusteralpha = 0.05; 
cfg.correcttail = 'alpha';
cfg.numrandomization = 1000; 
cfg.minnbchan        = 1;
cfg.clusterstatistic = 'maxsum';
design = zeros(1,size(high_phyaggr_nogo(:),1) + size(low_phyaggr_nogo(:),1));
design(1,1:size(high_phyaggr_nogo(:),1)) = 1;
design(1,(size(high_phyaggr_nogo(:),1)+1):(size(high_phyaggr_nogo(:),1) + size(low_phyaggr_nogo(:),1)))= 2;
cfg.design = design;             % design matrix
cfg.ivar  = 1;  
stat_phyagg_nogo = ft_timelockstatistics(cfg, high_phyaggr_nogo{:}, low_phyaggr_nogo{:});
stat_phyagg_go = ft_timelockstatistics(cfg, high_phyaggr_go{:}, low_phyaggr_go{:});


cfg = [];
cfg.style     = 'blank';
cfg.layout    = layout_capa;
cfg.highlight = 'on';
cfg.highlightchannel = find(stat_agg_nogo.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, grandavg_high_agg_go, grandavg_low_agg_go)
title('Nonparametric: significant without multiple comparison correction')

cfg = [];
cfg.highlightsymbolseries = ['*','*','.','.','.'];
cfg.layout = layout_capa;
cfg.contournum = 0;
cfg.markersymbol = '.'; 
cfg.alpha = 0.25;
cfg.parameter= 'stat';
cfg.zlim = [-10 10];
ft_clusterplot(cfg, stat_agg_go);
