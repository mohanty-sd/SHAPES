%% Generate simulation data
%Number of data realizations per signal type and snr combination
nRlz = 10;
%Signal types (see BNCHMRKSIGINFO)
nSig = [1,2,10];
%Signal snr values
snrVal = [10,100];
%Number of samples for White Gaussian noise padding at each end
numPad = []; %Use [] for default value (see GENDATABFSIG)

%Path to the folder under which sub-folders containing simulated data will
%be created: Each sub-folder corresponds to one combination of (signal
%serial number, snr) and contains the specified number (nRlz) of data files.
simDataDir = 'TEMP';
%Path to files containing the unit norm signal time series
sigDir = '.';

%------DO NOT CHANGE BELOW-------------
for lp = 1:length(snrVal)
    gendataBFsig(nRlz,nSig,sigDir,simDataDir,...
                                  struct('snr',snrVal(lp),...
                                         'numPad',numPad));
end