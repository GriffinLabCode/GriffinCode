%% correlation plot
%
% this function generates a correlation plot based on the inputs
%
% INPUTS:
% var1 and var2 must be a vector in double format from paired observations
%
% OUTPUTS:
% pearsons r and p values
%
% written by John Stout with help from this guy
% https://www.mathworks.com/matlabcentral/answers/377139-how-to-plot-best-fit-line

function [r_pearson,p_pearson] = PlotCorrelation(var1,var2)

figure('color',[1 1 1]);
scatter(var1,var2,'k','MarkerFaceColor',...
    [0.800000011920929 0.800000011920929 0.800000011920929]);
    [R,P] = corrcoef(var1,var2)
    coeffs = polyfit(var1, var2, 1);
    % Get fitted values
    fittedX = linspace(min(var1), max(var1), 200);
    fittedY = polyval(coeffs, fittedX);
    % Plot the fitted line
    hold on;
    plot(fittedX, fittedY, 'r', 'LineWidth', 1.5); 
    axis tight
end