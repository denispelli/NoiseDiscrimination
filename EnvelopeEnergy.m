% what is E of cos(x)*cos(y)
% vs E of cos(r)
[x,y]=meshgrid(-100:100,-100:100);
r=sqrt(x.^2 + y.^2);
gDomain=abs(x)<50 & abs(y)<50;
g2Domain=abs(r)<50;
g=cos(0.5*pi*x/50).*cos(0.5*pi*y/50);
g2=cos(0.5*pi*r/50);
g(~gDomain)=0;
g2(~g2Domain)=0;
fprintf('cos(x)*cos(y) mean %.0f, rms %.0f\n',sum(g(:)),norm(g(:)));
fprintf('cos(r) mean %.0f, rms %.0f\n',sum(g2(:)),norm(g2(:)));
d=g-g2;
fprintf('difference mean %.0f, rms %.0f\n',sum(d(:)),norm(d(:)));
figure(1)
subplot(1,3,1)
imshow(g)
subplot(1,3,2)
imshow(g2)
subplot(1,3,3)
imshow(0.5+g-g2)