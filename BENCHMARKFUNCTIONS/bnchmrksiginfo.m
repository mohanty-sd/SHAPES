function [sigType,sigIndx] = bnchmrksiginfo(sigSrlNum)
%Benchmark signal information 
%[T,I] = BNCHMRKSIGINFO(L)
%T is a character array that identifies the class of benchmark signal, and
%I is the index of the signal within that class, corresponding to the
%linear index L. At present 1 <= L <= 10.
%   1<= L <= 6 corresponds to the benchmark functions (f_1 to f_6) in
%   Galvez, Iglesias, Comp. Aided Design (2012).
%   7 <= L <= 10 corresponds to additional benchmark functions used in the
%   CSDA 2019 paper.

%Soumya D. Mohanty, May 2019

if sigSrlNum>=1 && sigSrlNum <= 6
    sigType = 'GIBFsig';
    sigIndx = sigSrlNum;
elseif sigSrlNum>=7 && sigSrlNum <=10
    sigType = 'SMBFsig';
    sigIndx = sigSrlNum-6;
else
    error('Signal type not recognized');
end