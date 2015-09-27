ld=2; %fixed letter degree
ndr = [0.5,2,8,inf]; %noise decay radius
ecc = [0,2,8,32]; %eccentricity
nc=0.1; %noise contrast takes values [0.1,0.35,0]. 
%Change value of nc and repeat below commands every time.
[nc2,ndr2,ecc2]=meshgrid(nc,ndr,ecc);
grid1=[nc2(:) ndr2(:) ecc2(:)]; %creates 16x3 grid of parameters
grid1b = [grid1; grid1]; %each data point twice
grid1b = grid1b(randperm(size(grid1b,1)),:); %randomly permutes rows of 32x3 matrix

openvar grid1b
