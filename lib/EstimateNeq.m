function [E0,Neq]=EstimateNeq(E,N)
% We estimate the best linear fit of E vs N, taking into account the
% conservation of sd of log E. The minimization begins with a guess that is
% a linear regression that doesn't take that into account (i.e. assuming
% conservation of sd of E, not log E). We constrain the solution to
% nonnegative values of E0 and Neq.
% April, 2018. denis.pelli@nyu.edu
assert(all(size(N)==size(E)),'E and N must have same size.');
assert(all(N>=0),'N must not be negative.');
assert(all(E>=0),'E must not be negative.');
if size(E,2)>1
    E=E';
    N=N';
end
if size(E,2)~=1
    error('E and N should be vectors, yet have size %dx%d.',size(E));
end
% E=b(1)+b(2)*N; % Regression equation.
w=warning('OFF','MATLAB:singularMatrix');
b=[ones(size(N)) N]\E; % Regress.
warning(w);
E0=b(1); % Guess E0
Neq=E0/b(2); % Guess Neq
E0=max(E0,eps); % Impose positivity on the guess, so mincon won't fail.
Neq=max(Neq,0); % Impose positivity on the guess, so mincon won't fail.
fun=@(b) Cost(E,N,b(1),b(2));
% b=fminsearch(fun,[E0 Neq]); % Unconstrained fit.
opts=optimoptions('fmincon','Display','off','MaxIterations',1000);
w=warning('OFF','MATLAB:singularMatrix');
b=fmincon(fun,[E0 Neq],[],[],[],[],[0 0],[inf inf],[],opts); % Search constrains E0 and Neq to not be negative.
warning(w);
E0=b(1);
Neq=b(2);
end

function cost=Cost(E,N,E0,Neq)
% Compute RMS error in predicting log E. We use log because the sd of
% measurement is approximately conserved in log E, and not in E.
modelE=(E0/Neq)*(N+Neq);
cost=sqrt(mean(log10(E./modelE).^2));
end