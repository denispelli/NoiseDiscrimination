% Auxillary file for d01aj_demo.m, providing the function to be integrated.

% NAG Copyright 2009.

function [result] = d01aj_f2(x)
result = x^2*abs(sin(5*x));
