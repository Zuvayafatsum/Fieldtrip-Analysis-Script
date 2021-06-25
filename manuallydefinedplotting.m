%% Plotting Topography of Significant clusters with predefined time intervals (an alternative to ft_clusterplot)

function capa_clusterplot = acaba(stat,grandavg1,grandavg2,Fs,alpha,topography_interval);
load('capa_layout');
load('capa_neighbour');
cfg = []; 
cfg.parameter = 'avg'; 
cfg.operation =  '(x1-x2)'; 
raw_effect = ft_math(cfg,grandavg1,grandavg2);
denemeplotting = deneme_interval(stat,Fs,alpha);
neg_existence = isfield(denemeplotting,'neg');
pos_existence = isfield(denemeplotting,'pos');


if pos_existence ==1  &&  neg_existence ==1
    
%for positive clusters
    if isempty(denemeplotting.pos) == 0; 
for k = 1:size(denemeplotting.pos,1); 
     if denemeplotting.pos(k,3) < 0.05;
N_of_topoplots = round((denemeplotting.pos(k,2) - denemeplotting.pos(k,1))/topography_interval);
time_steps = linspace(denemeplotting.pos(k,1),denemeplotting.pos(k,2),N_of_topoplots);

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
   if sum(stat.posclusterslabelmat(j,(round((time_steps(i) - (stat.cfg.latency(1)*1000))*Fs /1000)):((round((time_steps(i+1) - (stat.cfg.latency(1)*1000))*Fs /1000))))) >= 1;
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
   if sum(stat.posclusterslabelmat(j,(round((time_steps(i) - (stat.cfg.latency(1)*1000))*Fs /1000)):((round((time_steps(i+1) - (stat.cfg.latency(1)*1000))*Fs /1000))))) >= 1;
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
    sgtitle(sprintf('Topographies of %d. positive cluster',k))
end
else
        fprintf('No significant clusters to be plotted for the %d. positive cluster',k)
     end
end
    end


% 
%  %%% Negative
if isempty(denemeplotting.neg) == 0;
for k = 1:size(denemeplotting.neg,1); 
        if denemeplotting.neg(k,3) < 0.05;
   
N_of_topoplots = round((denemeplotting.neg(k,2) - denemeplotting.neg(k,1))/topography_interval);
time_steps = linspace(denemeplotting.neg(k,1),denemeplotting.neg(k,2),N_of_topoplots);

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
        fprintf('No significant clusters to be plotted for the %d. negative cluster',k)
    end
end
end
    else
    fprintf('No significant clusters to be plotted')
end

end

