
function [allResults,bestMdlResults] = shps(inParams, psoP)
%SHAPES adaptive spline fit with FKM option
%[O,BMO] = SHPS(I,P)
%The SHAPES adaptive spline fit algorithm: Penalized spline with PSO-based
%knot optimization and model selection over the number of knots.  I is the
%input struct, P is the PSO parameter struct, and O is a struct containing
%the output.
%
%NOTE: The random number generator on each parallel worker is reset to its
%default state for every call to this function. Comment out the relevant
%line ("rng(lpruns);") if this is not desired.
%
%The required fields of I are:
% 'dataX': vector of uniformly spaced predictor (i.e., independent variable) values.
% 'dataY': vector of outcome (i.e., dependent variable) values.
% 'nBrks': vector of knot numbers to use in model selection.
% 'rGain' : regulator gain
%
%The optional fields of I are:
% 'padL','padR': vectors that are prepended and appended, respecitvely, to 
%                'dataY'. Leave either one out to invoke their default value of
%                [-0.5,0.5].
%
%The struct P contains settings for PSO and number of independent PSO
%runs. The fields of P are as follows.
%   'nRuns' : Number of independent PSO runs. The run with the best fitness
%             value is used for constructing the output. PARFOR is used to
%             parallelize over the runs. Use parpool(numWorkers) to set the
%             default number of parallel workers.
%   'psoParams' : The PSO parameter structure. See the help for
%                 SDMBIGDAT19/CODES/crcbpso.m. Set to [] to invoke the
%                 default parameter values.
%
%O is a struct array with the following field. Each element of O
%corresponds to one model (i.e., one number of knots).
% 'allRunsOutput': An N element struct array containing results from each PSO
%              run. The fields of this struct are:
%                 'fitVal': The fitness value.
%                 'bsplCoeffs': The B-spline coefficients.
%                 'brkPts': The knots.
%                 'mltplct': The multiplicity of the knots in 'brkPts'
%                 'estSig': The estimated signal.
%                 'totalFuncEvals': The total number of fitness
%                                   evaluations.
% 'bestRun': The best run.
% 'bestSig' : The signal estimated by the best run.
% 'bestBrks' : The knots found in the best run.
% 'AIC' : The AIC value for the bestrun model.
% 'BIC' : The BIC value for the bestrun model.
% 'nBrks': The number of knots defining the bestrun model.
%BMO is a struct containing results for the best model as selected by its
%AIC value. The fields of BMO are as follows.
%  'bestModelNum': The index of the element of O corresponding to the best
%                  model chosen using AIC ('ABM: AIC Best Model')
%  'bestModelSig': The estimated signal from the best run for the ABM
%  'bestModelnBrks' : The number of knots defining the ABM
%  'bestModelBrkPts': The knots from the best run for the ABM
%  'bestModelMltplct': The multiplicity sequence of the knots from
%                      the best run for the ABM
%  'bestModelAIC': The AIC value for the ABM
%  'BICModelNum': The index of the element of O corresponding to the best
%                 model chosen using BIC ('BBM: BIC Best Model')
%  'BICModelSig': The estimated signal from the best run for the BBM
%  'BICbestModelnBrks': The number of knots defining the BBM
%  'BICbestModelBrkPts': The knots from the best run for the BBM
%  'bestModelBIC': The BIC value for the BBM

%Soumya D. Mohanty, May 2018
%Apr 2019: Extended by adding BIC
%June 2019: Consolidated number of runs and pso parameters input arguments
%Mar 2020: Adapted from REGSPLPSPLMDLSEL

%Number of independent PSO runs
nRuns = psoP.nRuns;
%Parameters to pass on to PSO 
psoParams = psoP.psoParams;
outputLvl = 0;

%Default padding
padL = [-0.5,0.5];
padR = [-0.5,0.5];
if isfield(inParams,'padL')
    padL = inParams.padL;
end
if isfield(inParams,'padR')
    padR = inParams.padR;
end
numPadL = length(padL);
numPadR = length(padR);

strtX = inParams.dataX(1);
endX = inParams.dataX(end);
lSmpIntrvl = inParams.dataX(2)-inParams.dataX(1);
rSmpIntrvl = inParams.dataX(end)-inParams.dataX(end-1);
dataX = [strtX-(numPadL:-1:1)*lSmpIntrvl,...
         inParams.dataX(:)',...
         endX+(1:numPadR)*rSmpIntrvl];
dataY = [padL,...
         inParams.dataY(:)',...
         padR];
nbrksVec = inParams.nBrks;
rminVal = 0;%dataX(1);
rmaxVal = 1;%dataX(end);
rGain = inParams.rGain;

nSamples = length(dataY);
% rngX = dataX(end)-dataX(1);

outStruct = struct('totalFuncEvals',[],...
                   'bestLocation',[],...
                   'bestFitness',[]);
allResults = struct('allRunsOutput',struct('fitVal', [],...
                                           'brkPts',[],...
                                           'bsplCoeffs',[],...
                                           'estSig',zeros(1,nSamples),...
                                           'totalFuncEvals',[],...
                                           'mltplct',[]),...
                    'nBrks',[],...
                    'bestRun',[],...
                    'bestFitVal',[],...
                    'bestSig', zeros(1,nSamples),...
                    'bestBrks',[],...
                    'bestBrksMltplct',[],...
                    'AIC',[],...
                    'BIC',[]);
                
