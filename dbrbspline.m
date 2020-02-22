function bsplMat = dbrbspline(dataX,brkPts,bsplOrdr,varargin)
%B-splines using de Boor's algorithm: ch. X, "Practicle guide to Splines"
%Y=DBRBSPLINE(X,B,K)
%X is the row vector of independent variable values at which to evaluate
%B-splines. (X is assumed to be strictly ascending.) B is the row vector of
%breakpoints in strictly ascending order (B(1)>= X(1) and B(end)<=X(end)).
%K is the order of the B-spline polynomial (order = degree + 1). The
%B-splines are returned as rows of the matrix Y, with Y(i,:)<-B-spline with
%index i-1.
%
%Y=DBRBSPLINE(X,B,K,M)
%The number of repetitions of B[i] can be specified in M[i], M[1<i<end] <=
%K-1.  M[i] = 1 means B[i] appears twice. (Note: M[1] and M[end] are always
%set to K-1 irrespective of their supplied values.) Setting M to []
%invokes the default value of [K-1,zeros(2,length(B)-1),K-1].
%
%The total number of knots is L = length(B) + sum(M). The number of
%B-splines returned is L-K.

%Soumya D. Mohanty, Apr 2019

nSamples = length(dataX);
nBrks = length(brkPts);

if any(diff(dataX)<= 0)
    error('X values must be strictly ascending')
end

if nBrks < 2
    error('Insufficient number of breakpoints');
end

if brkPts(1)<dataX(1) || brkPts(end) > dataX(end)
    error('Breakpoints cannot lie outside X range');
end

%Breakpoint multiplicity
bsplDeg = bsplOrdr-1;
mltplct = [bsplDeg,zeros(1,nBrks-2),bsplDeg];
nreqArgs = 3;
%Optional input handling
for lpargs = 1:(nargin-nreqArgs)
    if~isempty(varargin)
        switch lpargs
            case 1
                %Never overwrite the end multiplicities
                mltplct(2:(end-1)) = varargin{1}(2:(end-1));
            otherwise
                error('Excess number of optional inputs');
        end
    end
end

if any(mltplct > bsplDeg)
    error('Excess breakpoint multiplicity');
end


%Knots
nKnts = nBrks + sum(mltplct);
kntPts = zeros(1,nKnts);
countKnots = 1;
%Initialize pairing sequence for j (REGRESSION_NOTES/bsplines.tex)
%1 if kntPts(i+j-1) not equal to kntPts(i) and zero otherwise
if bsplDeg
    pairVecs = ones(bsplDeg,nKnts-1);
    pairVecs(:,(nKnts-bsplDeg):end)=0;
else
    %No recursion will happen for bsplOrdr = 1 so don't need it
    pairVecs = [];
end
%Breakpoint repitions are prepended except at the end where they are
%appended
for lp = 1:(nBrks-1)
    kntPts(countKnots:(countKnots+mltplct(lp))) = brkPts(lp);
    %Assign pairing sequence values
    for lpk = 1:mltplct(lp)
        pairVecs(lpk,countKnots:(countKnots+mltplct(lp)-lpk)) = 0;
    end
    countKnots = countKnots+mltplct(lp)+1;
end
kntPts(countKnots:end) = brkPts(end);
%Logical array needed for indexing purpose
pairVecs = logical(pairVecs);


%Assign knot indices to x values; negative knot index indicates x value
%outside the breakpoint range
kntIndx4x = -ones(1,nSamples);
validIndx = find(dataX >= brkPts(1) & dataX <= brkPts(end));
strtIndx = validIndx(1);
endIndx = validIndx(end);
for lp = 1:(nKnts-1)
    xInFlag = sum(dataX(strtIndx:endIndx) >= kntPts(lp) & ...
                  dataX(strtIndx:endIndx) < kntPts(lp+1));
     if xInFlag
         %x value between non-repeating knots
        kntIndx4x(strtIndx:(strtIndx+xInFlag-1))=lp;
        %Move to higher values of x
        strtIndx = strtIndx+xInFlag;
     else
         %x between repeating knots; do not move along x array
     end 
end

%Number of B-splines
nBspl = nKnts - bsplOrdr;
bsplMat = zeros(nBspl,nSamples);

%Precompute denominator sequences 
omgDen = zeros(bsplDeg,nKnts-1);
tmpVec = zeros(size(kntPts));
for lp = 1:bsplDeg
    tmpVec(:) = 0;
    %Shift the knot sequence
    tmpVec(1:(end-lp)) = kntPts((lp+1):end);
    %Denominator is non-zero only if the pairing sequence value is 1
    omgDen(lp,pairVecs(lp,:)) = 1./(tmpVec(pairVecs(lp,:))-kntPts(pairVecs(lp,:)));
end
%Gamma denominator = shifted omega denominator
gamDen = zeros(size(omgDen));
gamDen(:,1:(end-1)) = omgDen(:,2:end);

%Recursion: current order k -->
%B_{j,k} = (x-tau_j)*B_{j,k-1}*omgDen(i)+(tau_{j+k}-x)B_{j+1,k-1}*gamDen(j)
%For each x and corresponding knot index i, i-(k-1)<= j <= i.
%---------------------------------
%For each x and k >=2, recursion overwrites a section of bsplMat that is
%bsplOrdr rows tall. Calling this section 'holdCol', the following is the
%storage scheme:
%holdCol(bsplOrdr-m) <- B_{i-m,k}, 0 <= m <= k-1
for lpsmp = validIndx
    %Current value of x
    x = dataX(lpsmp);
    %knot index i
    knotI = kntIndx4x(lpsmp);
    if knotI > 0
        
        %Initialize storage with B_{i,1} = 1
        bsplMat(knotI, lpsmp)=1;%holdCol(bsplOrdr)=1;
        
        %Recursion in decreasing values of m (see above)
        for currOrdr = 2:bsplOrdr
            
            %Row from bottom: rFb = m+1 = k ...
            rFb = currOrdr;
            
            %... corresponding actual row index (from top)
            truRo = knotI-(rFb-1);
            
            subtrctIndx = rFb-1; % = m
            
            %j = i - m
            currKnotI = knotI-subtrctIndx;
            
            %tau_{j+k}
            kntPt4gam = kntPts(currKnotI+currOrdr);
            
            bsplMat(truRo, lpsmp) = gamDen(currOrdr-1,currKnotI)*(kntPt4gam-x)*...
                                            bsplMat(truRo+1, lpsmp);
            
            %Recursion for 0< m < k-1
            for rFb = (currOrdr-1):-1:2
                truRo = knotI-(rFb-1);
                subtrctIndx = rFb-1;
                currKnotI = knotI-subtrctIndx;
                kntPt4omg = kntPts(currKnotI);
                kntPt4gam = kntPts(currKnotI+currOrdr);
                bsplMat(truRo, lpsmp) = omgDen(currOrdr-1,currKnotI)*(x-kntPt4omg)*bsplMat(truRo, lpsmp) + ...
                                        gamDen(currOrdr-1,currKnotI)*(kntPt4gam-x)*bsplMat(truRo+1, lpsmp);
            end
            %m = 0
            truRo = knotI;
            currKnotI = knotI;
            kntPt4omg = kntPts(currKnotI);
            bsplMat(truRo, lpsmp) = omgDen(currOrdr-1,currKnotI)*(x-kntPt4omg)*bsplMat(truRo, lpsmp);
        end
    end
end