%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%               Loading and Linearizing Position Data                 %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Walkthrough/tutorial workflow

% FUNCTIONS
% LoadPos()
% getd()
% PosCon()
% MakeCoord()
% LinearizePos()

% SECTIONS:
% Loading and Plotting Position Data
% Getting Position Data Conversion Factors
% Making Coords
% Getting Choice Points Manually
% Linearizing Position Data

% BACKGROUND

% Position data is collected by an overhead camera and position tracking 
% algorithm as it views the bright, point source of light emitted by the 
% headstage LEDs. This position data is saved in the Neuralynx .nvt file.

% In the vandermeerlab codebase, position data is loaded using the function
% LoadPos(), and the x and y coordinate positions are accessed using the
% function getd().

% In analyses involving the use of trajectories, it is necessary to store
% the idealized path a rat would take along the track. These idealized
% paths, or coords, are saved for later use in scripts that order place 
% cells based on their field positions on the track.

% This workflow takes you through position data loading and linearizing
% using the example session R050-2014-04-02 recorded in RR1 at UW. R050's
% maze is T-shaped and has one choice point. The end of the left arm has a
% food reward and the end of the right arm has a water reward.

% A.Carey, Feb 2015

%% Current Directory

clear

% set your current directory to the session you want to work with:

datafolder = 'X:\01.Experiments\John n Andrew\Dual optogenetics w mPFC recordings\All Subjects - DNMP\Good performance\Medial Prefrontal Cortex\Baby Groot 9-11-18'; 

cd(datafolder) 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%              Loading and Plotting Position Data                     %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\shared\io')
%addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\toolboxes\MClust-4.3\MClust\Utilities')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\shared\io\neuralynx')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\shared\datatypes\tsd')
%addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\toolboxes\MClust-4.3\MClust\Utilities\@tsd')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\shared\util')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\shared\datatypes\iv')
addpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\shared\linearize')


% load data
load('Int_file.mat')
load('VT1.mat')

% interp missing data
[ExtractedX,ExtractedY] = correct_tracking_errors(datafolder);   

% define the position variable
pos(1,:) = ExtractedX;
pos(2,:) = ExtractedY;

%% plot the position data

% position data is accessed using the function getd()
% if you want the x data points, x = getd(pos,'x');

figure; plot(pos(1,:),pos(2,:),'.','Color',[0.7 0.7 0.7],'MarkerSize',4); xlabel('x data'); ylabel('y data');

% In reality, R050's maze was oriented such that the top of the T points up. Notice
% here that the T-maze is actually upside down! This is because the camera
% mirrors the data in the Y axis.

% We can set certain axis properties so that the position data is
% plotted in the orientation we want to see it, but at the same time
% preserve the real data points and their relationships to one another:

%% You can also rotate the maze:

figure; plot(pos(1,:),pos(2,:),'.','Color',[0.7 0.7 0.7],'MarkerSize',4); xlabel('x data'); ylabel('y data');
set(gca,'YDir','reverse') % this flips the Y axis
view(270,90); % the number 270 rotates the plot 270 degrees CLOCKWISE
title('Figure rotated AND flipped')

% Note that you can also perform this flip rotation by plotting (y,x), but
% this also transposes the data and works only for mazes that are bilaterally 
% symmetrical in the y axis (I think >_<). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%     The above plotting examples are important for the next steps,   %%%
%%%     when making coords properly and getting the outer               %%%
%%%     boundaries of your track                                        %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%           Getting Position Data Conversion Factors                  %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BACKGROUND INFORMATION

% You might need to load position data in centimeters instead of in units
% of pixels.

% Do do this, you need the real dimensions of your track in cm but these 
% dimensions must be as if the track fits perfectly into a box that has the 
% same orientation as the camera's field of view (the box has to be orthogonal 
% to the field of view, or whatever word it is). See digrams below.

