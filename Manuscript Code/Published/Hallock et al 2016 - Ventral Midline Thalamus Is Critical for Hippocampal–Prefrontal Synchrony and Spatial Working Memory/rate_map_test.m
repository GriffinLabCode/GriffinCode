
function [filtered_map, rate_map, binned_pos, binned_spike] = rate_map(ExtractedX, ExtractedY, TimeStamps, spk, Int, bin, sigma, plot)

TT4_SS_15 = spk;

% select
bin = 200;
sigma = 5;
plot = 0;

Int_sample = Int(1:2:end,:);
Int_choice = Int(2:2:end,:);

for i = 1:size(Int_sample);
   
    index_start = Int_sample((i-1),1);
    index_finish = Int_sample ((i),1);
    
    pos_start = dsearchn (TimeStamps', index_start);
    pos_finish = dsearchn (TimeStamps', index_finish);
    
    % quantity of data points can vary between trials
    pos_data = [];
    pos_data (1,:) = ExtractedX (1, pos_start : pos_finish);
    pos_data (2,:) = ExtractedY (1, pos_start : pos_finish);
    
    pos_cell {i} = pos_data';
    
    ts_cell {i} = TimeStamps (pos_start:pos_finish)';
    
    spk_index = find(spk > index_start & spk < index_finish);
    spk_new = spk(spk_index);
    spk_cell {i} = spk_new;
    
end

pos_cell_new = vertcat(pos_cell {:});
ts_cell_new = vertcat (ts_cell {:});
spk_cell_new = vertcat (spk_cell {:});
     
[binned_pos,C] = hist3(pos_cell_new,[200 200]);
binned_pos = hist3(pos_cell_new,'Ctrs',C);
binned_pos = binned_pos/30;

for spikei = 1:length(spk_cell_new)
    spk_ts = dsearchn(ts_cell_new',spk_cell_new(spikei,1));
    spk_x(spikei,1) = pos_cell_new(spk_ts,1);
    spk_x(spikei,2) = pos_cell_new(spk_ts,2);
end

binned_spike = hist3(spk_x,'Ctrs',C);

rate_map = binned_spike ./ binned_pos;

rate_map(1,1) = NaN;
rate_map_raw = rate_map;

rate_map(isnan(rate_map)) = 0;

[X,Y] = meshgrid(round(-bin/2):round(bin/2), round(-bin/2):round(bin/2));
f = exp(-X.^2/(2*sigma^2)-Y.^2/(2*sigma^2));
f = f./sum(f(:));

filtered_map = conv2(rate_map,f,'same');

for i = 1:size(filtered_map,1);
    for k = 1:size(filtered_map,2);
        if isnan(rate_map_raw(i,k))
            filtered_map(i,k) = NaN;
        end
    end
end
            
[nr,nc] = size(filtered_map);

if plot == 0
figure()
pcolor([filtered_map nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
colormap(jet)
box off
set(gca,'TickDir','out')
xlabel('X-Coordinate')
ylabel('Y-Coordinate')
end




    
    