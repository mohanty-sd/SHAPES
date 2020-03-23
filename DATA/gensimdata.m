function [] = gensimdata(nTrials,simDataDir,simParams)
%Light-weight simulation data generation function
%GENSIMDATA(N,D,P)
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
%
%NOTE: The random number generator is initialized to its 'default' state
%for every call to this function. Comment out the relevant line
%("rng('default');") if this is not desired.

%Soumya D. Mohanty, May 2018
%Mar 2020: Adapted from CRCBOOKCODES / GENSIMDATACRCB

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
