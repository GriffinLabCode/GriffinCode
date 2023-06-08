function [hpcSignal,vmtSignal,pfcSignal] = ratNames2LFP_entrainment(ratName)
    if contains(ratName,'BabyGroot')
        hpcSignal = 'CSC12';
        vmtSignal = 'CSC14';
        pfcSignal = 'mPFC';
    elseif contains(ratName,'Meusli')
        hpcSignal = 'CSC13';
        vmtSignal = 'Re';
        pfcSignal = 'mPFC';
    elseif contains(ratName,'Groot')
        hpcSignal = 'HPC';
        vmtSignal = 'Re';
        pfcSignal = 'mPFC';
    end
end
    