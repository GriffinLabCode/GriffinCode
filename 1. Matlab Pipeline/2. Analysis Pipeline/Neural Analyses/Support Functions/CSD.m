function [CSDoutput]  = CSD(data,SR,spacing,varargin);
    % Detemines the 1-dimensional (in space) current source density (CSD) 
    % for a set of voltage traces obtained from a linear array of 
    % electrodes of equal spacing. The CSD can be obtained using the 
    % standard CSD method (Nicholson & Freeman, 1975, J Neurophysiol,
    % 38(2): 356-68) or the inverse (delta) CSD method (Petterson et al.,
    % 2006, J Neurosci Methods, 154(1-2):116-33).
    
    % Function inputs (required)
    
    %   1) data: input data where columns contain temporal data and rows
    %      contain spatial data (i.e each column is a voltage trace from a
    %      single electrode). The data must be in volts.
    %   2) SR: sampling rate of the input data, in Hz.
    %   3) spacing: this is the spacing between two adjacent electrodes.     
    %      Must be in meters. 
    
    % Function inputs (optional: name-value pair arguments)
    
    %   1) 'conductivity': the conductivity of the extracellular medium, in 
    %      siemans per meter. Default is 0.3 S.m^-1.
    %   2) 'unitsCurrent': specifies the units of current for the CSD 
    %      output. Options are 'A', 'mA', 'uA', 'nA' and 'pA' for amps,
    %      milliamps, microamps, nanoamps and picoamps respectively.
    %      Default is microamps (uA).
    %   3) 'unitsLength': specifies the units of length for the CSD output.
    %      Options are 'cm', 'mm', 'um' and 'nm' for centimeters,
    %      millimeters, micrometers and nanometers respectively. Default
    %      is millimeters. 
    %   4) 'inverse': obtains the CSD using the inverse CSD method. This
    %      option requires the radius (surrounding each electrode 
    %      contact) in which the CSD is considered to be restricted to. 
    %      Frequently taken as the radius of the electrode or a multiple
    %      (e.g. 5) of the electrode spacing. 
    
    % Function outputs (CSDoutput)
    
    % The output of the function consists of the current source density in
    % amps.meters^-3. Default units are microamps.millimeters^-3. The CSD
    % data is in the same format as the input voltage data (temporal data 
    % in columns; spatial data in rows). When using the standard CSD
    % method, the first and last columns (consisting of data from the 1st 
    % and last electrodes) will be filled with NaNs. This is due to the
    % standard CSD method unable to obtain the CSD at these outermost 
    % electrode contacts. The inverse CSD method does not have this 
    % limitation.
    
    % Example inputs
    
    %   1) CSDoutput = CSD(data,10000,1E-4);
    %           Determines the CSD using the standard CSD method. Input
    %           data has a sampling rate of 10 kHz. Spacing between two
    %           adjacent electrodes is 100 micrometers. 
    %   2) CSDoutput = CSD(data,10000,1E-4,'unitsCurrent','mA' ...
    %      'unitsLength','cm');
    %           Same as above (example input 1) with the exception that the
    %           CSD output units is now in milliamp.centimeter^-3. 
    %   3) CSDoutput = CSD(data,25000,1E-4,'inverse',5E-4);
    %           Determines the CSD using the inverse CSD method. Input
    %           data has a sampling rate of 25 kHz. Spacing between
    %           two electrode contacts is 100 micrometers. The radius 
    %           (required for the inverse method) is 500 micrometers.
    
    %%%%%%%%% Function %%%%%%%%%
    % Input parser section 
    disp('Code written by Timothy Olsen')
    
    p = inputParser; 
    addRequired(p,'data',@isnumeric); % required function input
    addRequired(p,'SR',@isnumeric); % required function input
    addRequired(p,'spacing',@isnumeric); % required function input
    addParamValue(p,'conductivity',0.3,@isnumeric); % varargin input  
    checkStrCur = @(s) any(strcmp(s,{'A','mA','uA','nA','pA'}));
    addParamValue(p,'unitsCurrent','uA',checkStrCur); % varargin input   
    checkStrLen = @(st) any(strcmp(st,{'cm','mm','um','nm'}));
    addParamValue(p,'unitsLength','mm',checkStrLen); % varargin input
    addParamValue(p,'inverse',@isnumeric); % varargin input  
    parse(p,data,SR,spacing,varargin{:});
    data  = p.Results.data;
    SR  = p.Results.SR;
    spacing  = p.Results.spacing;
    conductivity  = p.Results.conductivity;
    unitsCurrent = p.Results.unitsCurrent;
    unitsLength = p.Results.unitsLength;
    radius  = p.Results.inverse;
  
    % determines whether the inverse CSD method is called 
    if sum(strcmp('inverse',varargin)) == 1; 
        CSDtype = 0;
    else
        CSDtype = 1;
    end
    
    % Determines conA. Needed to convert CSD data to desired current units 
    if unitsCurrent=='A'; conA=1; elseif unitsCurrent=='mA'; conA=1000; ...
    elseif unitsCurrent=='uA'; conA=1000000; elseif unitsCurrent=='nA'; ...
    conA=1000000000; elseif unitsCurrent=='pA'; conA=1000000000000; end;
    % Determines conL. Needed to convert CSD data to desired length units 
    if unitsLength=='cm'; conL=100; elseif unitsLength=='mm'; conL=1000;...   
    elseif unitsLength=='um'; conL=1000000; elseif unitsLength=='nm'; ...
    conL=1000000000; end;
    SPm = (1/SR)*1000; % sampling period in ms      
    xAxis = [SPm:SPm:SPm*length(data)]'; % x-axis for plots
    
    % Plots the voltage on the far left subplot
    if CSDtype == 1; % plots the voltages for the standard CSD method 
        MmV = max(max(abs(data(:,2:end-1)))); % absolute maximum voltage
        yAxisM = MmV*(size(data,2)-2); % starting baseline for plots
        figure(1); % plots voltage data for the 2nd to 2nd last electrode
        subplot(1,3,1);          
        for j = 1:(size(data,2)-2);    
            plot(xAxis,data(:,j+1)+yAxisM,'k');
            yAxisMCol(1,j) = yAxisM;
            yAxisM = yAxisM-MmV; % moves baseline of plot down by MmV
            hold on
        end   
        % converts axis labels to electrode number
        g1 = get(gca,'YTickLabel');     
        yAxisMCol = flipud(yAxisMCol');
        set(gca,'Ytick',[yAxisMCol]);
        ax=gca; ExV = ax.YRuler.Exponent; 
        axis([0,inf,MmV*0.5,(MmV*(size(data,2)-1))-(MmV*0.5)]);        
        set(gca, 'YTickLabel', [size(data,2)-1:-1:2]); % electrode number        
    else % plots the voltages for the inverse CSD method  
        MmV = max(max(abs(data))); % absolute maximum voltage
        yAxisM = MmV*size(data,2); % starting baseline for plots
        figure(1) % plots the voltage data for all electrodes
        subplot(1,3,1);    
        for j = 1:size(data,2);    
            plot(xAxis,data(:,j)+yAxisM,'k');
            yAxisMCol(1,j) = yAxisM;
            yAxisM = yAxisM-MmV; % moves baseline of plot down by MmV
            hold on
        end    
        % converts axis labels to electrode number
        g1 = get(gca,'YTickLabel'); 
        yAxisMCol = flipud(yAxisMCol');
        set(gca,'Ytick',[yAxisMCol]);
        ax=gca; ExV = ax.YRuler.Exponent;
        axis([0,inf,MmV*0.5,(MmV*(size(data,2)+1))-(MmV*0.5)])
        set(gca, 'YTickLabel', [size(data,2):-1:1]); % electrode number 
    end
    % controls the size of magenta scale bar
    if length(g1) < 5;   
        scale1 = ((str2num(g1{2})-str2num(g1{1}))/4)*10^double(ExV);
    elseif length(g1) >= 5 & length(g1) < 10;
        scale1 = ((str2num(g1{2})-str2num(g1{1}))/2)*10^double(ExV);
    else
        scale1 = ((str2num(g1{2})-str2num(g1{1})))*10^double(ExV);
    end   
    % plots scale bar at bottom right of plot
    scV = plot(repmat(max(xAxis),2,1),linspace(0,scale1,2)','m'); 
    scV.LineWidth = 3; 
    % figure labels 
    ylabel('Electrode');
    title({'Voltage'; ['(\color{magenta}scale bar = ' num2str(scale1)...
        ' V\color{black})']});
    xlabel('Time (ms)');
    % plots color bar then turns visbility off. Allows all subplots to be
    % aligned vertically (right subplot contains colorbar)
    colorbar('SouthOutside','Box','off','Visible','off');    
    set(subplot(1,3,1),'color','none','box','off'); % controls appearance
    axY = gca; axY.YRuler.Axle.Visible = 'off'; % controls appearance
    hold off
    % Obtains the CSD
    if CSDtype == 1; % obtains the CSD using the standard CSD method
    CSD = repmat(NaN,size(data,1),size(data,2)); % matrix of NaNs
    for ii = 1:size(data,1); % obtaines the CSD
        for i = 2:size(data,2)-1; % 2nd to 2nd last electode
            % traditional CSD equation
            CSD(ii,i) = -(((data(ii,i+1) - 2*data(ii,i) + data(ii,i-1) )...
                / (spacing^2))*conductivity); 
        end
    end
    else % obtains the CSD using the inverse CSD method
        numElec = size(data,2); % number of electrodes
        z = [spacing:spacing:spacing*numElec]; % electrode positions
        for j = 1:numElec; % generates the F matrix
            for i = 1:numElec;       
                F(j,i) = (spacing/(2*conductivity)) * ... 
                    (sqrt((z(j)-z(i))^2+(radius^2))-abs(z(j)-z(i)));
            end
        end
        % inverse CSD equation
        CSD = F^-1*data'; % matrix multiplication of 1/F with voltages
    end    
    CSD = CSD / conL^3; % converts CSD units to desired length (m, mm, etc)
    CSD = CSD * conA; % converts CSD units to desired amps (A, mA, uA, etc)
    
    % changes um to micrometers for labelling (required later)
    if unitsLength == 'um' 
        unitsLength = ['\mu' 'm'];
    end 
    % changes uA to microamps for labelling (required later)
    if unitsCurrent == 'uA'; 
        unitsCurrent = ['\mu' 'A'];
    end
    
    % Plots the CSD on the middle subplot
    if CSDtype == 1; % plots the CSD for the standard CSD method 
        MC = max(max(abs(CSD(:,2:end-1)))); % absolute maximum CSD
        yAxisM = MC*(size(CSD,2)-2); % starting baseline for plots
        figure(1) % plots the CSD data for the 2nd to 2nd last electrode
        subplot(1,3,2);
        for j = 1:(size(CSD,2)-2);    
            plot(xAxis,CSD(:,j+1)+yAxisM,'k');
            yAxisMColC(1,j) = yAxisM;
            yAxisM = yAxisM-MC; % moves baseline of plot down by MC
            hold on
        end    
        % converts axis labels to electrode number
        g2 = get(gca,'YTickLabel');        
        yAxisMColC = flipud(yAxisMColC');
        set(gca,'Ytick',[yAxisMColC]);
        ax=gca; ExC = ax.YRuler.Exponent;
        axis([0,inf,MC*0.5,(MC*(size(CSD,2)-1))-(MC*0.5)]);
        set(gca, 'YTickLabel', [size(CSD,2)-1:-1:2]); % electrode number   
    else % plots the CSD for the inverse CSD method 
        CSD = CSD';
        MC = max(max(abs(CSD))); % absolute maximum CSD
        yAxisM = MC*size(CSD,2); % starting baseline for plots
        figure(1) % plots the CSD data for all electrodes
        subplot(1,3,2);
        for j = 1:size(CSD,2);    
            plot(xAxis,CSD(:,j)+yAxisM,'k');
            yAxisMColC(1,j) = yAxisM;
            yAxisM = yAxisM-MC; % moves baseline of plot down by MmV
            hold on
        end  
        % converts axis labels to electrode number
        g2 = get(gca,'YTickLabel'); 
        yAxisMColC = flipud(yAxisMColC');
        set(gca,'Ytick',[yAxisMColC]);
        ax=gca; ExC = ax.YRuler.Exponent;
        axis([0,inf,MC*0.5,(MC*(size(CSD,2)+1))-(MC*0.5)])
        set(gca, 'YTickLabel', [size(CSD,2):-1:1]); % electrode number 
    end
    % controls the size of magenta scale bar    
    if length(g2) < 5;   
        scale2 = ((str2num(g2{2})-str2num(g2{1}))/4)*10^double(ExC);;
    elseif length(g2) >= 5 & length(g2) < 10;
        scale2 = ((str2num(g2{2})-str2num(g2{1}))/2)*10^double(ExC);;
    else
        scale2 = ((str2num(g2{2})-str2num(g2{1})))*10^double(ExC);;
    end
    % plots scale bar at bottom right of plot
    scC = plot(repmat(max(xAxis),2,1),[0 scale2]','m'); 
    scC.LineWidth = 3;  
    % figure labels
    ylabel('Electrode')
    title({'CSD'; ['(\color{magenta}scale bar = ' num2str(scale2) ...
        ' ' unitsCurrent '/' unitsLength '^{3}\color{black})']});
    xlabel('Time (ms)')
    % plots color bar then turns visbility off. Allows all subplots to be
    % aligned vertically (right subplot contains colorbar)
    colorbar('SouthOutside','Box','off','Visible','off')
    set(subplot(1,3,2),'color','none','box','off');
    axY = gca; axY.YRuler.Axle.Visible = 'off';  
    hold off
    
    % plots CSD as heat map on the far right subplot
    M = max(max(abs(CSD))); % abosolute maximum CSD, for the colormap scale   
    clims = [-M M]; % gives the upper and lower limit for the colormap
    figure(1)
    subplot(1,3,3)
    if CSDtype == 1; % standard CSD method
        im = imagesc(CSD(:,2:end-1)',clims); % CSD as heatmap 
        colormap(flipud(jet)); % blue = source; red = sink
        cb = colorbar('SouthOutside');
        set(gca,'Ytick',[1:1:size(data,2)-1]);
        set(gca, 'YTickLabel',[2:1:size(data,2)-1]); % electrode number
    else % inverse CSD method
        im = imagesc(CSD',clims); % CSD as heatmap 
        colormap(flipud(jet)); % blue = source; red = sink
        cb = colorbar('SouthOutside');
        set(gca,'Ytick',[1:1:size(data,2)]);
        set(gca, 'YTickLabel',[1:1:size(data,2)]); % electrode number
    end
    % heat map appearance and labels
    cb.Label.String = [unitsCurrent '/' unitsLength '^{3}'];
    set(im, 'XData', xAxis);
    axis([0,max(xAxis),-inf,inf]);
    ylabel('Electrode');
    xlabel('Time (ms)');
    title('CSD (\color{red}sink, \color{blue}source\color{black})');
    % Function output
    CSDoutput = CSD;
    
end
