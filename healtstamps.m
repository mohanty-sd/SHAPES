function hldTVals = healtstamps(tmin,tmax,minGapTime,ckTVals,varargin)
%Rectify time stamps to ensure minimum gap
%T = HEALTSTAMPS(T1,T2,M,V)
%Return a vector T, with the same length as V, containing a new set of time
%values such that there is a minimum gap between consecutive values. T1 and
%T2 are the minimum and maximum time boundaries and M is the desired
%minimum gap.
%
%
%T = HEALTSTAMPS(T1,T2,M,V,TOL)
%Compares the difference between a gap and M against TOL to check if the
%gap is less than M. The default value of TOL is 1e-4*M.

%Soumya D. Mohanty, July 2013

tol = 1e-4*minGapTime;
if nargin > 4
    tol = varargin{1};
end
%Healing is not possible if there is insufficient space between the ends
if (length(ckTVals)+1)*minGapTime > tmax-tmin
    error('Bad minimum gap');
end

%Initial assumption is that the time values are OK
hldTVals = ckTVals;
if ~any(minGapTime-diff([tmin,hldTVals,tmax])>tol)
    return;
end

%Distances to left and right particles
nPoints = length(hldTVals);

while any(minGapTime-diff([tmin,hldTVals,tmax])>tol)
    ld = hldTVals-[tmin,hldTVals(1:(end-1))];
    rd = [hldTVals(2:end),tmax]-hldTVals;
    ld = min([ld;minGapTime*ones(1,nPoints)]);
    rd = min([rd;minGapTime*ones(1,nPoints)]);
    %"Force": positive means move to the right (more gap on the right than
    %left) and negative means move to the left (more gap on the left than
    %right)
    frc = rd-ld;
    %Exreme points cannot move closer to the boundaries if the existing gap
    %is already <= minimum gap
    if (minGapTime-ld(1)) > tol && frc(1) < 0
        frc(1)=0;
    end
    if (minGapTime-rd(end)) > tol && frc(end) > 0
        frc(end) = 0;
    end
    %update positions
    hldTVals = sort(hldTVals+frc);
end
