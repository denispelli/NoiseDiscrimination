for i=1:129
    new.brightness=min(1,i/128);
    old=MacDisplaySettings(new);
    if i<129
        x(i)=new.brightness;
    end
    if i>1
        y(i-1)=old.brightness;
    end
end
plot(x,y);
plot(x(1:end-1),diff(y))
length(unique(y))