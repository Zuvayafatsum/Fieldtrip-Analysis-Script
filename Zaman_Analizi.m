%% Veriyi okutma, triallarý define etme ve epoklanmýþ halini diske yazdýrma
ft_defaults
load('capa_layout');
load ('capa_neighbour');
subject_names = {'ahmet' 'aslý' 'asude'  'ayla' 'basak' 'berkant' 'bernis' 'beyhan' 'busra' 'cigdem' ...
    'deniz' 'elif' 'emine' 'enes'  'eray' 'erdem' 'fatih' 'filiz' 'furkan' 'ipek' 'irem' ...
    'mustafa' 'omer' 'ozkan'  'rukiye' 'samet' 'seckin' 'seda' 'selin' 'serdar' 'sevcan' ...
    'sumeyra' 'zeynep' };
conditions = {'S2' 'S4' 'S6'};
stimuli_list = {'S  2' 'S  4' 'S  6'};
path = 'D:\Program Files\MATLAB\Mehmet_Aygunes\';
epoched_data = {};
for i = 1:length(subject_names);
    for k=1:length(conditions)
cfg = []; 
cfg.dataset         = [path subject_names{i} '_deney3_part1_new_' conditions{k} '_seg.vhdr']; 
cfg.trialdef.prestim = 2.5; 
cfg.trialdef.poststim = 2.5;
cfg.trialdef.eventtype = 'Stimulus' ;
cfg.trialdef.eventvalue = stimuli_list{k};

cfg = ft_definetrial(cfg);
switch k
            case 1
            epoched_data(i).baseline = ft_preprocessing (cfg); % Read in the trials definded above
            case 2
            epoched_data(i).person = ft_preprocessing (cfg); % Read in the trials definded above
            case 3
            epoched_data(i).number = ft_preprocessing (cfg); % Read in the trials definded above    
end
    end    
end
clear i k conditions path stimuli_list subject_names cfg

save epoched_data epoched_data
%% Condition spesifik subject level ortalama alma
% ft_selectdata  
for i = 1:length(epoched_data);
cfg = []; 
    baseline_tlock{i} = ft_timelockanalysis(cfg,epoched_data(i).baseline);
end

for i = 1:length(epoched_data);
    cfg = []; 
    person_tlock{i} = ft_timelockanalysis(cfg,epoched_data(i).person);
end

for i = 1:length(epoched_data);
    cfg = []; 
    number_tlock{i} = ft_timelockanalysis(cfg,epoched_data(i).number);
end
clear i cfg
%% Visualize timelocked subject level data
n = 1;  %arbitrary number to visualize subject of interest
cfg = []; 
cfg.layout = capa_layout; 
cfg.xlim = [-0.5 1.5]; 
ft_multiplotER(cfg,baseline_tlock{n},person_tlock{n},number_tlock{n})
%% Preprocessing of timelocked averaged data
cfg = [] ; 
cfg.lpfilter = 'yes'; 
cfg.lpfreq = [15]; 
% cfg.preproc.hpfilter ='yes';
% cfg.preproc.hpfreq = 1;
% cfg.detrend = 'yes';
% cfg.hpfilter = 'yes';
% cfg.hpfreq = [1];
for i = 1:length(baseline_tlock);

    baseline_tlock_filtered{i} = ft_preprocessing(cfg,baseline_tlock{i});
end
for i = 1:length(person_tlock);
    person_tlock_filtered{i} = ft_preprocessing(cfg,person_tlock{i});
end
for i = 1:length(number_tlock);
    number_tlock_filtered{i} = ft_preprocessing(cfg,number_tlock{i});
end
%% baseline correction AFTER filtering
cfg = []; 
cfg.parameter = 'avg';
cfg.baseline = [-0.2 0]; 
for i = 1:length(baseline_tlock_filtered);
    baseline_tlock_bc{i} = ft_timelockbaseline(cfg,baseline_tlock_filtered{i});
end

for i = 1:length(person_tlock_filtered);
    person_tlock_bc{i} = ft_timelockbaseline(cfg,person_tlock_filtered{i});
end

for i = 1:length(number_tlock_filtered);
    number_tlock_bc{i} = ft_timelockbaseline(cfg,number_tlock_filtered{i});
