mainFolder=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(mainFolder,'lib'));
clear a b
t=GetSecs;
for i=1:3 % 2000
    a(i)=rand;
    setting.brightness=a(i);
    MacDisplaySettings(setting);
    s=MacDisplaySettings;
    b(i)=s.brightness;
end
t=(GetSecs-t)/length(a);
setting.brightness=1;
tic;MacDisplaySettings(setting);toc
fprintf('%.1f s per iteration (two calls per iteration).\n',t);

fprintf('%d peek vs poke difference in brightness setting: mean %.7g, sd %.7g, max min, %.7g %.7g\n',...
   length(a-b),mean(a-b),std(a-b),max(a-b),min(a-b));
histogram(b-a)
ylabel('Frequency');
xlabel('Brightness peek minus poke');

if true
    disp('peek ');tic;oldSettings=MacDisplaySettings;toc
    newSettings.brightness=[];
    newSettings.automatically=[];
    newSettings.trueTone=[];
    newSettings.nightShiftSchedule=[];
    newSettings.nightShiftManual=[];
    newSettings.showProfilesForThisDisplayOnly=[];
    newSettings.profile=[];
    newSettings.profileRow=[];
    MacDisplaySettings(0)
    %MacDisplaySettings(1)
    disp('poke+peek ');tic;MacDisplaySettings(newSettings);toc
    return
    
    MacDisplaySettings(0,newSettings)
    newSettings.brightness=0.9;
    newSettings.automatically=true;
    newSettings.trueTone=false;
    newSettings.nightShiftSchedule='Off';
    newSettings.nightShiftManual=true;
    newSettings.showProfilesForThisDisplayOnly=true;
    newSettings.profile=[];
    newSettings.profileRow=2;
    MacDisplaySettings(newSettings)
    newSettings
    MacDisplaySettings
    MacDisplaySettings(oldSettings)
    newSettings.brightness=0.8;
    newSettings.automatically=false;
    newSettings.trueTone=true;
    newSettings.nightShiftSchedule='Sunset to Sunrise';
    newSettings.nightShiftManual=false;
    newSettings.showProfilesForThisDisplayOnly=false;
    newSettings.profile=[];
    newSettings.profileRow=1;
    MacDisplaySettings(newSettings);
    newSettings
    MacDisplaySettings
end