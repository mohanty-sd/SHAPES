%% Test script for SHPS
% SHPS runs the SHAPES algorithm on given data. 

%Input data file (use DATA/test_gendataBFsig.m to generate simulated data first)
inDataFile = fullfile('DATA','TEMP','GIBFsig2_WgnPad2_SNR100_DATA','inFile_1');

%Regulator gain
rGain = 2.0;
%Number of knots over which to perform model selection
nKnts = [5,10];
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

%% Do not change below

load(inDataFile);

% Parameters for SHPS
params = struct('dataY',dataY,'dataX',dataX,...
                'nBrks',nKnts,'rGain',rGain);

psoP = struct('nRuns',nRuns,...
             'psoParams',psoParams);
         
[allResults,bestMdlResults] = shps(params, psoP);

figure;
plot(dataX,dataY,'.');
hold on
plot(dataX,bestMdlResults.bestModelSig);
legend('Data','Signal','Estimate');
