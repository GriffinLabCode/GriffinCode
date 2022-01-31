%% backwards generate viewVTdata
% when generating your Int_information file, you have to set a ton of
% parameters. But what if you have an Int_information file, but need to
% modify some of those parameters? Instead of having to manually sort
% through things, you can run backwardGenViewVT.mat which will backwards
% generate your minX,minY,addX, and addY variables to save a ton of time.
%
% -- INPUTS -- %
% inputs: this is your fld rectangle data generated rom view_VT_data and
%       saved out into your Int_information file. For example, 
%           inputs = CP_fld;
%
% -- OUTPUTS -- %
% minX: minimum X rectangle
% minY:
% diffX: used to calculate addX
% diffY
%
% written by John Stout

function [minX,minY,diffX,diffY] = backwardGenViewVT(inputs)
    minX = inputs(1);
    minY = inputs(2);
    diffX = inputs(1)+inputs(3);
    diffY = inputs(2)+inputs(4);
    
    disp([' minX=',num2str(minX), ' minY=', num2str(minY), ' addX=',num2str(diffX),'-minX' ,' addY=',num2str(diffY),'-minY'])
end