end
save  baseline_tlock_bc  baseline_tlock_bc
save person_tlock_bc person_tlock_bc
save  number_tlock_bc  number_tlock_bc
%% Visualize preprocessed data
n = 2;  %arbitrary number to visualize subject of interest
cfg = []; 
cfg.layout = capa_layout; 
cfg.xlim = [-0.2 1.3]; 
ft_multiplotER(cfg,baseline_tlock_bc{n},person_tlock_bc{n},number_tlock_bc{n})
%baþka bir preprocessing iþlemi yapýlmayacak ise; istatistiðe burada oluþturulan
%datalar gireceði için dikkatli incelenmeliler!!!
%analiz basamaklarýný tekrarlamamak adýna, bu kýsýmda emin olduktan sonra
%varolan datalar ve elde edilecek grandaveragelar save edilebilir.
%(.mat formatýnda)
%% Grandaveraging
cfg = [];
    baseline_grandavg = ft_timelockgrandaverage(cfg,baseline_tlock_bc{:});
    person_grandavg = ft_timelockgrandaverage(cfg,person_tlock_bc{:});
    number_grandavg = ft_timelockgrandaverage(cfg,number_tlock_bc{:});
save baseline_grandavg baseline_grandavg
save person_grandavg person_grandavg
save number_grandavg number_grandavg
%% Visualization of grandaverages 

cfg = []; 
cfg.layout = capa_layout; 
cfg.xlim = [-0.2 1]; 
ft_multiplotER(cfg,baseline_grandavg,person_grandavg,number_grandavg)
hold on
axis on

cfg = []; 
cfg.xlim =[0.3 0.5]; 
cfg.zlim = [-1.5 4];
cfg.layout = capa_layout; 
figure(1)
ft_topoplotER(cfg,baseline_grandavg)

figure(2)
ft_topoplotER(cfg,person_grandavg)

figure(3)
ft_topoplotER(cfg,number_grandavg)


cfg =[];
cfg.layout = capa_layout; 
ft_neighbourplot(cfg)
%% Statistical analysis 
n_of_subjects = 33;
n_of_conditions = 3;
design = zeros(2,n_of_subjects*n_of_conditions);
design(1,1:n_of_subjects) = 1;
design(1,(n_of_subjects+1):2*n_of_subjects) = 2;
design(1,2*n_of_subjects+1:3*n_of_subjects) = 3;   
design(2,1:n_of_subjects) = 1:n_of_subjects ; 
design(2,(n_of_subjects+1):2*n_of_subjects) = 1:n_of_subjects;
design(2,2*n_of_subjects+1:3*n_of_subjects) = 1:n_of_subjects; 

stat_F_test = {};
cfg                     = [];
cfg.channel             = 'all';
cfg.parameter           = 'avg';
cfg.method              = 'montecarlo';            
cfg.numrandomization    = 1000;                      %can be 'all' in case of two conditions; or a number like 500 or 1000 (is recommended, but takes longer)
cfg.tail                = 0;                       
cfg.correcttail         = 'prob';                  
cfg.alpha               = 0.05;  
cfg.latency             = [0.2 0.8];                 
cfg.statistic           = 'depsamplesFmultivariate';          
cfg.correctm            = 'cluster';               
cfg.clustertail         = 0;
cfg.clusteralpha        = 0.05;                                                                 
cfg.clusterstatistic    = 'maxsum';                 
cfg.clusterthreshold    = 'nonparametric_common';                                                                                                   
cfg.neighbours          = capa_neighbour;                
cfg.minnbchan           = 2; 
cfg.design = design;
cfg.ivar = 1; 
cfg.uvar = 2;
stat_F_test = ft_timelockstatistics(cfg,person_tlock_bc{:},number_tlock_bc{:},baseline_tlock_bc{:});    

%% Post-hoc 300-450
% Baseline vs Person
stat_person_base_300_450 = [];
cfg = [];
cfg.layout = capa_layout;
cfg.neighbours  = capa_neighbour; % defined as above
cfg.latency     = [0.3 0.45];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.correcttail = 'prob';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.tail             = 0;
cfg.numrandomization = 1000; 
cfg.minnbchan        = 2;
cfg.clusterstatistic = 'maxsum';
design = zeros(2,66);
design(1,1:33) = 1;
design(1,34:66) = 2;
design(2,1:33) = 1:33;
design(2,34:66) = 1:33;
% design = [1 2];
cfg.design = design;             % design matrix
cfg.ivar  = 1;  
cfg.uvar = 2;
stat_person_base_300_450  = ft_timelockstatistics(cfg,baseline_tlock_bc{:},person_tlock_bc{:}); 

