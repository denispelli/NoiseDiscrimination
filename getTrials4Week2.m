ld=2; %fixed letter degree
ndr = [2,sqrt(2*16),16]; %noise decay radius
ecc = [32]; %eccentricity
nc=0.2; %noise contrast takes values [0.1,0.35,0]. 
%Change value of nc and repeat below commands every time.
[nc2,ndr2,ecc2]=meshgrid(nc,ndr,ecc);
grid1=[nc2(:) ndr2(:) ecc2(:)]; %creates 16x3 grid of parameters
%grid1b = repmat(grid1,2,1);%each data point twice
grid1b = repmat(grid1,1,1);%each data point once
grid1b = grid1b(randperm(size(grid1b,1)),:); %randomly permutes rows of 32x3 matrix

clear ld ndr  ecc  nc  nc2  ndr2  ecc2  grid1;
disp('`grid1b` is generated in workspace');
disp('');
