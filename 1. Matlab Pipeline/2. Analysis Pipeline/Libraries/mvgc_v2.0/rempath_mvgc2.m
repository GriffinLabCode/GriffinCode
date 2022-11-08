%% MVGC Toolbox "startup" script
%
% Initialise MVGC Toolbox. This file is run automatically if Matlab is started
% in the toolbox root (installation) directory.
%
% You may have to (or want to) customise this script for your computing
% environment.
%
% (C) Lionel Barnett and Anil K. Seth, 2012. See file license.txt in
% installation directory for licensing terms.
%
%% Set toolbox version

global mvgc_version;
mvgc_version.major = 2;
mvgc_version.minor = 0;

fprintf('[mvgc startup] Initialising MVGC toolbox version %d.%d\n', mvgc_version.major, mvgc_version.minor);

%% v2.0: Dirty workaround for Matlab "static TLS" bug (deprecated, v2.0)
% See http://www.mathworks.de/support/bugreports/961964. Affects Linux 64-bit
% versions R2014a, R2013b, R2013a, R2012b. Apparently fixed in R2014b.
%
% if isunix && verLessThan('matlab','8.4') && ~verLessThan('matlab','8.0') - ver
% 2.0: 'verLessThan' broken in older versions apply the workaround anyway
%    fprintf('[mvgc startup] Applying workaround for legacy Matlab "static TLS" bug\n');
%    ones(10)*ones(10);
%    clear ans
% end

%% Set paths

% Add mvgc root directory and appropriate subdirectories to path

global mvgc_root;
mvgc_root = fileparts(mfilename('fullpath')); % directory containing this file

% essentials
rmpath(mvgc_root);
rmpath(fullfile(mvgc_root,'core'));
rmpath(fullfile(mvgc_root,'gc'));
rmpath(fullfile(mvgc_root,'gc','ss'));
rmpath(fullfile(mvgc_root,'gc','subsample'));
rmpath(fullfile(mvgc_root,'cc'));
rmpath(fullfile(mvgc_root,'GCCA_compat'));    % moved v2.0
rmpath(fullfile(mvgc_root,'MVGC_v1_compat')); % added v2.0
rmpath(fullfile(mvgc_root,'stats'));
rmpath(fullfile(mvgc_root,'utils'));
rmpath(fullfile(mvgc_root,'deprecated')); % added v2.0 - make deprecated functions available for the time being
rmpath(fullfile(mvgc_root,'demo'));
rmpath(fullfile(mvgc_root,'mex'));
rmpath(fullfile(mvgc_root,'experimental'));
rmpath(fullfile(mvgc_root,'docs')); % don't add the 'html' subdirectory!

% Maintainer version (include 'maintainer', 'extra' and 'testing')

if true % extra stuff & testing

	% Maintenance, testing and in-house extras

    rmpath(genpath(fullfile(mvgc_root,'extra')));
    rmpath(genpath(fullfile(mvgc_root,'testing')));
end

if true % Initialise in-house "Gpmat" Gnuplot/Matlab library if present.

	global gpmat_root;
	gpmat_root = getenv('MATLAB_GPMAT');
	if exist(gpmat_root,'dir') == 7
		cd(gpmat_root);
		startup;
		cd(mvgc_root);
		fprintf('[mvgc startup] Initialised "Gpmat" Matlab Gnuplot API\n');
	else
		fprintf(2,'[mvgc startup] WARNING: couldn''t find "Gpmat" Matlab Gnuplot API\n');
	end
end

if false % Initialise in-house LZ library

	global LZc_root;
	LZc_root = getenv('MATLAB_LZC');
	if exist(LZc_root,'dir') == 7
		cd(LZc_root);
		startup;
		cd(mvgc_root);
		fprintf('[mvgc startup] Initialised "LZc" Matlab Lempel-Ziv complexity API\n');
	else
		fprintf(2,'[mvgc startup] WARNING: couldn''t find "fLZc" Matlab Lempel-Ziv complexity API\n');
	end
end

% Maintainer

if true % MVGC maintainer

	% Maintenance, testing and in-house extras

    rmpath(fullfile(mvgc_root,'maintainer'));
end

%% Check |mex| files

% Check for |mex| files and set flags appropriately

global have_mvfilter_mex;
have_mvfilter_mex = exist('mvfilter_mex','file') == 3;
if have_mvfilter_mex
    fprintf('[mvgc startup] ''mvfilter_mex'' mex routine available for your platform\n');
else
    fprintf(2,'[mvgc startup] WARNING: no ''mvfilter'' mex file found; please run ''make'' from\n');
    fprintf(2,'[mvgc startup]          the command line in the C subfolder, then ''mextest''\n');
    fprintf(2,'[mvgc startup]          from the Matlab prompt. Meanwhile, a slower scripted\n');
    fprintf(2,'[mvgc startup]          routine will be used.\n');
end

global have_findin_mex;
have_findin_mex = exist('findin_mex','file') == 3;
if have_findin_mex
    fprintf('[mvgc startup] ''findin'' mex routine available for your platform\n');
else
    fprintf(2,'[mvgc startup] WARNING: no ''findin'' mex file found; please run ''make'' from\n');
    fprintf(2,'[mvgc startup]          the command line in the C subfolder, then ''mextest''\n');
    fprintf(2,'[mvgc startup]          from the Matlab prompt. Meanwhile, a slower scripted\n');
    fprintf(2,'[mvgc startup]          routine will be used.\n');
end

%%
% <startup.html back to top>
