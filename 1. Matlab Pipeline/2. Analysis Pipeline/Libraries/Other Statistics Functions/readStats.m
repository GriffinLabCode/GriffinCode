%% readStats
% this function was written to promote statistical testing conversions to
% manuscript writing
%
% -- INPUTS -- %
% data: cell array or matrix
% parametric: set to 'y' if you want a parametric test (ttest or ttest2)
% stat_test: name of statistical test
%               Parametric options:
%                   'ttest' or 'ttest2'
%               non-parametric options:
%                   'signrank' or 'ranksum'
%               
% data_title: what you are comparing (str type)
% OPTIONAL: numCorrections: set to whatever numerical value you want for
%               Bonferroni p-value correction (p*number of tests)
%
% -- OUTPUTS -- %
% displayed 
%
% written by John Stout on 4/10/2023

function [] = readStats(data1,data2,parametric,stat_test,data_title,numCorrections) 
    % check that numCorrections exists, and if it does, check that the
    % variable is not empty. We will set this to 1 automatically.
    if exist('numCorrections')==1
        if isempty(numCorrections)
            numCorrections = 1;
        end
    end
    
    % parametric tests
    if contains(parametric,[{'y'} {'Y'}])
        if contains(stat_test,'ttest2')
            disp('Running two sample t-test')
            [h,p,ci,stat]=ttest2(data1,data2);       
        else
            disp('Running paired ttest')
            [h,p,ci,stat]=ttest(data1,data2);
        end
        if p<0.05
            p=p*numCorrections;
            data_title = horzcat(data_title,' Bonf Corrected');
        else
            data_title = horzcat(data_title,' not Bonf Corrected');
        end    
        disp([data_title,' | ','t(',num2str(stat.df),') = ',num2str(stat.tstat),', ci = ',num2str(ci(1)),' to ',num2str(ci(2)),', p = ',num2str(p)]);        
    else
        % non-parametric versions
        if contains(stat_test,'ranksum')
            disp('Running ranksum test')
            [p,h,z]=ranksum(data1,data2); 
            z = z.ranksum;
        elseif contains(stat_test,'signrank')
            disp('Running signrank test for paired data')
            [p,h,z]=signrank(data1,data2);  
            z = z.signedrank;
        end
        if p<0.05
            p=p*numCorrections;
            data_title = horzcat(data_title,' Bonf Corrected');
        else
            data_title = horzcat(data_title,' not Bonf Corrected');
        end            
        disp([data_title,' | Z = ',num2str(z),', p = ',num2str(p)]);                
    end
end
