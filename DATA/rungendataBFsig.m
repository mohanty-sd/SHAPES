%% Generate simulation data
%Number of data realizations per signal
nRlz = 10;
%Signal serial numbers
nSig = [1,2,10];
%Signal snr values
snrVal = [10,100];
%Number of samples for WGN padding at each end
numPad = [];

%Path to the directory under which the directories containing simulated
%data are to be created
simDataDir = 'TEMP';
%Path to files containing the unit norm signal time series
sigDir = '.';

%------DO NOT CHANGE BELOW-------------
for lp = 1:length(snrVal)
    gendataBFsig(nRlz,nSig,sigDir,simDataDir,...
                                  struct('snr',snrVal(lp),...
                                         'numPad',numPad));
end