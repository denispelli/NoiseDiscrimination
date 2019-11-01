function [Neq,E0,deltaEOverN]=EstimateNeq(E,N,ok)
% [Neq,E0,deltaEOverN]=EstimateNeq(E,N,ok);
% Given equal-length vectors E and N, estimate the best linear fit of
%    E = deltaEOverN*(N+Neq),
% where deltaEOverN and Neq are fitted constants, contrained to be
% nonnegative. Our fit takes into account the conservation of sd of log E
% across values of E and N. The minimization begins with a quick guess, a
% linear regression, that doesn't take that conservation into account (i.e.
% assuming conservation of sd of E, not log E). We use the regression fit
% as a starting point for the minimization. We constrain the solution to
% nonnegative values of E0 and Neq. We use the optional logical array "ok",
% to ignore bad thresholds. We also return E0=deltaEOverN*Neq, which is the
% estimated threshold E in zero noise. Note that Neq and E0 are zero for
% the ideal observer, though this algorithm won't explicitly know when you
% give it data from the ideal observer.
%
% In fact, the above equation is a two-parameter fit, but sometimes we
% receive only one measurement, leaving the fit unconstrained. A better
% approach is to instead fit the equation
%    E = E0+deltaEOverN*N,
% We also return Neq=E0/deltaEOverN. For most cases the two equations are
% equivalent, but the latter has the advantage of coping when we only know
% E at N=0, or when E is monotonically decreasing as N increases. In those
% cases we can't estimate deltaEOverN or Neq, which we set to NaN, but we
% still can estimate E0.
%
% The mincon function using the default algorithm often gave wrong answers.
% Using the option to select the 'sqp' algorithm helped a lot. We now try
% an unconstrained fit first, which is more reliable, and only if the
% answer is out of bounds do we try the constrained fit.
%
% When the E vs. N data are nearly flat, the best fit requires a large Neq.
% If the slope is negative then the best fitting Neq is negative. In that
% situation the best legal fit (positive Neq) is a large Neq, but the
% minimizing fits won't find the large Neq solution if you seed it with
% small Neq. That's why we take the absolute value of Neq in choosing a
% seed for the next fit.
%
% October 16, 2019. Discovered and fixed a bug. If the parameters E0 or
% deltaEOverN went negative during the minimization then the cost, which is
% based on log E, became complex and the cost minimization gave crazy
% results. We now make the cost (real) infinite whenever E0 or deltaEOverN
% is negative, and we now get reasonable fits in all cases, as far as I
% know. It would be a good idea to recompute all Neq estimates made by
% this routine.
%
% denis.pelli@nyu.edu

if false
    % Data for debugging.
    N=[0.00018628 0  0.00027579 0   0.00027579 0];
    E=[0.0026637 8.4782e-06  0.0041035 8.8371e-06 0.0041089 8.8371e-06];
    
    % Warning: observer "s c", conditionName "gabor;M=104", deltaEOverN<1, deltaEOverN 1.1e-05
    % E=[0.32 0.41 ];
    % N=[0.00028 0 ];
    plot(N,E,'*');
    xlabel('N (deg^2)');
    ylabel('E (deg^2)');
end
printFit=false;
if nargin<3
    ok=isfinite(E); % Ignore NaN and inf data.
end
switch sum(ok(:))
    case 0
        E0=nan;
        Neq=nan;
        deltaEOverN=nan;
        return
    case 1
        E0=E(ok);
        Neq=nan;
        deltaEOverN=E(ok)/N(ok);
        return
    otherwise
end
assert(all(size(N)==size(E)),'E and N must have same size.');
assert(all(size(ok)==size(E)),'E and "ok" must have same size.');
assert(all(N>=0),'N must not be negative.');
assert(all(E>=0),'E must not be negative.');
if size(E,1)~=1 && size(E,2)~=1
    error('E and N should be vectors, but they have size %dx%d.',size(E));
end
if size(E,2)>1
    E=E';
    N=N';
    ok=ok';
end
% Omit thresholds that are not ok.
E=E(ok);
N=N(ok);
assert(all(isfinite(N)),'Some values in vector N are not finite.');

%% Sort, so N is increasing.
[~,ii]=sort(N);
N=N(ii);
E=E(ii);

%% RETURN IF NO DATA
if isempty(N)
    E0=nan;
    Neq=nan;
    deltaEOverN=nan;
    return
end

