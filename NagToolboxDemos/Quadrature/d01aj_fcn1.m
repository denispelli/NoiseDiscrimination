% Auxillary file for d01aj_demo.m, providing the function to be integrated.

% NAG Copyright 2009.

function [result] = d01aj_f1(x)
result = x*sin(30*x)/sqrt(1.0-x^2/(4.0*pi^2));
