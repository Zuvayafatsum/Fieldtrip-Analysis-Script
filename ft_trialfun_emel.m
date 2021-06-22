function [trl, event] = ft_trialfun_example1(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "trigger" events
value = {event.value}';
sample = [event.sample]';
value_check = cellfun(@isempty,value);
for i = 1:length(value_check)
    if value_check(i)== 1
        value{i} = 'Bos';
    end
end
% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);

% for each trigger except the last one
trl = [];
for j = 1:(length(value)-1)
  trg1 = string(cell2mat(value(j)));
  trg2 = string(cell2mat(value(j+1)));
  if trg1 == cfg.ilk_stim && trg2 == cfg.ikinci_stim && (sample(j+1) - sample(j)) <= cfg.interval * hdr.Fs; 
    trlbegin = sample(j) + pretrig;       
    trlend   = sample(j) + posttrig;         
    offset   = pretrig;
    newtrl   = [trlbegin trlend offset];
    trl      = [trl; newtrl];
  end
end
end
