function [] = gendataBFsig(nRlz,nSig,sigDir,outDataDir,simParams)
%Generate simulation data with different types of benchmark signals
%GENDATABFSIG(N,Nsig,S,D,P)
%N is the number of data realizations to produce for each type of signal.
%Nsig is a vector of benchmark signal serial numbers: 1 to 6 refer to GIBF
%and 7 to 10 refer to SMBF signals and more can be added later. Nsig can
%specify any mixture of any subset of signal serial numbers in any order. S
%is the path to folder containing benchmark signal files. Each signal file
%should have the two variables 'fs' and 'unitnormsig' at the minimum. D is
%the path to folder where the folders containing the data realizations will
%be stored. P is a structure that specifies the simulation parameters.
% P.snr : SNR of the signal to be injected into white Gaussian noise (WGN)
%         with zero mean and unit variance.
% P.numPad : The number of WGN samples to pad the data with at each end.
%            This padding helps in signal estimation when the signal does
%            not terminate smoothly at zero. The padding is taken into
%            account during post-processing. Set to [] to invoke the
%            default value of 2.

%Soumya D. Mohanty, May 2019

snr = simParams.snr;
numPad = simParams.numPad;
if isempty(numPad)
    numPad = 2;
end

inParams = struct('snr',snr,...
                   'sigFile','',...
                   'numPad',numPad);
for lp = nSig
    [sigType,sigIndx] = bnchmrksiginfo(lp);
    inParams.sigFile = [sigDir,filesep,sigType,num2str(sigIndx)];
    simDataDir = [outDataDir,filesep,sigType,num2str(sigIndx),...
                  '_WgnPad',num2str(inParams.numPad),'_SNR',...
                  num2str(inParams.snr),'_DATA'];
    mkdir(simDataDir);
    gensimdatacrcb(nRlz,simDataDir,inParams);
end
