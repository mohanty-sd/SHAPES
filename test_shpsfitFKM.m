%% Test script for SHPSFITFKM
% SHPSFITFKM evaluates the fitness value of a given knot sequence. 

%Interior knots (Note: chosen randomly; not the global optimizer of the
%fitness function)
intBrkPts = [0.2,0.3,0.301,0.4,0.5,0.5005,0.501,0.6];
%Regulator gain
rGain = 2.0;
%Input data file (use DATA/test_gendataBFsig.m to generate simulated data first)
inDataFile = fullfile('DATA','TEMP','GIBFsig2_WgnPad2_SNR100_DATA','inFile_1');

%% Do not change below

load(inDataFile);

smplIntrvl = dataX(2) - dataX(1);

nIntBrks = length(intBrkPts);


% Transform knot sequence to standardized coordinates in 'plain'
% parametrization scheme (leaving a little offset of a sampling interval
% from the predictor boundary values)
xVec = (intBrkPts-(dataX(1)+smplIntrvl))/(dataX(end)-dataX(1)-2*smplIntrvl);

% Parameters for SHPSFITFKM: rmin and rmax give the range for each
% element of xVec. It is [0,1] since each element of xVec is standardized.
params = struct('dataY',dataY,'dataX',dataX,...
                'rmin',zeros(1,nIntBrks),'rmax',ones(1,nIntBrks),...
                'rGain',rGain);

[fitVal,rc,~,ppsig,mltplct] = shpsfitFKM(xVec,params);
figure;
plot(dataX,dataY,'.');
hold on
plot(dataX,ppsig);
legend('Data','Signal','Estimate');
