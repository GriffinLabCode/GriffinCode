%% redish zIdPhi code

% -- parameters to change -- %

% 1 second window
window_sec = 1; 

% smoothing data
postSmoothing = 0.5; 

%srate
vt_srate = 30;

% dont display anything
display = 0; 

% change in x, consider time
dx    = dxdt_griffinLab(x,window_sec,postSmoothing,vt_srate,display);

% change in y, consider time
dy    = dxdt_griffinLab(y,window_sec,postSmoothing,vt_srate,display);

% orientation
phi   = atan2(dy,dx);

% unwrap to prevent circular transitions
uphi  = unwrap(phi);

% change in orientation, consider time
dphi  = dxdt_griffinLab(uphi,window_sec,postSmoothing,vt_srate,display);

% integrated absolute value of change in orientation when considering time
IdPhi = trapz(abs(dphi));
