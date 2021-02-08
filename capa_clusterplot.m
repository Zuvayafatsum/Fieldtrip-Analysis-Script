%% An alternative for ft_clusterplot for plotting with desired time intervals

load('capa_layout');
load('capa_neighbour');
cfg = []; 
cfg.parameter = 'avg'; 
cfg.operation =  '(x1-x2)'; 
raw_effect = ft_math(cfg,number_grandavg,baseline_grandavg); % !!!
cluster_interval = cluster_time_interval(stat_base_number_300_450,512,0.05); % !!!
Fs = 512;
stat = stat_base_number_300_450; % !!!

topography_interval =30; 
for k = 1:size(cluster_interval.neg,1); 
    if cluster_interval.neg(k,3) < 0.05;
N_of_topoplots = round((cluster_interval.neg(k,2) - cluster_interval.neg(k,1))/topography_interval);
time_steps = linspace(cluster_interval.neg(k,1),cluster_interval.neg(k,2),N_of_topoplots);

for i = 1:(N_of_topoplots-1);
    a = round((N_of_topoplots-1)/2);
    if a >= 6
        figure(k)
    subplot(round(a/2),4,i)  
    cfg = []; 
cfg.layout = capa_layout; 
cfg.xlim = [time_steps(i)/1000 time_steps(i+1)/1000];
cfg.highlight = 'on'; 
channel_indices = zeros(1,32);
for j = 1:32; 
   if sum(stat.negclusterslabelmat(j,(round((time_steps(i) - (stat.cfg.latency(1)*1000))*Fs /1000)):((round((time_steps(i+1) - (stat.cfg.latency(1)*1000))*Fs /1000))))) >= 1;
       channel_indices(j) = 1;
   else
       channel_indices(j) = 0;
   end
end
channels_to_be_highlighted = find(channel_indices == 1);
cfg.highlightchannel = channels_to_be_highlighted;
cfg.highlightcolor     = [1 1 1];
   cfg.highlightsize      = 8;
ft_topoplotER(cfg,raw_effect)

    else
        figure(k)
         subplot(a,3,i)  
cfg = []; 
cfg.layout = capa_layout; 
cfg.xlim = [time_steps(i)/1000 time_steps(i+1)/1000];
cfg.highlight = 'on'; 
channel_indices = zeros(1,32);
for j = 1:32; 
   if sum(stat.negclusterslabelmat(j,(round((time_steps(i) - (stat.cfg.latency(1)*1000))*Fs /1000)):((round((time_steps(i+1) - (stat.cfg.latency(1)*1000))*Fs /1000))))) >= 1;
       channel_indices(j) = 1;
   else
       channel_indices(j) = 0;
   end
end
channels_to_be_highlighted = find(channel_indices == 1);
cfg.highlightcolor     = [1 1 1];
   cfg.highlightsize      = 8;
cfg.highlightchannel = channels_to_be_highlighted;

ft_topoplotER(cfg,raw_effect)

    end
    sgtitle(sprintf('Topographies of %d. negative cluster',k))
end
    else
        fprintf('No significant clusters to be plotted for the %d. negative cluster',k);
    end
end

cfg = []; 
cfg.layout = capa_layout; 
cfg.xlim = [0.2 1.3];

ft_multiplotER(cfg,kisa_gavg,uzun_gavg)