% Baselin vs Number
stat_number_base_300_450 = [];
cfg = [];
cfg.layout = capa_layout;
cfg.neighbours  = capa_neighbour; % defined as above
cfg.latency     = [0.3 0.45];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.correcttail = 'prob';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.tail             = 0;
cfg.numrandomization = 1000; 
cfg.minnbchan        = 2;
cfg.clusterstatistic = 'maxsum';
design = zeros(2,66);
design(1,1:33) = 1;
design(1,34:66) = 2;
design(2,1:33) = 1:33;
design(2,34:66) = 1:33;
% design = [1 2];
cfg.design = design;             % design matrix
cfg.ivar  = 1;  
cfg.uvar = 2;
stat_base_number_300_450  = ft_timelockstatistics(cfg,number_tlock_bc{:},baseline_tlock_bc{:}); 

%Person vs Number
stat_number_person_300_450 = [];
cfg = [];
cfg.layout = capa_layout;
cfg.neighbours  = capa_neighbour; % defined as above
cfg.latency     = [0.3 0.45];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.correcttail = 'prob';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.tail             = 0;
cfg.numrandomization = 1000; 
cfg.minnbchan        = 2;
cfg.clusterstatistic = 'maxsum';
design = zeros(2,66);
design(1,1:33) = 1;
design(1,34:66) = 2;
design(2,1:33) = 1:33;
design(2,34:66) = 1:33;
% design = [1 2];
cfg.design = design;             % design matrix
cfg.ivar  = 1;  
cfg.uvar = 2;
stat_person_number_300_450  = ft_timelockstatistics(cfg,number_tlock_bc{:},person_tlock_bc{:}); 

%% Post-hoc 600_780
% Baselin vc Person
stat_base_person_600_780 = [];
cfg = [];
cfg.layout = capa_layout;
cfg.neighbours  = capa_neighbour; % defined as above
cfg.latency     = [0.6 0.78];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.correcttail = 'prob';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.tail             = 0;
cfg.numrandomization = 1000; 
cfg.minnbchan        = 2;
cfg.clusterstatistic = 'maxsum';
design = zeros(2,66);
design(1,1:33) = 1;
design(1,34:66) = 2;
design(2,1:33) = 1:33;
design(2,34:66) = 1:33;
% design = [1 2];
cfg.design = design;             % design matrix
cfg.ivar  = 1;  
cfg.uvar = 2;
stat_base_person_600_780  = ft_timelockstatistics(cfg,baseline_tlock_bc{:},person_tlock_bc{:}); 

% Baselin vs Number
stat_base_number_600_780 = [];
cfg = [];
cfg.layout = capa_layout;
cfg.neighbours  = capa_neighbour; % defined as above
cfg.latency     = [0.6 0.78];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.correcttail = 'prob';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.tail             = 0;
cfg.numrandomization = 1000; 
cfg.minnbchan        = 2;
cfg.clusterstatistic = 'maxsum';
design = zeros(2,66);
design(1,1:33) = 1;
design(1,34:66) = 2;
design(2,1:33) = 1:33;
design(2,34:66) = 1:33;
% design = [1 2];
cfg.design = design;             % design matrix
cfg.ivar  = 1;  
cfg.uvar = 2;
stat_base_number_600_780  = ft_timelockstatistics(cfg,baseline_tlock_bc{:},number_tlock_bc{:}); 

%Person vs Number
stat_number_person_600_780 = [];
cfg = [];
cfg.layout = capa_layout;
cfg.neighbours  = capa_neighbour; % defined as above
cfg.latency     = [0.6 0.78];
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.correcttail = 'prob';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.tail             = -1;
cfg.numrandomization = 1000; 
cfg.minnbchan        = 2;
cfg.clusterstatistic = 'maxsum';
design = zeros(2,66);
design(1,1:33) = 1;
design(1,34:66) = 2;
design(2,1:33) = 1:33;
design(2,34:66) = 1:33;
% design = [1 2];
cfg.design = design;             % design matrix
cfg.ivar  = 1;  
cfg.uvar = 2;
stat_person_number_600_780  = ft_timelockstatistics(cfg,number_tlock_bc{:},person_tlock_bc{:}); 

