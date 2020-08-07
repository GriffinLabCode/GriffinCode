%% whereishe_master
% this function generates a majority of the Int file - its to be used in
% combination with the Int_DNMP_john script.
%
% This function currently only works for the left recording room - you will
% need to change this under the 'copy and paste' section (section 2)
%
% INPUTS: 
%         datafolder - string variable containing directory
%         missing_data - a string. Can be:
%               'interp' to interpolate missing vt data
%               'exclude' to exclude missing vt data
%               'ignore' to ignore missing vt data
%               For example: missing_data = 'interp';
%
% OUTPUTS: Int file
%

function [Int] = whereishe_master(pos_x,pos_y,pos_t)

% load VT data
load('Int_information')

n=length(pos_x);

%% dont' change:

A_start_x = rRW_fld(1,1); A_end_x =(rRW_fld(1,1)+rRW_fld(1,3));A_start_y =rRW_fld(1,2); A_end_y =(rRW_fld(1,2)+rRW_fld(1,4)); 
B_start_x = lRW_fld(1,1); B_end_x =(lRW_fld(1,1)+lRW_fld(1,3));B_start_y =lRW_fld(1,2); B_end_y =(lRW_fld(1,2)+lRW_fld(1,4)); 
C_start_x = STM_fld(1,1); C_end_x =(STM_fld(1,1)+STM_fld(1,3));C_start_y =STM_fld(1,2); C_end_y =(STM_fld(1,2)+STM_fld(1,4)); 
D_start_x = PED_fld(1,1); D_end_x =(PED_fld(1,1)+PED_fld(1,3));D_start_y =PED_fld(1,2); D_end_y =(PED_fld(1,2)+PED_fld(1,4)); 
E_start_x = CP_fld(1,1);  E_end_x =(CP_fld(1,1)+CP_fld(1,3));E_start_y =CP_fld(1,2); E_end_y =(CP_fld(1,2)+CP_fld(1,4)); 

% (rest of) regular 'whereishe' continues here

A_mid_x = (A_start_x + A_end_x)/2;
B_mid_x = (B_start_x + B_end_x)/2;

num_Int = 1;
Int = [];
E2 = [];

%Tstamp variables
interval_start_tstamp = 0;interval_end_tstamp = 0;
E_start_t = 0; E_end_t = 0;

%State variables. Indicator (1 or 0)
inside_A = 0;inside_B = 0; inside_C = 0; inside_D = 0; has_been_to_C = 0;
has_been_to_D = 0; num_L=0; num_R=0; has_been_to_A=0; has_been_to_B=0;
inside_E = 0; has_been_to_E = 0;

was_inside_A=0; was_inside_B=0; was_inside_D=0; 

for i=1:n;
    
    %Where was the rat?
    was_inside_A=inside_A;
    was_inside_B=inside_B;
    was_inside_C=inside_C;
    was_inside_D=inside_D;
    was_inside_E=inside_E;
    
    %Where is the rat? These expressions evalue to 1 when true and 0 when
    %false. It's a shorter If statement.
    inside_A = (pos_x(1,i)>=A_start_x) && (pos_x(1,i)<=A_end_x) && (pos_y(1,i)>=A_start_y) && (pos_y(1,i)<=A_end_y);
    has_been_to_A = (((pos_x(1,i)>=A_start_x) && (pos_x(1,i)<=A_end_x) && (pos_y(1,i)>=A_start_y) && (pos_y(1,i)<=A_end_y)) || (has_been_to_A == 1));
    inside_B = (pos_x(1,i)>=B_start_x) && (pos_x(1,i)<=B_end_x) && (pos_y(1,i)>=B_start_y) && (pos_y(1,i)<=B_end_y);
    has_been_to_B = (((pos_x(1,i)>=B_start_x) && (pos_x(1,i)<=B_end_x) && (pos_y(1,i)>=B_start_y) && (pos_y(1,i)<=B_end_y)) || (has_been_to_B == 1));
    inside_C = (pos_x(1,i)>=C_start_x) && (pos_x(1,i)<=C_end_x) && (pos_y(1,i)>=C_start_y) && (pos_y(1,i)<=C_end_y);
    has_been_to_C = (((pos_x(1,i)>=C_start_x) && (pos_x(1,i)<=C_end_x) && (pos_y(1,i)>=C_start_y) && (pos_y(1,i)<=C_end_y)) || (has_been_to_C==1));
    inside_D = (pos_x(1,i)>=D_start_x) && (pos_x(1,i)<=D_end_x) && (pos_y(1,i)>=D_start_y) && (pos_y(1,i)<=D_end_y);
    has_been_to_D = (((pos_x(1,i)>=D_start_x) && (pos_x(1,i)<=D_end_x) && (pos_y(1,i)>=D_start_y) && (pos_y(1,i)<=D_end_y)) || (has_been_to_D==1));
    inside_E = (pos_x(1,i)>=E_start_x) && (pos_x(1,i)<=E_end_x) && (pos_y(1,i)>=E_start_y) && (pos_y(1,i)<=E_end_y);
    has_been_to_E = (((pos_x(1,i)>=E_start_x) && (pos_x(1,i)<=E_end_x) && (pos_y(1,i)>=E_start_y) && (pos_y(1,i)<=E_end_y)) || (has_been_to_E==1));
    
    %we are interested in the interval between the exit from D (box) and the entry to B or A (reward zones), respectively:
    if ((was_inside_D ~=0) && (inside_D==0))
