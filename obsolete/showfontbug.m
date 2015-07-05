for j=1:9
    f=sprintf('/Users/denispelli/Dropbox/pelli2012vss-counting-receptive-fields/NoiseDiscrimination/noisediscrimination-software/bugsignals/bug%d',j);
    load(f);
    figure(j);
    for i=1:9
        subplot(3,3,i);imshow(signal(i).image);
    end
end
    