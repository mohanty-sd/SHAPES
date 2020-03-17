function [fitVal,varargout] = shpsfitFKM(xVec,params)
%fitness function for SHAPES with FKM options 
%F = SHPSFITFKM(X,P) 
%Computes the L2 norm of the difference between a data vector and the best
%fit cubic spline corresponding to the knot sequence X. The best fit is
%found using penalized least squares with a quadratic penalty on the norm
%of the b-spline coefficients. X is a row vector specifying the interior
%knots, standardized such that each element is in [0,1]. If any element in
%X is outside [0,1], F is set to infinity. 
%
%The end knots are fixed to be the boundaries of the predictor sequence
%(see below). The end B-splines are retained, allowing the fitting of
%functions that do not go to zero at the data boundaries. Knots in X that
%are closer than the minimum separation between predictor values are merged
%into a single knot with higher multiplicity. (The above settings are
%labeled as FKM.) 
%
%P is a structure with the following fields.
%     P.rmin and P.rmax  are the minimum and maxium predictor values,
%     respectively. They are used to convert X(i,j) internally before
%     computing the fitness: X(:,j) -> X(:,j)*(rmax(j)-rmin(j))+rmin(j).
%
%     P.dataX and P.dataY contain the predictor sequence and the
%     corresponding data (outcome) values, respectively. P.dataX is assumed
%     to be in ascending order and the values are assumed to be regularly
%     spaced.
%
%     P.rGain >= 0 contains the gain factor for the penalty term. 
%
%[F,RC,C,S]=SHPSFITFKM(X,P)
%Returns the unstandardized knots in RC, the best-fit b-spline coefficients
%in C, and the estimated spline itself in S. If a knot X(i) was merged with
%X(i+1), RC(i+1) = NaN.
%
%[F,RC,C,S,M]=SHPSFITFKM(X,P)
%Returns the knot multiplicity sequence in M, with the number of extra
%repeated knots being M(i).
%
%If X is a R-by-N matrix, then F is an 1-by-R vector containing the fitness
%value for each row of X. Similarly, RC, C, S, and M will have rows
%corresponding to the rows of X.


%Soumya D. Mohanty
%Mar 2020: Adapted from CRCBOOKCODES / REGSPLPSPLFITFUNC.

%Number of rows = number of independent spline candidates
[nVecs,nBrks] = size(xVec);
%One fitness value for each row
fitVal = zeros(1,nVecs);

%Check for out of bound coordinates and flag them
validPts = chkstdsrchrng(xVec);
%Set fitness for invalid points to infty
fitVal(~validPts)=inf;
xVec(validPts,:) = s2rvector(xVec(validPts,:),params);

%Data values
dataX = params.dataX;
dataY = params.dataY;
%Sampling interval: predictor values are regularly spaced
smplIntrvl = dataX(2)-dataX(1);
%Regulator gain
rGain = params.rGain;
%Default number of cubic b-splines is = #interior break pts + 2.
nAllBsplines = nBrks+2;
nBsplines = nAllBsplines;
strtBspline = 1;
endBspline = nAllBsplines;

