function [all_sess] = mean_ifrq(type,varargin)
% get out mean and stdev for all varargin and output w
% labels or something

% CW

% if type is 'all', just go through all the fields in the struct and get
% out mean, std and field name...
if strcmp(type,'all')
    names=fieldnames(varargin{1});
    for i=1:length(names)
        tmp=[];
        tmp=getfield(varargin{1},char(names(i)));
        all_sess.mean(i,:)=mean(tmp.data);
        all_sess.std(i,:)=std(tmp.data);
        all_sess.name{i,:}=char(names(i));
    end
% Otherwise, just get mean, std and name for all the varargin
else 
    for i=1:nargin
        all_sess.mean(i)=mean(varargin{i}.data);
        all_sess.std(i)=std(varargin{i}.data);
        all_sess.name(i)=varargin{i}.name;
    end
end

end