%        just left D, note the time:
        interval_start_tstamp=pos_t(1,i);
    end
    

    if (was_inside_E==0) && (inside_E ~=0) && (was_inside_A==0)...
            && (was_inside_B==0) && (inside_A==0) && (inside_B==0) ...
            && (was_inside_C==1)
            E_start_t = pos_t(1,i);
    end

    if (was_inside_E ~=0) && (inside_E==0)
        E_end_t = pos_t(1,i);
    end
    
    %If he was coming from E, he is choosing a reward zone.
    if (was_inside_A==0) && (inside_A ~=0) && (has_been_to_E ~=0) 
        %Chose right
%         interval_end_tstamp=pos_t(1,i);
        Int(num_Int,:) = [interval_start_tstamp, pos_t(1,i), 1, 0, E_start_t, E_end_t, NaN, NaN];
        num_Int = num_Int + 1;
%         Int_R(num_R, 2)=interval_end_tstamp;

         if has_been_to_B == 1
%             Int_L(num_L,1:2) = 0;
%             num_L = num_L-1;
             has_been_to_B = 0;
         end
        
    end
    
    if (was_inside_B==0) && (inside_B ~=0) && (has_been_to_E ~=0)
        %Chose left
%         interval_end_tstamp=pos_t(1,i);
        Int(num_Int,:) = [interval_start_tstamp, pos_t(1,i), 0, 0, E_start_t, E_end_t, NaN, NaN];
        num_Int = num_Int + 1;
%         Int_L(num_L, 2)=interval_end_tstamp;

         if has_been_to_A == 1
%             Int_R(num_R,1:2) = 0;
%             num_R = num_R-1;
             has_been_to_A = 0;
         end
        
    end
    
    %When the animal leaves A or B, reset the indicator of whether he has
    %been to C and E
    %Potentially an issue if the animal backtracks
    if (was_inside_A ~=0) && (inside_A==0) || (was_inside_B ~=0) && (inside_B==0)
        has_been_to_C=0;
        has_been_to_E=0;
    end
    
    % define when animal leaves the reward zone
    if (inside_A==0) && (was_inside_A~=0) %&& (pos_x(1,i) < A_start_x)
        %Left of the Right reward zone on the return stem
        E2(num_Int,1) = pos_t(1,i);
        has_been_to_D = 0;
    end
    
    % define when animal leaves the reward zone
    if (inside_B ==0) && (was_inside_B~=0) %&& (pos_x(1,i) < B_start_x)
        %Left of the Left reward zone on the return stem
        E2(num_Int,1) = pos_t(1,i);
        has_been_to_D = 0;
    end
    
    if (inside_D ==1) && (was_inside_D==0) && (has_been_to_A == 1)
        %Entering the Base from the Right Reward Zone
        E2(num_Int,2) = pos_t(1,i);
        has_been_to_A = 0;
    end
    
    if (inside_D ==1) && (was_inside_D==0) && (has_been_to_B == 1)
        %Entering the Base from the Left Reward Zone
        E2(num_Int,2) = pos_t(1,i);
        has_been_to_B = 0;
    end
    
end

if ~isempty(Int)
    Int(:,[7,8]) = E2([2:num_Int],:);
end

clear q p r
end