%Number of samples in the data
nSamples = length(dataX);
%Storage for the knots
brkPts = zeros(nVecs,nBrks);
%Default multiplicity of knots
mltplct = zeros(nVecs,nBrks);
%Temp arrays 
brkPtsLogTmp = false(1,nBrks-2);
mltplct4Log = zeros(1,nBrks);
brkPtsLgcl = false(1,nBrks);
brkPtsLgcl2 = false(1,nBrks);
hldEndBrkPts = zeros(1,2);
for lpc = 1:nVecs
    if validPts(lpc)
        
        strtBrkPt = dataX(1);
        stopBrkPt = dataX(end);
        
        %Interior breakpoints are not allowed to touch the start
        %and end break points to prevent excess knot multiplicity
        brkPts(lpc,:) = [strtBrkPt,...
            xVec(lpc,2:(end-1))*(stopBrkPt-strtBrkPt-2*smplIntrvl)+...
            strtBrkPt+smplIntrvl,...
            stopBrkPt];
        brkPts(lpc,:) = sort(brkPts(lpc,:));
        
        %merge interior breakpoints if needed
        [brkPtsLogTmp,mltplctTmp] = brkpts2mltplct(smplIntrvl,3,brkPts(lpc,2:(end-1)),'logOut');
        brkPtsLgcl = [true,brkPtsLogTmp,true];
        mltplct4Log = [0,mltplctTmp,0];
        %Avoid resizing arrays after merging by using NaN's
        brkPts(lpc,~brkPtsLgcl) = NaN; %==> breakpoint was absorbed
        postMrgNBrks = length(~isnan(brkPts));%Number of remaining breakpoints
        brkPtsLgclStrt = 1;%find(brkPtsLog, 1 ); %1st non-zero
        brkPtsLgclStrtNxt = find(brkPtsLgcl((brkPtsLgclStrt+1):end), 1 )+brkPtsLgclStrt; %next non-zero
        brkPtsLgclEnd = nBrks;%find(brkPtsLog, 1, 'last' ); %last non-zero
        brkPtsLgclEndPrv = find(brkPtsLgcl(1:(brkPtsLgclEnd-1)), 1, 'last'); %next to last non-zero
        %Interior breakpoints in (next non-zero):(next to last non-zero).
        brkPtsLgcl2(:)=false;
        brkPtsLgcl2(brkPtsLgclStrtNxt:brkPtsLgclEndPrv) = brkPtsLgcl(brkPtsLgclStrtNxt:brkPtsLgclEndPrv);
        %Disperse end breakpoints enough to heal interior breakpoints.
        %Make fake data ends while healing to allow the end breakpoints to
        %match the actual data ends if needed.
        endBrkPtsGap = smplIntrvl*(postMrgNBrks-1);
        hldEndBrkPts = healtstamps(dataX(1)-endBrkPtsGap+smplIntrvl,dataX(end)+endBrkPtsGap-smplIntrvl,...
            endBrkPtsGap, ...
            [brkPts(lpc,brkPtsLgclStrt),...
            brkPts(lpc,brkPtsLgclEnd)]);
        brkPts(lpc,brkPtsLgclStrt) = hldEndBrkPts(1);
        brkPts(lpc,brkPtsLgclEnd) = hldEndBrkPts(2);
        %Heal interior breakpoints
        brkPts(lpc,brkPtsLgcl2) = ...
            healtstamps(brkPts(lpc,brkPtsLgclStrt),...
            brkPts(lpc,brkPtsLgclEnd),...
            smplIntrvl,...
            brkPts(lpc,brkPtsLgcl2));
        mltplct(lpc,brkPtsLgcl) = mltplct4Log(brkPtsLgcl);
    end
end



%Transfer matrix for the calculation of the best coefficients
gMat = zeros(nBsplines);
%Matrix of bspline coefficients
coeffMat = zeros(nBsplines,nVecs);
for lpc = 1:nVecs
    if validPts(lpc)
        %Generate B-splines
        %-------------------
        %Note: Nan's may be present if knots were merged 
        %FIXME the ISNAN operation should be done only once
        bVals = dbrbspline(dataX,brkPts(lpc,~isnan(brkPts(lpc,:))),4,...
                           mltplct(lpc,~isnan(brkPts(lpc,:))));
        
        %Construct the transfer matrix for this set of b-splines. The (i,p)
        %element is sum_k b_i(t_k)b_p(t_k), where b_s(t) is the s'th b-spline
        %function for this set of knots.
        for lpc2 = strtBspline:endBspline
            gMatRo = lpc2-strtBspline+1;
            for lpc3 = lpc2:endBspline
                gMatCol = lpc3-strtBspline+1;
                gMat(gMatRo,gMatCol) = bVals(lpc2,:)*bVals(lpc3,:)';
                gMat(gMatCol,gMatRo) = gMat(gMatRo,gMatCol);
            end
        end
        %The source term
        fMat = bVals(strtBspline:endBspline,:)*dataY';
        %Residual sum squared from penalized least squares
        [rss,coeffMat(:,lpc)] = rss4rgain(rGain, dataY,...
                                  bVals(strtBspline:endBspline,:),...
                                  fMat, gMat);
        fitVal(lpc) = sqrt(rss);
    end
end

%Optional output
if nargout > 1
    %Real coordinates (internal knots only)
    varargout{1} = brkPts;
    if nargout > 2
        varargout{2} = coeffMat;
        if nargout > 3
            estSig = zeros(nVecs,nSamples);
            for lpc = 1:nVecs
                if validPts(lpc)
                    %Generate the candidate signal                    
                    bVals = dbrbspline(dataX,brkPts(lpc,~isnan(brkPts(lpc,:))),...
                                       4,mltplct(lpc,~isnan(brkPts(lpc,:))));                            
                    estSig(lpc,:) = coeffMat(:,lpc)'*bVals(strtBspline:endBspline,:);
                end
            end
            varargout{3} = estSig;
            if nargout > 4
                varargout{4} = mltplct;
            end
        end
    end
end


end

function [rss,coeffMat] = rss4rgain(rGain, dataY, bVals, fMat, gMat)
    %Compute the residual sum squared for a given regulator gain. Returns
    %the rss and the solution.
    gMat = gMat + rGain*eye(size(gMat));
    %Solve for the coefficients
    coeffMat = gMat'\fMat;
    %Generate the candidate signal
    ppsig = coeffMat'*bVals;
    %plot(dataX,ppsig,'k');
    %Construct the L2 norm of the residual
    rss = norm(dataY-ppsig)^2;
end
