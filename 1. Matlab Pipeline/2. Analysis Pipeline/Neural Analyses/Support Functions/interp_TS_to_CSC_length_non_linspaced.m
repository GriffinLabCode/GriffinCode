%%
%{
This is used as a more adaptive alternative to linspacing the Timestamps var (after loading a CSC).

Linspacing works fine but can lead to misalignment between events and the true segments of LFP surrounding those events.
For example, a session with multiple start/stop/start recording points leads to a non-linear progression of Timestamp values in the var. 
This can be seen by plotting Timestamps. 
With a single start and single stop progression you would expect a smooth linearly progressing line;
however, this is not the case with multiple starts and stop and the plot will appear more jagged with breaks in the continuity of recorded timestamp values.
Moreover, linspacing simply takes the first and last timestamp value and creates regularly distances between timestamp values inbetween in order to match the length of a given CSC.
This can lead to misalignment of data and the actual times in which they occurred. 
 
Interpolation can be used as an alternative to maintain complex temporal structure and the relations between data and their true times of occurence.

This function is to be used immediately after loading a CSC with the load function.

Inputs:
        - Samples       (512 x n)
        - Timestamps    (1   x n)


Notes: 
        - The length of Timestamps should match the size(Samples,2).

Outputs:
        - Samples_new       (1 x (512*n))
        - Timestamps_new    (1 x length(Samples_new)


Can plot to see diff, temporal structure will be maintained but Timestamps_new will be lengthened to match length of linearized CSC vector.
        figure; subplot 121; plot(Timestamps); subplot 122; plot(Timestamps_new)


written by Andrew Garcia

%}
function [Timestamps_new, Samples_new] = interp_TS_to_CSC_length_non_linspaced(Timestamps, Samples)

Samples_new = Samples(:)';
TS_length = 1:length(Timestamps);
stepper = length(Timestamps)/(length(Samples_new)+512);
extender = (1:stepper:length(Timestamps));
Timestamps_new = interp1(TS_length,Timestamps,extender);

if length(Timestamps_new) ~= length(Samples_new)
    error('SOURCE OF ERROR: LENGTH OF TIMESTAMPS_NEW DOES NOT MATCH LENGTH OF SAMPLES_NEW.');
    return;
else
end


end