%% THE SPECIAL CASE OF THRESHOLD E THAT DOES NOT INCREASE WITH N.
% A fairly common special case, in noisy data with few noise levels, is
% that the threshold E is a not-increasing function of N. In that case the
% best fit is a horizontal line E=E0, where E0 is the geometric mean of the
% measured thresholds E. Neq has only a lower bound, to be much greater
% than the highest noise tested, Neq>>max(N). And
% deltaEOverN=E0/Neq<<E0/max(N). Since they lack useful point estimates, we
% set both to NaN.
hasMultipleN=length(unique(N))>1;
hasMultipleE=~all(diff(E)<=0);
if ~hasMultipleE || ~hasMultipleN
    % The data determine at most E0.
    if hasMultipleN || all(N==0)
        % The data determine just E0.
        E0=10^mean(log10(E));
    else
        % The data determine none of our parameters.
        E0=nan;
    end
    Neq=nan;
    deltaEOverN=nan;
    return
end

%% 1. USE REGRESSION
% E=b(1)+b(2)*N; % Regression equation.
w=warning('OFF','MATLAB:singularMatrix');
b=[ones(size(N)) N]\E; % Regress.
warning(w);
E0=b(1); % Guess E0
deltaEOverN=b(2); % Guess deltaEOverN
Neq=E0/deltaEOverN; % Guess Neq
if printFit
    modelE=E0+deltaEOverN*N;
    rms=sqrt(mean((E-modelE).^2));
    fprintf('Initial regression, deltaEOverN %.2g, E0 %.2g, rms error of E %.2g, rms error of log E %.2g\n',...
        deltaEOverN,E0,rms,Cost(E,N,E0,deltaEOverN));
end
%% 2. USE fminsearch WITH POSITIVITY ENFORCED IN OUR COST FUNCTION
E0=max(E0,eps); % Impose positivity on the guess, so mincon won't fail.
deltaEOverN=abs(deltaEOverN); % Impose positivity on the guess, so mincon won't fail.
fun=@(b) Cost(E,N,b(1),b(2));
opts=optimset('TypicalX',[0.1 1e-6],'MaxFunEvals',1e6);
b=fminsearch(fun,[E0 deltaEOverN],opts); % Unconstrained fit.
E0=b(1);
deltaEOverN=b(2);
if printFit
    modelE=E0+deltaEOverN*N;
    rms=sqrt(mean((E-modelE).^2));
    fprintf('fminsearch fit, deltaEOverN %.2g, E0 %.2g, rms error of E %.2g, rms error of log E %.2g\n',...
        deltaEOverN,E0,rms,Cost(E,N,E0,deltaEOverN));
end
% The unconstrained fit is more reliable, so we use its answer when it's in
% bounds. If it's out of bounds, then we run a constrained fit.
if E0<0 || deltaEOverN<0
    %% 3. USE fmincon WITH EXPLICIT POSITIVITY CONSTRAINT (AND COST FUNCTION)
    unconstrainedCost=Cost(E,N,E0,deltaEOverN);
    E0=max(eps,E0);
    deltaEOverN=abs(deltaEOverN);
    % The choice of algorithm is key. With the default algorithm I was
    % getting terrible fits. 'sqp' works well.
    opts=optimoptions('fmincon','Display','off','Algorithm','sqp','TypicalX',[0.1 1e-6]);
    w=warning('OFF','MATLAB:singularMatrix');
    b=fmincon(fun,[E0 Neq],[],[],[],[],[eps eps],[inf inf],[],opts); % Search constrains E0 and Neq to not be negative.
    warning(w);
    E0=b(1);
    deltaEOverN=b(2);
    if printFit
        modelE=E0+deltaEOverN*N;
        rms=sqrt(mean((E-modelE).^2));
        fprintf('mincon fit, deltaEOverN %.2g, E0 %.2g, rms error of E %.2g, rms error of log E %.2g\n',...
            deltaEOverN,E0,rms,Cost(E,N,E0,deltaEOverN));
    end
end
cost=Cost(E,N,E0,deltaEOverN);
if cost>0.5
    warning('The rms error in fitting log E is %.2f, which is terribly large. E0 %.2g, deltaEOverN %.2g',cost,E0,deltaEOverN);
    fprintf('deltaEOverN %.1f, Neq %.2g, E0 %.2g, RMS error in log E %.1f\n',...
        deltaEOverN,Neq,E0,Cost(E,N,E0,deltaEOverN));
    x.N=N;
    x.E=E;
    x.modelE=E0+deltaEOverN*N;
    struct2table(x)
end
deltaEOverN=b(2);
end

function cost=Cost(E,N,E0,deltaEOverN)
% Compute RMS error in predicting log E. We use log because the sd of
% measurement is approximately conserved in log E, and not in E. Positivity
% of E0 and deltaEOverN is enforced by returning infinite cost if either is
% negative.
modelE=E0+deltaEOverN*N;
if E0<0 || deltaEOverN<0
    cost=inf;
    return
end
cost=sqrt(mean(log10(E./modelE).^2));
end