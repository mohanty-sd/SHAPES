%% Test script for SHPS
% SHPS runs the SHAPES algorithm on given data. 

%Input data file (use DATA/test_gendataBFsig.m to generate simulated data first)
inDataFile = fullfile('DATA','TEMP','inFile_1');

%Regulator gain
rGain = 0.1;
%Number of knots over which to perform model selection
nKnts = [5,6,7,8,9,10,12,14,16,18];
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

%% 
%-----------Do not change below---------------

load(inDataFile);

% Parameters for SHPS
params = struct('dataY',dataY,'dataX',dataX,...
                'nBrks',nKnts,'rGain',rGain);

psoP = struct('nRuns',nRuns,...
             'psoParams',psoParams);

tic;
[allResults,bestMdlResults] = shps(params, psoP);
toc;

figure;
%Take care of padding
strtIndx = numPad+1;
endIndx = length(dataX)-numPad;
plot(dataX(strtIndx:endIndx),dataY(strtIndx:endIndx),'.');
hold on
plot(dataX(strtIndx:endIndx),bestMdlResults.bestModelSig(strtIndx:endIndx));
legend('Data','Estimate');
