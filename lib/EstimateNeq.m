function [E0,Neq]=EstimateNeq(E,N,ok)
% We estimate the best linear fit of E vs N, taking into account the
% conservation of sd of log E. The minimization begins with a quick guess
% that is a linear regression that doesn't take that into account (i.e.
% assuming conservation of sd of E, not log E). We constrain the solution
% to nonnegative values of E0 and Neq. We use the optional logical array
% "ok", to ignore bad thresholds.
%
% When the data are nearly flat, the best fit requires a large Neq. If the
% slope is negative then the best fitting Neq is negative. In that
% situation the best legal fit is a large Neq, but the minimizing fits
% don't find the large Neq solution if you seed it with small Neq. That's
% why we take the absolute value of Neq in choosing a seed for the next
% fit.
% May 2018. denis.pelli@nyu.edu
printFit=true;
if nargin<3
    ok=true(size(E));
end
switch sum(ok(:))
    case 0
        E0=nan;
        Neq=nan;
        return
    case 1
        E0=E(ok);
        Neq=nan;
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
Neq=E0/b(2); % Guess Neq
if printFit
    fprintf('Initial regression, Neq %.2g, E0 %.2g, rms error of log E %.2g\n',Neq,E0,Cost(E,N,E0,Neq));
end
E0=max(E0,eps); % Impose positivity on the guess, so mincon won't fail.
Neq=abs(Neq); % Impose positivity on the guess, so mincon won't fail.
fun=@(b) Cost(E,N,b(1),b(2));
opts=optimset('TypicalX',[0.1 1e-6],'MaxFunEvals',1e6);
b=fminsearch(fun,[E0 Neq],opts); % Unconstrained fit.
E0=b(1);
Neq=b(2);
if printFit
    fprintf('fminsearch fit, Neq %.2g, E0 %.2g, rms error of log E %.2g\n',Neq,E0,Cost(E,N,E0,Neq));
end
% The unconstrained fit is more reliable, so we use its answer when it's in
% bounds. If it's out of bounds, then we run a constrained fit.
if E0<0 || Neq<0
    unconstrainedCost=Cost(E,N,E0,Neq);
    E0=max(eps,E0);
    Neq=abs(Neq); 
    % The choice of algorithm is key. With the default algorithm I was
    % getting terrible fits. 'sqp' works well.
    opts=optimoptions('fmincon','Display','off','Algorithm','sqp','TypicalX',[0.1 1e-6]);
    w=warning('OFF','MATLAB:singularMatrix');
    b=fmincon(fun,[E0 Neq],[],[],[],[],[eps eps],[inf inf],[],opts); % Search constrains E0 and Neq to not be negative.
    warning(w);
    E0=b(1);
    Neq=b(2);
    if printFit
        fprintf('mincon fit, Neq %.2g, E0 %.2g, rms error of log E %.2g\n',Neq,E0,Cost(E,N,E0,Neq));
    end
    cost=Cost(E,N,E0,Neq);
    if cost>unconstrainedCost+0.01
        warning('The rms error in fitting log E is %.2f constrained vs. %.2f unconstrained.\n',cost,unconstrainedCost);
    end
end
end

function cost=Cost(E,N,E0,Neq)
% Compute RMS error in predicting log E. We use log because the sd of
% measurement is approximately conserved in log E, and not in E.
modelE=(E0/Neq)*(N+Neq);
cost=sqrt(mean(log10(E./modelE).^2));
end