% Furthermore, the dimesions should be measured according to the trajectory
% the rat would have followed, ie: don't measure from one outer edge to the
% opposite outer edge, because the rat doesn't walk along the edge -- he
% walks along the center (unless he's an acrobat or weird).

% rhombus track ex: you don't want lengths a and b, you want x and y 

%    |.... x ....| 
%  _ _ _ _ _ _ _ _ _ 
% |                  |
% |        .         |  _
% |      .   .  a    |  .
% |    .       .     |  .
% |  .           .   |  y 
% |    .       .     |  .
% |      .   .  b    |  .
% |        .         |  _
% |                  |
% |_ _ _ _ _ _ _ _ _ |
%   field of view

% R050's T-maze is already approx lined up with the camera's field of view, so x = a and y = b
%     |.....x......|
%  _ _ _ _ _ _ _ _ _ _ 
% |         a          |
% |    ____________    | _             
% |   |     |      |   | .
% |   |     |      |   | .
% |   |     |      |   | y
% |         | b        | .  
% |         |          | .
% |         |          | _
% |_ _ _ _ _ _ _ _ _ _ |

% The dimensions should be saved in your ExpKeys as:
%           ExpKeys.realTrackDims = [xWidth yWidth];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%                    Making a Coord File                              %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open the function MakeCoord() and read its internal documentation for
% more information

% let's get the idealized trajectories; MakeCoord() takes varargins that can
% reorient your maze as you prefer to see it. If you recorded in RR1 you
% should always flip the Y axis unless LoadPos() is changed to do load the
% Y data differently

coordL = MakeCoord(pos(1,:),pos(2,:),'titl','Draw left trajectory, press enter when done','XDir','reverse');
coordR = MakeCoord(pos(1,:),pos(2,:),'titl','Draw right trajectory, press enter when done','XDir','reverse');

% these coords should be converted to units of cm using the convFact you already
% collected above:
convFact(1) = 2.09; convFact(2) = 2.04;

coordL_cm = coordL; % copy coordL under a new variable name, and apply some changes:
coordL_cm(1,:) = coordL_cm(1,:)./convFact(1); % apply x conversion
coordL_cm(2,:) = coordL_cm(2,:)./convFact(2); % apply y conversion

coordR_cm = coordR; % as above, for R instead
coordR_cm(1,:) = coordR_cm(1,:)./convFact(1); % apply x conversion
coordR_cm(2,:) = coordR_cm(2,:)./convFact(2); % apply y conversion

% put it all in a struct for tighter packing in the base workspace (when loading variables later)
coord = struct('coordL',coordL,'coordL_cm',coordL_cm,'coordR',coordR,'coordR_cm',coordR_cm);

clear coordL coordL_cm coordR coordR_cm

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%                   Getting Choice Points Manually                    %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If your maze has any choice points, it's probably a good idea to get the
% coordinates of those choice points. Here's how you can do this using a
% script:

%figure; plot(getd(pos,'x'),getd(pos,'y'),'.','Color',[0.7 0.7 0.7],'MarkerSize',4); set(gca,'YDir','reverse'); hold on;

figure; plot(pos(1,:),pos(2,:),'.','Color',[0.7 0.7 0.7],'MarkerSize',4); set(gca,'XDir','reverse'); hold on;
plot(coord.coordL(1,:),coord.coordL(2,:),'ob'); plot(coord.coordR(1,:),coord.coordR(2,:),'og'); title('Click choice point; press enter');
maximize

% get user input:
[x,y] = ginput;

plot(x,y,'or','MarkerSize',10,'LineWidth',4); pause(1); close

% convert choice point units

chp = [x; y];
chp_cm = [x/convFact(1); y/convFact(2)];

% add to coord
coord.chp = chp;
coord.chp_cm = chp_cm;

% coord can be saved as a metadata field, and metadata can be saved as a
% .mat file for later use

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%                     Linearizing Position Data                       %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here's a quick example of how to linearize the position data. You can
% think of linearizing as "pushing the position data onto the nearest point
% along the coord trajectory". 

% Normally you would have a separate script that defines the trial start
% and stop times; for the sake of this example, here are the trial
% intervals for all right trials that R050 did for the example session:

tstart = Int(Int(:,3)==0,1);
tend   = Int(Int(:,3)==0,8);

trial_iv_R = iv(tstart,tend);

clear tstart tend

%% Load position data in units of centimeters

% do do this, you need to specify conFact as a config field
cfg.convFact = convFact;

pos = LoadPos(cfg);


%% Now, restrict the position data to the right trials only:

pos_R = restrict(pos,trial_iv_R);

% You can plot the output to see what this looks like:
figure; plot(getd(pos_R,'x'),getd(pos_R,'y')); set(gca,'YDir','reverse')

% note that the lines connecting the end of the right arm to the start of
% the track are not actually present in the data...they are just artifacts
% of plotting.

%% Linearize the position data 
IntL = Int(find(Int(:,3)==1),:);
IntR = Int(find(Int(:,3)==0),:);

clear NN d xLeft yLeft TSleft
for i = 1:length(IntL)
    xLeft{i} = ExtractedX(TimeStamps_VT >= IntL(i,1) & TimeStamps_VT <= IntL(i,7));
    yLeft{i} = ExtractedY(TimeStamps_VT >= IntL(i,1) & TimeStamps_VT <= IntL(i,7));
    TSleft{i} = TimeStamps_VT(TimeStamps_VT >= IntL(i,1) & TimeStamps_VT <= IntL(i,7));
end
X = horzcat(xLeft{:});
Y = horzcat(yLeft{:});

% get coordinate points between ideal trajectory and real data
clear NN
NN = griddata(coord.coordL(1,:),coord.coordL(2,:),1:length(coord.coordL(1,:)),X,Y,'nearest');

% get distance
clear d
d = sqrt((coord.coordL(1,ceil(NN))-X).^2 + (coord.coordL(2,ceil(NN))-Y).^2);

% maybe now use NN, which is a nearest point index, to calculate the
% distance from stem entry, and bin data
% get binned data
% get spiking data binned
ci = 1;
clusters   = dir('TT*.txt');

clear spikeTimes numSpikes timeDiff firingRate
spikeTimes = textread(clusters(ci,:).name);

spks = spikeTimes(spikeTimes >= TSleft{triali}(1) & spikeTimes <= TSleft{triali}(end));

% shape of timestamp data
spkForm = NaN(size(TSleft{triali}));

% find nearest points
spkSearch = dsearchn(TSleft{triali}',spks);

% replace and create boolean spk data
spkForm(spkSearch) = 1;
spkForm(isnan(spkForm)==1)=0;

% make time vector
timeForm = repmat(1/30,size(TSleft{triali})); % seconds sampling rate

% 30 samples per sec means i can divide each indiivudal point by 30.
%clear binSpks binTime
for i = 1:max(NN{triali}) % loop across the number of bins
    binSpks{triali}{i} = spkForm(NN{triali} == i);
    binTime{triali}{i} = timeForm(NN{triali} == i);
end
    
% does removing empty arrays make the binning even?
%binSpks{triali} =  binSpks{triali}(~cellfun('isempty',binSpks{triali}));
%binTime{triali} =  binTime{triali}(~cellfun('isempty',binTime{triali}));

% calculate firing rate per bin
numSpks{triali} = cellfun(@sum,binSpks{triali});
sumTime{triali} = cellfun(@sum,binTime{triali});

% firing rate (spks/sec)
FR{triali} = numSpks{triali}./sumTime{triali};

% concatenate and smooth data
FRmat = vertcat(FR{:});
FRmat(find(isnan(FRmat)==1))=0;

% smooth
VidSrate = 30;
gauss_width = 60; 
gauss_timeWidth = gauss_width*(1/VidSrate); % this is in seconds
n = -(gauss_width-1)/2:(gauss_width-1)/2;
alpha       = 4; % std = (N)/(alpha*2) -> https://www.mathworks.com/help/signal/ref/gausswin.html
w           = gausswin(gauss_width,alpha);
stdev = (gauss_width-1)/(2*alpha);
y = exp(-1/2*(n/stdev).^2);
  
% convolve data with gaussian - remove a certain path to avoid mixing up
% functions
rmpath('X:\03. Lab Procedures and Protocols\MATLABToolbox\Andrew code\Github\nsb2015\code-matlab\shared\util')
clear smoothFR normFR
for i = 1:length(FR)
    % smooth data
    smoothFR(i,:) = conv(FRmat(i,:),w,'same');
    % normalize firing
    normFR(i,:) = normalize(smoothFR(i,:),'range');
end

figure('color','w');
subplot 211; hold on;
x_label = NN;
imagesc(x_label,flipud(flipud(1:size(normFR,1))')',normFR);
axis tight
shading 'interp';
c = colorbar;
%ylabel('Trial # in progressive order')
ylabel('Trial')
%xlabel('Norm. Distance')
ylabel(c,'Norm. FR')

% lets figure out where T-junction is
clear MarkTidx xMarkT yMarkT
for triali = 1:size(IntL,1)
    MarkTidx(triali) = find(TSleft{triali} == IntL(triali,5));
    
    linPosT(triali) = NN{i}(MarkTidx(triali));
end

% plot a line on the imagesc figure
ylimits = ylim;
l1 = line([linPosT],[linspace(ylimits(1),ylimits(2),length(linPosT))]);
l1.Color = 'r';
l1.LineStyle = '--';
l1.LineWidth = 2;

% pos_R_lin.data(1), the z (or linearized position data), is the same
% regardless of whether you load position data in centimeters or pixels.
% pos_R_lin.data(2), the z dist (or the amount the real position was
% displaced when it was pushed onto z) is different depending on the units
% you choose when loading pos.