for lpbrks = 2:length(nbrksVec)
    allResults(lpbrks) = allResults(1);
    for lpruns = 2:nRuns
        allResults(lpbrks).allRunsOutput(lpruns) = allResults(lpbrks).allRunsOutput(1);
    end
end
for lpruns = 2:nRuns
    outStruct(lpruns) = outStruct(1);
end

params = struct('dataY',dataY,...
                  'dataX', dataX,...
                  'nBrks',[],...
                  'rmin',[],...
                  'rmax',[],...
                  'rGain',rGain);

aicVec = zeros(1,length(nbrksVec));
bicVec = zeros(1,length(nbrksVec));

for lpbrks = 1:length(nbrksVec)
    %Parameters for fitness function
    nbrks4Srch = inParams.nBrks(lpbrks);
    nBsplines = nbrks4Srch+2; 
    nDim = nbrks4Srch;
    allResults(lpbrks).nBrks = nDim;
    params.nBrks = nbrks4Srch;
    params.rmin = rminVal*ones(1,nDim);
    params.rmax = rmaxVal*ones(1,nDim);
    params.rGain = rGain;
    fHandle = @(x) shpsfitFKM(x,params);
    %Run PSO    
    parfor lpruns = 1:nRuns
    %for lpruns = 1:nRuns
        %Reset random number generator for each worker
        rng(lpruns);
        outStruct(lpruns)=crcbpso(fHandle,nDim,psoParams,outputLvl);
    end
    %Prepare output
    fitVal = zeros(1,nRuns);
    estSig = zeros(nRuns,nSamples);
    brkPts = zeros(nRuns,nbrks4Srch);
    mltplct = zeros(nRuns,nbrks4Srch);
    bsplCoeffs = zeros(nRuns,nBsplines);
    for lpruns = 1:nRuns
        fitVal(lpruns) = outStruct(lpruns).bestFitness;
        [~,brkPts(lpruns,:),bsplCoeffs(lpruns,:),estSig(lpruns,:),mltplct(lpruns,:)] = fHandle(outStruct(lpruns).bestLocation);
        allResults(lpbrks).allRunsOutput(lpruns).fitVal = fitVal(lpruns);
        allResults(lpbrks).allRunsOutput(lpruns).brkPts = brkPts(lpruns,:);
        allResults(lpbrks).allRunsOutput(lpruns).bsplCoeffs = bsplCoeffs(lpruns,:);
        %Remove padding
        allResults(lpbrks).allRunsOutput(lpruns).estSig = estSig(lpruns,(numPadL+1):(end-numPadR));
        allResults(lpbrks).allRunsOutput(lpruns).totalFuncEvals = outStruct(lpruns).totalFuncEvals;
        allResults(lpbrks).allRunsOutput(lpruns).mltplct = mltplct(lpruns,:);
    end
    %Find the best run
    [~,bestRun] = min(fitVal(:));
    allResults(lpbrks).bestRun = bestRun;
    allResults(lpbrks).bestFitVal = allResults(lpbrks).allRunsOutput(bestRun).fitVal;
    allResults(lpbrks).bestSig = allResults(lpbrks).allRunsOutput(bestRun).estSig;
    allResults(lpbrks).bestBrks = allResults(lpbrks).allRunsOutput(bestRun).brkPts;
    allResults(lpbrks).bestBrksMltplct = allResults(lpbrks).allRunsOutput(bestRun).mltplct;
    %Get the AIC value
    %AIC = 2*#parameters -2*ln(max(likelihood))
    %Number of parameters: nDim breakpoints + nDim b-spline coefficients
    aicVec(lpbrks) = 2*(2*nDim) + allResults(lpbrks).bestFitVal^2;
    allResults(lpbrks).AIC = aicVec(lpbrks);
    %BIC values
    %BIC = ln(nSamples)*#parameters - 2*ln(max(likelihood))
    bicVec(lpbrks) = log(nSamples)*(2*nDim) + allResults(lpbrks).bestFitVal^2;
    allResults(lpbrks).BIC = bicVec(lpbrks);
end

%Best model results
[~,bestMdlIndx] = min(aicVec);
[~,BICbestMdlIndx] = min(bicVec);
bestMdlResults = struct('bestModelNum',bestMdlIndx,...
                        'bestModelSig',allResults(bestMdlIndx).bestSig,...
                        'bestModelnBrks',allResults(bestMdlIndx).nBrks,...
                        'bestModelBrkPts',allResults(bestMdlIndx).bestBrks,...
                        'bestModelMltplct',allResults(bestMdlIndx).bestBrksMltplct,...
                        'bestModelAIC', allResults(bestMdlIndx).AIC,...
                        'BICModelNum',BICbestMdlIndx,...
                        'BICModelSig',allResults(BICbestMdlIndx).bestSig,...
                        'BICbestModelnBrks',allResults(BICbestMdlIndx).nBrks,...
                        'BICbestModelBrkPts',allResults(BICbestMdlIndx).bestBrks,...
                        'bestModelBIC', allResults(BICbestMdlIndx).BIC);



