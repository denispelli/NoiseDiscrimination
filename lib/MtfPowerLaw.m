function w=MtfPowerLaw(n,exponent,fLow,fHigh)
% w=MtfPowerLaw(size,exponent,fLow,fHigh) returns an mtf, i.e. a matrix
% meant to be used as a filter. The squared mtf is a power law of frequency,
% with the given exponent. If you use this to filter white noise, then
% exponents of 0 and -1 will result in white and pink noise. The mtf is
% normalized so that if you apply it to white noise, within its passband
% the output noise will have the same average power spectral density as the
% input noise.
% For a symmetric mtf, use an odd size n. The matrix size is mxn if "size"
% is [m,n], and nxn if "size" is n. The matrix elements represent gain at
% each freq, uniformly spaced from about -1 to 1 of Nyquist frequency (see
% FREQSPACE). fLow and fHigh are the radial cut-off frequencies on this
% scale. The filter has gain 1 in the frequency interval [fLow,fHigh], and
% gain 0 outside it. Add EPS to create complementary filters that add to 1,
% e.g.
% 	MtfPowerLaw(n,e,0,f)+MtfPowerLaw(n,e,f+eps,1)==MtfPowerLaw(n,e,0,1)
% For circular symmetry make fHigh<=1. Setting fLow=0 and fHigh=Inf will
% produce an all-pass filter. Here's a typical use:
% 	noise=randn(n,n);
% 	filter=MtfPowerLaw(n,0,fLow/fNyquist,fHigh/fNyquist);		
% 	if any(any(filter~=1)) % skip all-pass filter
% 		ft=filter.*fftshift(fft2(noise));
% 		noise=real(ifft2(ifftshift(ft)));
% 	end
% Also see OrientationBandpass, Bandpass, Bandpass2, FREQSPACE.

% 10/5/15 dgp wrote it

if nargin~=4
	error('Usage: w=MtfPowerLaw(n,exponent,fLow,fHigh)')
end
if any(n<2) | any(n~=floor(n))
	error('First arg ''n'' must be an integer greater than 1')
end
if length(n)==1
	n=[n n];
end
if fLow<0 | fHigh<0
	error('Radial frequencies can''t be negative')
end
% handle common special case quickly
if fLow==0 & fHigh>2^0.5 & exponent==0
	w=ones(n);
	return
end
if exponent<0
    % High pass to avoid infinite gain at zero frequency.
    fLow=max(fLow,1e-10);
end
% call to meshgrid based on FREQSPACE.m
t1 = ((0:n(2)-1)-floor(n(2)/2))*(2/(n(2)));
t2 = ((0:n(1)-1)-floor(n(1)/2))*(2/(n(1)));
[t1,t2] = meshgrid(t1,t2);
t1=t1.^2+t2.^2; % radial frequency squared
clear t2
w=t1.^(exponent/2);				% start with all-pass filter
d=find(t1<fLow.^2 | t1>fHigh.^2); % find out-of-band frequencies
if ~isempty(d)
	w(d)=zeros(size(d));		% zero the gain at those frequencies
    % Normalize to preserve average power spectral density across the band.
    wAverage = sum(w(:).^2)/sum(w(:)>0);
    w=w/wAverage^0.5;
end
