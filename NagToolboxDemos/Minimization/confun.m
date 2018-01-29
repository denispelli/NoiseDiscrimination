% Auxillary file for e04wd_demo.m, providing any nonlinear constraint 
% functions to be used during the minimization.

% NAG Copyright 2009.
function [mode, ccon, cjac, user] = confun(mode, ncnln, n, ldcj, needc, x, cjac, nstate, user)

% Specify the nonlinear constraint functions.  In this example, we don't
% have any of these - in fact, because ncnln, the number of non-linear 
% constraints has a value of zero in e04wd_demo, this function (confun) is 
% never actually called by e04wd.  In that case (see e04wd documentation), 
% the name of the nonlinear constraints function file can be specified as 
% 'e04wdp' in the call to e04wd, and there is no need to provide this 
% file.  Instread, in this example, we provide this dummy file to 
% illustrate the mechanism for the implementation of nonlinear constraints.
end
