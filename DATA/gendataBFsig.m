function [] = gendataBFsig(nRlz,nSig,snrVal,varargin)
%Generate simulation data with different types of benchmark signals
%GENDATABFSIG(N,Nsig,SNR)
%N is the number of data realizations to generate. Each realization is
%stored out in a separate .mat file: Realization i is stored in a file
%named 'inFile_i.mat'. Nsig is the benchmark signal serial number: 1 to 6
%refer to GIBF and 7 to 10 refer to SMBF signals. SNR is the signal to noise
%ratio of the signal in zero mean white Gaussian noise with unit variance. 
%
%GENDATABFSIG(N,Nsig,SNR,D) 
%D is the path to folder where the data realization files will be stored.
%Set D to '' to invoke its default value, which is the current working
%directory. D should be created, if it does not exist, before passing it to
%this function.
%
%GENDATABFSIG(N,Nsig,SNR,D,S)
%S is the path to folder containing the benchmark signal files. Set S to ''
%to invoke its default value, which is the current working directory.
%
%GENDATABFSIG(N,Nsig,SNR,D,S,P)
%P is The number of WGN samples to pad the data with at each end. This
%padding helps in signal estimation when the signal doe not terminate
%smoothly at zero. The padding should be taken into account during
%post-processing. Set to [] to invoke the default value of 2.

%Soumya D. Mohanty, May 2019
%Mar 2020: Modified for simplicity of usage

countOptargs = 1;
simDataDir = '.';
if nargin > 3
    if ~isempty(varargin{countOptargs})
        simDataDir = varargin{countOptargs};
    end
end
countOptargs = countOptargs+1;
sigDir = '.';
if nargin > 4
    if ~isempty(varargin{countOptargs})
        sigDir = varargin{countOptargs};
    end
end    
countOptargs = countOptargs+1;
numPad = 2;
if nargin > 5
    if ~isempty(varargin{countOptargs})
        numPad = varargin{countOptargs};
    end
end   

%Construct input parameter struct for GENSIMDATA
inParams = struct('snr',snrVal,...
                   'sigFile','',...
                   'numPad',numPad);
%Resolve benchmark function from its serial number
[sigType,sigIndx] = bnchmrksiginfo(nSig);
inParams.sigFile = [sigDir,filesep,sigType,num2str(sigIndx)];

gensimdata(nRlz,simDataDir,inParams);

