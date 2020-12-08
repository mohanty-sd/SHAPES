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

%Soumya D. Mohanty, May 2019
%Mar 2020: Modified for simplicity of usage
%Dec 2020: Removed padding

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

%Construct input parameter struct for GENSIMDATA
inParams = struct('snr',snrVal,...
                   'sigFile','');
%Resolve benchmark function from its serial number
[sigType,sigIndx] = bnchmrksiginfo(nSig);
inParams.sigFile = [sigDir,filesep,sigType,num2str(sigIndx)];

gensimdata(nRlz,simDataDir,inParams);

