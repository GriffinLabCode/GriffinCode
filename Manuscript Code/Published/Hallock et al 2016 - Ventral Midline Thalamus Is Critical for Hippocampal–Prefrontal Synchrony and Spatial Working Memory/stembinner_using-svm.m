

ntrials = size(Int,1);

% Convert timestamp values into seconds
%spksec = spk/1e6;
%intsec = Int/1e6;

% STM_fld = [310 200 45 175];

xmin = 230; %   Manually define stem entry and stem exit coordinates
xmax = 530;
ymax = 280;
ymin = 220;

numbins = 7;    %   Right now, this code is hard set to six stem bins (7-1 = 6). The number of stem bins could be made flexible - however, this would take some tinkering

bins = linspace(xmin,xmax,numbins);
bins = round(bins);

%for i = 1:ntrials
%    spk_new = find(spksec>intsec(i,1) & spksec<intsec(i,5));
%    time_spent = (intsec(i,5)) - (intsec(i,1));
%    nspikes = length(spk_new);
%    fr_stem(i) = nspikes/time_spent;
%end

for i = 1:2:size(Int)
    ts_ind = find(TimeStamps>Int(i,1) & TimeStamps<Int(i,5));
    ts_temp = TimeStamps(ts_ind);
    x_temp = ExtractedX(ts_ind); % x_pos when in ts_indx
    x_temp = x_temp';
    bins = bins';
    k = dsearchn(x_temp,bins); % what valules for each bin
    bins = bins';
    x_temp = x_temp';
    spk_ts = ts_temp(k); % one spk per bin???
for j = 1:length(bins)-1
    numspikes_ind = find(spikeTimes>spk_ts(j) & spikeTimes<spk_ts(j+1)); % made this TT4_SS_15
    numspikes = length(numspikes_ind);
    time_temp = spk_ts(j+1) - spk_ts(j);
    time_temp = time_temp/1e6;
    fr_temp(j) = numspikes/time_temp; % got NaN 
end
fr_new(i-1,1:size(fr_temp,2)) = fr_temp;
   end 
