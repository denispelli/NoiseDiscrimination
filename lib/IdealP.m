function [p,err]=IdealP(signal,contrast,noiseSd,options)
% Returns the ideal observer's probability of correct identification of 1
% of n arbitrary signals in the presence of white noise with given standard
% deviation. This is the exact solution, evaluated by a MATLAB routine that
% numerically integrates the multivariate normal distribution.
%
% signal is a struct array, each element has a field called "image":
% signal(1).image, signal(2).image, etc. All the images must be of the same
% size. "contrast" is a scalar applied to the image before the noise is
% added. noiseSd is the standard deviation of the white gaussian noise
% added to each pixel of the signal image. Returns proportion correct p.
%
% IdealP now takes 0.5 s, all together, to call mvncdf 9 times (once per
% signal) with the tolerance set to 1e-3. (In limited testing the accuracy
% seems to be about a factor of ten better than the nominal tolerance.) The
% time to process 9 signals rises to 6 s with the tolerance set to 1e-4,
% and 36 s with tolerance set to 1e-5 (MATLAB default tolerance for
% mvncdf). By default IdealP sets the tolerance to 1e-3, but you can
% optionally provide an options struct that will be passed to mvncdf. It
% seems to run until its estimated error "err" is smaller than the
% specified tolerance.
% 
% Note that the computing time depends strongly on the number of signals, and essentially not at all on the size of the signal images.
% That's because the images themselves don't matter. All that matters is their cross correlation, and that's all we provide to
% the MATLAB function that does the hard numerical integration of the multivariate normal distribution.
%
% We calculate the covariance function of all the letters in the alphabet
% and use the MATLAB function mvncdf to implement the multivariate normal
% integral specified in Eq. A9 of Pelli et al. (2006). That probability is
% for a given correct k, so we would average it across all the possible
% values of k.

defaultOptions.TolFun=1e-3;
if nargin<4
    options=defaultOptions;
else
    if ~isfield(options,'TolFun')
        options.TolFun=defaultOptions.TolFun;
    end
end
variance=noiseSd^2/contrast^2;
C=zeros(length(signal));
for i=1:length(signal)
    signal(i).image=double(signal(i).image);
    for j=1:i
        C(i,j)=dot(signal(i).image(:),signal(j).image(:));
        C(j,i)=C(i,j);
    end
    Cii(i)=C(i,i);
end
E=mean(Cii);
EOverN=E/variance;

d=length(signal);
x=zeros(1,d);
p=zeros(1,d);
sigma=zeros(d,d);
clear G
useEqA12=0;
% Most of the code implements Eq. A10 in Pelli et al. (2006). Optional code instead 
% implements Eq. A12. The agreement between the two answers indicates that 
% the equations are consistent with each other, and that I've implemented them 
% correctly here. The most convincing
% affirmation of the accuracy of IdealP is that it predicts th threshold p criterion
% when tested at the threshold E/N thresholds estimated by QUEST in monte carlo implementation
% of the ideal observer.
options=[];
for k=1:d
    for i=1:d
        if useEqA12
            xC(i)=0.5*sqrt((C(i,i)-2*C(i,k)+C(k,k))/variance);
        end
        G(i).image=signal(i).image-signal(k).image;
        ii=dot(G(i).image(:),G(i).image(:));
        x(i)=0.5*sqrt(ii/variance);
        for j=1:i
            if useEqA12
                sigmaC(i,j)=(C(i,j)-C(i,k)-C(k,j)+C(k,k))/sqrt( (C(i,i)-2*C(i,k)+C(k,k)) * (C(j,j)-2*C(j,k)+C(k,k)) );
                sigmaC(j,i)=sigmaC(i,j);
            end
            ij=dot(G(i).image(:),G(j).image(:));
            jj=dot(G(j).image(:),G(j).image(:));
            sigma(i,j)=ij/sqrt(ii*jj);
            sigma(j,i)=sigma(i,j);
        end
    end
    ii=(1:d)~=k; % Logical array to exclude indices equal to k
    x=x(ii); % Exclude indices equal to k.
    sigma=sigma(ii,ii); % Exclude indices equal to k.
    if isempty(options)
        [p(k),err(k)]=mvncdf(x,0,sigma);
    else
        [p(k),err(k)]=mvncdf(x,0,sigma,options);
    end
    if useEqA12
        xC=xC(ii);
        assert(all(x==xC))
        sigmaC=sigmaC(ii,ii);
        assert(all(sigma(:)==sigmaC(:)))
        [pC(k),errC]=mvncdf(xC,0,sigmaC,options);
        fprintf('p %.3f, xC %.3f, sigmaC %.2f\n',p(k),xC,sigmaC);
    end
end
p=mean(p);
err=mean(err);

% Print out the arguments to mvncdf, for debugging.
% fprintf('x\n');
% fprintf('%.3f, ',x);
%
% fprintf('\nsigma\n');
% for i=1:size(sigma,1)
%     fprintf('%.3f ',sigma(i,:));
%     fprintf('\n');
% end
% fprintf('p\n%.3f\n',p);

