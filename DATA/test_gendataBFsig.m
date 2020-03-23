%% Generate simulation data
%Number of data realizations 
nRlz = 10;
%Signal type (see BNCHMRKSIGINFO)
nSig = 1;
%Signal snr 
snrVal = 100;
%Number of samples for White Gaussian noise padding at each end
numPad = []; %Use [] for default value (see GENDATABFSIG)

%Path to the folder in which to create the data files
simDataDir = 'TEMP';
%Path to files containing the unit norm benchmark function vectors
sigDir = '.';

mkdir(simDataDir);

%------DO NOT CHANGE BELOW-------------
gendataBFsig(nRlz,nSig,snrVal,simDataDir,sigDir,numPad);
