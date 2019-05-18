function [E0,Neq,deltaEOverN]=EstimateNeq(E,N,ok)
% [E0,Neq,deltaEOverN]=EstimateNeq(E,N,ok);
% We estimate the best linear fit of E vs N, 
%    E = k*(N+Neq)
% where E0=k*Neq is E in zero noise. Thus k=E0/Neq and
%    E = (E0/Neq)*(N+Neq)
% This fails in the special case of the ideal observer, for whom E0 and Neq
% are both zero. So we also return deltaEOverN=(E-E0)/N, representing the
% fit
%    E = deltaEOverN*(N+Neq)
% Our fit takes into account the conservation of sd of log E. The
% minimization begins with a quick guess that is a linear regression that
% doesn't take that into account (i.e. assuming conservation of sd of E,
% not log E). We use the regression result as a starting point for the
% minimization. We constrain the solution to nonnegative values of E0 and
% Neq. We use the optional logical array "ok", to ignore bad thresholds.
%
% It was making terrible fits. mincon with the default algorithm often gave
% wrong answers. Using the option to select the 'sqp' algorithm helped a
% lot. We now try an unconstrained fit first, which is more reliable, and
% only if the answer is out of bounds do we try the constrained fit.
%
% When the data are nearly flat, the best fit requires a large Neq. If the
% slope is negative then the best fitting Neq is negative. In that
% situation the best legal fit (positive Neq) is a large Neq, but the
% minimizing fits don't find the large Neq solution if you seed it with
% small Neq. That's why we take the absolute value of Neq in choosing a
% seed for the next fit.
%
% May 2019. This function was formerly parameterized by E0 and Neq. It
% could not fit the ideal, for which both are zero. I reparameterized using
% E0 and deltaEOverN. I hope this will now handle all cases.
%
% May 2018. denis.pelli@nyu.edu
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
end
assert(all(size(N)==size(E)),'E and N must have same size.');
assert(all(size(ok)==size(E)),'E and "ok" must have same size.');
assert(all(N>=0),'N must not be negative.');
assert(all(E>=0),'E must not be negative.');
if size(E,2)>1
    E=E';
    N=N';
    ok=ok';
end
if size(E,2)~=1
    error('E and N should be vectors, yet have size %dx%d.',size(E));
end

% Omit thresholds that are not ok.
E=E(ok);
N=N(ok);

% E=b(1)+b(2)*N; % Regression equation.
w=warning('OFF','MATLAB:singularMatrix');
b=[ones(size(N)) N]\E; % Regress.
warning(w);
E0=b(1); % Guess E0
deltaEOverN=b(2); % Guess deltaEOverN
Neq=E0/deltaEOverN; % Guess Neq
if printFit
    fprintf('Initial regression, Neq %.2g, E0 %.2g, rms error of log E %.2g\n',Neq,E0,Cost(E,N,E0,Neq));
end
E0=max(E0,eps); % Impose positivity on the guess, so mincon won't fail.
deltaEOverN=abs(deltaEOverN); % Impose positivity on the guess, so mincon won't fail.
% Neq=abs(Neq); % Impose positivity on the guess, so mincon won't fail.
fun=@(b) Cost(E,N,b(1),b(2));
opts=optimset('TypicalX',[0.1 1e-6],'MaxFunEvals',1e6);
b=fminsearch(fun,[E0 deltaEOverN],opts); % Unconstrained fit.
E0=b(1);
deltaEOverN=b(2);
if printFit
    fprintf('fminsearch fit, deltaEOverN %.2g, E0 %.2g, rms error of log E %.2g\n',deltaEOverN,E0,Cost(E,N,E0,Neq));
end
% The unconstrained fit is more reliable, so we use its answer when it's in
% bounds. If it's out of bounds, then we run a constrained fit.
if E0<0 || deltaEOverN<0
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
        fprintf('mincon fit, deltaEOverN %.2g, E0 %.2g, rms error of log E %.2g\n',deltaEOverN,E0,Cost(E,N,E0,deltaEOverN));
    end
end
cost=Cost(E,N,E0,deltaEOverN);
if cost>0.5
    warning('The rms error in fitting log E is %.2f, which is terribly large. E0 %.2g, deltaEOverN %.2g',cost,E0,deltaEOverN);
end
deltaEOverN=b(2);
end

function cost=Cost(E,N,E0,deltaEOverN)
% Compute RMS error in predicting log E. We use log because the sd of
% measurement is approximately conserved in log E, and not in E.
modelE=E0+deltaEOverN*N;
cost=sqrt(mean(log10(E./modelE).^2));
end