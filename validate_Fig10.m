%% Validate results in Fig. 10 of SHAPES paper

%Signal type
nSig = 2;
%Path to signal files
sigDir = 'DATA';
%Signal to noise ratio
snrVal = 100;
%Number of data realizations
nRlz = 1000;

%Folder where generated data will be stored
simDataDir = 'VALIDATE';
%Folder where results will be stored
resultsDir = fullfile('VALIDATE','RESULTS');

%PSO related parameters
%------------------------
%Number of independent PSO runs
nRuns = 4;
%PSO parameters
psoParams = struct(...
               'popsize',40,...
               'maxSteps', 100,...
               'c1',2,...
               'c2',2,...
               'maxVelocity',0.5,...
               'startInertia',0.9,...
               'endInertia', 0.4,...
               'boundaryCond','',...
               'nbrhdSz',3);

%SHAPES parameters
%------------------------
%Regulator gain
rGain = 0.1;
%Number of knots over which to perform model selection
nKnts = [5,6,7,8,9,10,12,14,16,18];


%---------------Do not change below-----------------

mkdir(simDataDir);
mkdir(resultsDir);

%Generate data realizations (see test_gendataBFsig.m and the help for
%gendataBFsig.m for usage details) using default padding
gendataBFsig(nRlz,nSig,snrVal,simDataDir,sigDir);
preAllocInfo = load(fullfile(simDataDir,'inFile_1'),'dataX');
nSmpls = length(preAllocInfo.dataX);

psoP = struct('nRuns',nRuns,...
             'psoParams',psoParams);

%For each data file ...
for lp = 1:nRlz
    %Load data
    inFileName = fullfile(simDataDir,['inFile_',num2str(lp)]);
    inFileInfo = load(inFileName,'dataX', 'dataY');
    % Set parameters for SHPS
    params = struct('dataY',inFileInfo.dataY,...
                    'dataX',inFileInfo.dataX,...
                    'nBrks',nKnts,'rGain',rGain);
    %Run SHAPES
    disp(['Processing input file ',inFileName]);
    tic;
    [allResults,bestMdlResults] = shps(params, psoP);
    toc;

    %Store estimated signal
    estSig = bestMdlResults.bestModelSig;
    save(fullfile(resultsDir,['outFile_',num2str(lp)]),'estSig');
end

%Obtain point-wise mean and standard deviation of estimates
meanSig = zeros(1,nSmpls);
stdSig = zeros(1,nSmpls);
%For each output file ...
for lp = 1:nRlz
    %Load estimated signal
    outFileName = fullfile(resultsDir,['outFile_',num2str(lp)]);
    outFileInfo = load(outFileName,'estSig');
    
    %Accumulate ...
    meanSig = meanSig + outFileInfo.estSig/nRlz;
    
    stdSig = stdSig + outFileInfo.estSig.^2/nRlz;
end
stdSig = sqrt(stdSig - meanSig.^2);

%Plot
%-----------
%Sample data
inFileName = fullfile(simDataDir,'inFile_1');
inFileInfo = load(inFileName,'dataX', 'dataY');
dataX = inFileInfo.dataX;
dataY = inFileInfo.dataY;
%Take care of padding
numPad = 2;
strtIndx = numPad+1;
endIndx = length(dataX)-numPad;

figure;
plot(dataX(strtIndx:endIndx),dataY(strtIndx:endIndx),'.');
hold on;
plot(dataX(strtIndx:endIndx),meanSig(strtIndx:endIndx));
%+/- 2*sigma error 
plot(dataX(strtIndx:endIndx),meanSig(strtIndx:endIndx)-2*stdSig(strtIndx:endIndx));
plot(dataX(strtIndx:endIndx),meanSig(strtIndx:endIndx)+2*stdSig(strtIndx:endIndx));
axis tight;