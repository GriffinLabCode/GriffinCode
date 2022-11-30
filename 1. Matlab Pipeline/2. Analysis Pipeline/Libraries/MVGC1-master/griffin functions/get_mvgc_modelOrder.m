%% model order estimation
% this function will provide a BIC model order output
%
% -- INTPUTS --%
% data: matrix of data (rows = brain region, col = signal)
% mcgc_params: run "get_mvgc_parameters.m"
% plotFig: set to 1 if you would like to see the BIC/AIC process
%
% -- OUTPUTS -- %
% moBIC: BIC model order. Future code can select AIC or BIC based on which
%           is better fitting
%
% JS 11/8/22 from mvgc

function [moBIC] = get_mvgc_modelOrder(data,mvgc_params,plotFig)

    % convert data to type double (this doesn't actually matter for this
    % step)
    data = double(data);
    data = demean(data,'true');

    % AIC reflects information lost by the model. Lower values indicate less
    % information lost. BIC is like AIC, but generally preferred in our field.
    ptic('\n*** tsdata_to_infocrit\n');
    [AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(data,mvgc_params.momax,mvgc_params.icregmode);
    ptoc('*** tsdata_to_infocrit took ');

    if exist('plotFig')
        if plotFig == 1
            figure('color','w'); clf;
            plot_tsdata([AIC BIC]',{'AIC','BIC'},1/mvgc_params.fs);
            title('Model order estimation');
        end
    end