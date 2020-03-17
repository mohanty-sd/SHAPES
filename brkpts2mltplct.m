function [combBrkPts,mltplct] = brkpts2mltplct(minGap,maxMltplct,brkPts,varargin)
%Shrink knot sequence and add multiplicity
%[T,M] = BRKPTS2MLTPLCT(G,Mm,V)
%Takes a monotonically increasing sequence of knots V and returns a
%transformed set of knots T. Subsets of knots in V that are
%within an interval G of each other are merged into one knot with a
%correspondingly increased multiplicity. The multiplicity of each
%knot in T is returned in M. The maximum multiplicity is given by Mm.
%
%[T,M] = BRKPTS2MLTPLCT(G,Mm,V,O)
%O specifies the output type. There are two choices: 'brkOut' and
%'logOut'. For O='logOut', T is a logical array of the same size as V.
%The transformed set of knots can be obtained as V(T). The
%corresponding multiplicity sequence is M(T). Set O to '' to get the
%default value of 'brkOut'.

%Soumya D. Mohanty, May 2019

nBrks = length(brkPts);

outFlg = 'brkOut';
if nargin > 3 && ~isempty(varargin{1})
    outFlg = varargin{1};
end

%Identify knots that are crowded --> their gap from the preceding
%neighbor is less than minimum gap
crdBrkPts = (minGap-diff(brkPts)) >=0;

%Return if the knots are not crowded together
if ~any(crdBrkPts)
    mltplct = zeros(size(brkPts));
    switch outFlg
        case 'brkOut'
            combBrkPts = brkPts;
        case 'logOut'
            combBrkPts = true(size(brkPts));
        otherwise
            error('Output type not recognized');  
    end
    return;
end

%Count multiplicity of knots as they are merged
countMltplct = [0,crdBrkPts];
%Crowding was found using diff so merger direction is from higher to lower
%knots
strtBrk = nBrks;
while strtBrk > 1
    nMrg = 0; %Number of mergers for this knot
    nxtBrk = strtBrk-1;
    if countMltplct(strtBrk)
        %knot is crowded with preceding knot ...
        while nxtBrk >=1 && nMrg <= maxMltplct-1 && (brkPts(strtBrk)-brkPts(nxtBrk))<=minGap
            nMrg = nMrg + 1;
            %Multiplicity of merged knot not needed
            countMltplct(nxtBrk) = 0;
            nxtBrk = nxtBrk - 1;
        end
        countMltplct(strtBrk) = nMrg;
    end
    strtBrk = nxtBrk; 
end

%Number of knots after merger
strtBrk = nBrks;
switch outFlg
    case 'brkOut'
        nBrksMrg = nBrks - sum(countMltplct);
        combBrkPts = zeros(1,nBrksMrg);
        mltplct = zeros(1,nBrksMrg);
        countCombBrks = nBrksMrg;
        while strtBrk >= 1
            combBrkPts(countCombBrks) = brkPts(strtBrk);
            mltplct(countCombBrks) = countMltplct(strtBrk);
            strtBrk = strtBrk - (countMltplct(strtBrk)+1);
            countCombBrks = countCombBrks - 1;
        end
    case 'logOut'
        combBrkPts = zeros(size(brkPts));
        mltplct = zeros(size(brkPts));
        while strtBrk >= 1
            combBrkPts(strtBrk) = 1;
            mltplct(strtBrk) = countMltplct(strtBrk);
            strtBrk = strtBrk - (countMltplct(strtBrk)+1);
        end
        combBrkPts = logical(combBrkPts);
    otherwise
        error('Output type not recognized');
end

