
%neq is the measured equivalent noise level (in deg^2).
%a is a free parameter
%b is a free parameter, perhaps about 0.3
%diameter is the letter diameter in deg.
%ecc is the eccentricity in deg.


% the fitting should minimize the RMS error of the fit. Since the standard deviation of measurement is approximately constant for LOG Neq, we should compute the RMS error in log Neq, and use that as the cost function that we minimize. So, once you've used the model to compute neqModel, the error is:

% neqModel=@(p, targetRadius, eccentricity) p(1).*max(0.5.*targetRadius, p(2).*eccentricity).^2;
neqModel=@(p, targetRadius, eccentricity) p(1).*((0.5.*targetRadius).^2+p(2)*eccentricity.^2);
cost=@(p) mean((log10(dataTable.meanNeq ./ neqModel(p, dataTable.targetSize, dataTable.eccentricity))).^2).^0.5;



% "rms" is the RMS error of the log Neq prediction. We hope it's comparable to the RMS of repeated measurement which will be roughly 0.1.
p0=[2 4 6 8 3 5 2 100];
options=optimset('MaxFunEvals',1e8,'MaxIter',1e8);
p = fminsearch(cost,p0,options);
