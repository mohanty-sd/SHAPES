function [] = gensimdatacrcb(nTrials,simDataDir,simParams)
%Light-weight simulation data generation function
%GENSIMDATACRCB(N,D,P)
%N is the number of data realizations. D is the name of the directory where
%the data will be stored. Each realization is stored in a separate .mat
%file named as 'inFile_<n>.mat' where 'n' is the realization number. P is a
%structure with the following fields.
% 'snr': The matched filtering signal to noise ratio of the injected signal
%        in iid zero mean unit variance normal noise (WGN). 
% 'sigFile': The file containing the unit norm signal time series along
%            with the sampling frequency. The length of each data
%            realization is the length of the signal plus any padding at
%            the two ends.
% 'numPad': Number of padding samples at the beginning and at
%           the end of the signal time series. These samples will carry
%           pure WGN. 
%The simulation parameters are stored in a file called log.mat in D.

%Soumya D. Mohanty, May 2018
%May 2019: Modified to take parameter structure input and allow padding

load(simParams.sigFile);
nSamples = length(unitnormsig);
nSamples = nSamples + 2*simParams.numPad;
dataX = (0:(nSamples-1))/fs;

rng('default');
for lpfiles = 1:nTrials
    dataY = [zeros(1,simParams.numPad),simParams.snr*unitnormsig,zeros(1,simParams.numPad)];
    dataY = dataY + +randn(1,nSamples);
    dataFileName = [simDataDir,filesep,'inFile_',num2str(lpfiles)];
    save(dataFileName,'-struct','simParams');
    save(dataFileName,'dataX','dataY','-append');
end
save([simDataDir,filesep,'log'],'-struct','simParams');