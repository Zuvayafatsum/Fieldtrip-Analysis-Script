% stat = %NAME OF THE OUTPUT STAT FOLDER YOU HAVE
function [output] = cluster_time_interval(stat,Fs,alpha)
neg_existence = isfield(stat,'negclusters');
pos_existence = isfield(stat,'posclusters');
output = {};
if neg_existence == 1 
negNofclusters = length(stat.negclusters);
else 
    negNofclusters = 0;
end

if negNofclusters >= 1
    negcluster_time_intervals = zeros(negNofclusters,2);
    for i = 1:negNofclusters
        if stat.negclusters(i).prob < alpha
        [channelN timepoint] = find(stat.negclusterslabelmat == i);
negcluster_time_intervals(i,1) = (min(timepoint)*(1/Fs*(1000)))+ stat.cfg.latency(1)*1000;
negcluster_time_intervals(i,2) = (max(timepoint)*(1/Fs*(1000)))+ stat.cfg.latency(1)*1000;
negcluster_time_intervals(i,3) = stat.negclusters(i).prob;
        else 
            negcluster_time_intervals(i,1) = nan;
            negcluster_time_intervals(i,2) = nan;
            negcluster_time_intervals(i,3) = nan;
        end
    end
else
    negcluster_time_intervals = nan;
end
output.neg = negcluster_time_intervals;
if pos_existence == 1
posNofclusters = length(stat.posclusters);
else 
   posNofclusters = 0; 
end
if posNofclusters >= 1
    poscluster_time_intervals = zeros(posNofclusters,2);
    for i = 1:posNofclusters 
        if stat.posclusters(i).prob < alpha
        [channelN timepoint] = find(stat.posclusterslabelmat == i);
poscluster_time_intervals(i,1) = (min(timepoint)*(1/Fs*(1000)))+ stat.cfg.latency(1)*1000;
poscluster_time_intervals(i,2) = (max(timepoint)*(1/Fs*(1000)))+ stat.cfg.latency(1)*1000;
poscluster_time_intervals(i,3) = stat.posclusters(i).prob;
        else 
            poscluster_time_intervals(i,1) = nan;
            poscluster_time_intervals(i,2) = nan;
            poscluster_time_intervals(i,3) =nan;
        end
    end
else
       poscluster_time_intervals = nan;


end
       output.pos = poscluster_time_intervals;

end