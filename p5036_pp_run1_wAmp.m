clear all
close all
clc

%% load mechanical data
runname = 'p5036';
% read binary file (output of r_file)
[data,outname] = ReadBinBiax(runname);

SAVE = 1;

LPDisp          = data(:,2);
ShearStress     = data(:,3);
NormDisp        = data(:,4);
NormStress      = data(:,5);
Pc_disp         = data(:,6);
Pc              = data(:,7);
Ppa_disp        = data(:,8);
Ppa             = data(:,9);
Ppb_disp        = data(:,10);
Ppb             = data(:,11);
Time            = data(:,12);
effNorStress    = data(:,13);
Qa              = data(:,14);
Qb              = data(:,15);
Qdiff           = data(:,16);
Qavg            = data(:,17);
PpDiff          = data(:,18);
Perm            = data(:,19);
Sync            = data(:,20);
IntDisp         = data(:,21);
mu              = data(:,22);

clear data
% return

% ----------------------------------------------------------------------------
% |Column|             Name|             Unit|          Records|
% ----------------------------------------------------------------------------
% |     1|          LP_Disp|              mic|          7077587|
% |     2|       Shr_stress|              MPa|          7077587|
% |     3|      normal_disp|           micron|          7077587|
% |     4|                 |              MPa|          7077587|
% |     5|          Pc_disp|           micron|          7077587|
% |     6|               Pc|              MPa|          7077587|
% |     7|         Ppa_disp|           micron|          7077587|
% |     8|              Ppa|              MPa|          7077587|
% |     9|         Ppb_disp|           micron|          7077587|
% |    10|              Ppb|              MPa|          7077587|
% |    11|             Time|              sec|          7077587|
% |    12|     effNorStress|              MPa|          7077587|
% |    13|               Qa|            m^3/s|          7077587|
% |    14|               Qb|            m^3/s|          7077587|
% |    15|            Qdiff|            m^3/s|          7077587|
% |    16|             Qavg|            m^3/s|          7077587|
% |    17|           PpDiff|              MPa|          7077587|
% |    18|             perm|              m^2|          7077587|
% |    19|             Sync|              bit|          7077587|
% |    20|          IntDisp|           micron|          7077587|
% |    21|               mu|                .|          7077587|
% ----------------------------------------------------------------------------


%% Load Thickness
load('p5036_Thickness.mat');
%% Load Vertical Position Left Block
load('p5036_VerticalDisplacement.mat');

%% Load Permeability
load('p5036_Permeability_percentdiff_5_minflow_0.mat'); % load Perm_new

%% load acoustic data (output from pXXXX_a.m)
run = 'run17';
load(['Results_p5036_' run '_fullrun_Stack3WFs_absref_wAmp.mat']);

%% load acoustic settings mat file
AcSettingsfile = ['D:\Penn State\PhD\DOE-BES2017\Data\p5036\p5036mat\' run '.mat'];

acSettings = load(AcSettingsfile);             % load acoustic settings
numCHR = length(acSettings.channels2save);     % number of channels
numCHT = length(acSettings.channels2transmit); % number of channels
fs = acSettings.samplingFreq;
Nsamples = acSettings.Nsamples;

%% Overall run

% Find sample number corresponding to the beginning and end of the acoustic
% run
FirstIdxAc = find(Time > LocalAcTime(1,1),1,'first'); 
LastIdxAc = find(Time < LocalAcTime(end,1),1,'last');
idxAc = FirstIdxAc:LastIdxAc;

% Linear Interpolation
MaxInterI = zeros(length(Time(idxAc)),numCHR,numCHT);
TimeShiftI = zeros(length(Time(idxAc)),numCHR,numCHT);

RmsAmpI = zeros(length(Time(idxAc)),numCHR,numCHT);
freqQAmpI = zeros(length(Time(idxAc)),numCHR,numCHT);
maxAmpI = zeros(length(Time(idxAc)),numCHR,numCHT);
maxFreqI = zeros(length(Time(idxAc)),numCHR,numCHT);

for chnumt = 1:1:numCHT    
        MaxInterI(:,:,chnumt) = interp1(LocalAcTime(:,chnumt),MaxInter(:,:,chnumt),Time(idxAc));        
        TimeShiftI(:,:,chnumt) = interp1(LocalAcTime(:,chnumt),TimeShift(:,:,chnumt),Time(idxAc));
        
        RmsAmpI(:,:,chnumt) = interp1(LocalAcTime(:,chnumt),RmsAmp(:,:,chnumt),Time(idxAc));          
        freqQAmpI(:,:,chnumt) = interp1(LocalAcTime(:,chnumt),freqQAmp(:,:,chnumt),Time(idxAc));
        maxAmpI(:,:,chnumt) = interp1(LocalAcTime(:,chnumt),maxAmp(:,:,chnumt),Time(idxAc));
        maxFreqI(:,:,chnumt) = interp1(LocalAcTime(:,chnumt),maxFreq(:,:,chnumt),Time(idxAc));
end

%% Time Shift vs Time
close all
T = 5;
R = 5;

H1 = figure(1);
set(gcf,'position',[100 100 600 800],'Color',[1 1 1]);
ax1a = axes('Position',[0.15 0.82 0.7 0.10],'YAxisLocation','left','Color','none','XColor','none','NextPlot','add'); % add so that axes properties are not deleted when plotting
ax1b = axes('Position',[0.15 0.88 0.7 0.10],'YAxisLocation','right','Color','none','XColor','none','NextPlot','add');
ax1c = axes('Position',[0.15 0.67 0.7 0.10],'YAxisLocation','left','Color','none','XColor','none','NextPlot','add'); %,'XColor','none'
ax1d = axes('Position',[0.15 0.73 0.7 0.10],'YAxisLocation','right','Color','none','XColor','none','NextPlot','add');
ax2a = axes('Position',[0.15 0.4 0.7 0.25],'YAxisLocation','left','Color','none','NextPlot','add'); 
ax2b = axes('Position',[0.15 0.4 0.7 0.25],'YAxisLocation','right','Color','none','XColor','none','NextPlot','add'); 
ax3a = axes('Position',[0.15 0.1 0.7 0.25],'YAxisLocation','left','Color','none','NextPlot','add'); 
ax3b = axes('Position',[0.15 0.1 0.7 0.25],'YAxisLocation','right','Color','none','XColor','none','NextPlot','add'); 

hold(ax2a,'on');
plot(ax2a,Time(idxAc)-Time(idxAc(1)),ThChangeLPF(idxAc),'k','LineWidth',1); 
set(ax2a,'XLimMode','auto','YLimMode','auto'); %,'ycolor','k'
set(ax2a,'XTickMode','auto','YTickMode','auto','XTicklabel',[]);
set(ax2a,'FontSize',16);
ylabel(ax2a,'Thickness Change ($\mu$m)','Interpreter','Latex');

hold(ax2b,'on');
plot(ax2b,Time(idxAc)-Time(idxAc(1)),LPDisp(idxAc)/1000,'r','LineWidth',1); 
set(ax2b,'XLimMode','auto','YLimMode','auto','ycolor','r'); %
set(ax2b,'XTickMode','auto','YTickMode','auto','XTicklabel',[]);
set(ax2b,'FontSize',16);
ylabel(ax2b,'Load Point Disp. (mm)','Interpreter','Latex');
dcmObj = datacursormode;set(dcmObj,'UpdateFcn',@GoodCursor);

hold(ax1a,'on')
plot(ax1a,Time(idxAc)-Time(idxAc(1)),NormStress(idxAc),'k','LineWidth',1)
set(ax1a,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','k'); % ,'ycolor','k'
set(ax1a,'XTick',get(ax2a(1),'XTick'),'YTickMode','auto','XTicklabel',[]);% ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax1a,'FontSize',16);
ylabel(ax1a,'$\sigma_n$ (MPa)','Interpreter','Latex');

hold(ax1b,'on')
plot(ax1b,Time(idxAc)-Time(idxAc(1)),Ppa(idxAc),'r','LineWidth',1)
set(ax1b,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','r'); % ,'ycolor','k'
set(ax1b,'XTick',get(ax2a(1),'XTick'),'YTickMode','auto','XTicklabel',[]);% ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax1b,'FontSize',16);
ylabel(ax1b,'Ppa (MPa)','Interpreter','Latex');

hold(ax1c,'on')
plot(ax1c,Time(idxAc)-Time(idxAc(1)),Pc(idxAc),'k','LineWidth',1)
set(ax1c,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','k'); % ,'ycolor','k'
set(ax1c,'XTick',get(ax2a(1),'XTick'),'YTickMode','auto','XTicklabel',[]);% ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax1c,'FontSize',16);
ylabel(ax1c,'$P_c$ (MPa)','Interpreter','Latex');

hold(ax1d,'on')
plot(ax1d,Time(idxAc)-Time(idxAc(1)),Ppb(idxAc),'r','LineWidth',1)
set(ax1d,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','r'); % 
set(ax1d,'XTick',get(ax2a(1),'XTick'),'YTickMode','auto','XTicklabel',[]);% ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax1d,'FontSize',16);
ylabel(ax1d,'Ppb (MPa)','Interpreter','Latex');

hold(ax3a,'on');                                     
for kk = 5 %1:numCHT
    for hh = 6 %1:numCHR
        plot(ax3a,Time(idxAc)-Time(idxAc(1)),TimeShiftI(:,hh,kk));
    end
end
xlabel(ax3a,'Time (s)','Interpreter','Latex');
ylabel(ax3a,'Time Shift ($\mu$s)','Interpreter','Latex');
set(ax3a,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','k'); % 
set(ax3a,'XTick',get(ax2a(1),'XTick'),'YTickMode','auto');
set(ax3a,'FontSize',16);

hold(ax3b,'on')
plot(ax3b,Time(idxAc)-Time(idxAc(1)),ShearStress(idxAc),'r','LineWidth',1)
set(ax3b,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','r'); % 
set(ax3b,'XTick',get(ax2a(1),'XTick'),'YTickMode','auto');% ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax3b,'FontSize',16);
ylabel(ax3b,'Shear Stress (MPa)','Interpreter','Latex');
dcmObj = datacursormode;set(dcmObj,'UpdateFcn',@GoodCursor);

linkaxes([ax1a,ax1b,ax1c,ax1d,ax2a,ax2b,ax3a,ax3b],'x');

%% Pick TOF
winanalysis = idx2analyze(:,R,T);

timeWF = (0:Nsamples-1)/fs;

% figure used to pick arrival by hand
H2 = figure(2);
plot(timeWF,fullWFref(:,R,T));hold on
plot(timeWF(winanalysis(1):winanalysis(2)),fullWFref(winanalysis(1):winanalysis(2),R,T));

zoom on
pause;
[arrivaltime,~] = ginput(1);

%% Retrieve Distances and compute velocities
% display geometry at the end of the run
GeoVesselAcBlocks(InitTh,5,5,-mean(ThChange(idxAc(end-50:end)))/1000,mean(VertDisp(idxAc(end-50:end))));
% compute distances between sensors over the run
[pos_L,pos_R,dist_s,dist_b] = DistanceSensorsVessel(26,5,5,-ThChange(idxAc)/1000,VertDisp(idxAc));

dist_s = squeeze(dist_s);
dist_b = squeeze(dist_b);

c_b = 5.777;
c_s = dist_s./(arrivaltime+TimeShiftI(:,R,T)-dist_b/c_b);

%% Calculate attenuation (change in Q-factor)

% dalpha (relative between each consecutive point)
dalphamax_rel = -diff(log(maxAmpI(:,R,T))); % max amp spectrum
dalphamax_rel = [0;dalphamax_rel]./dist_s; %mm^-1 ignore attenuation in steel blocks

dalpha_rel = -diff(log(freqQAmpI(:,R,T))); % amplitude at the input frequency
dalpha_rel = [0;dalpha_rel]./dist_s; %mm^-1 ignore attenuation in steel blocks

% d(1/Q) (relative between each consecutive point)
dQm1max_rel = (dalphamax_rel.*c_s*10^6)./(pi*maxFreqI(:,R,T)); % using freq at the maximum amplitude (Hz)
dQm1_rel = (dalpha_rel.*c_s*10^6)./(pi*FreqQ); % using frequency chosen by user (Hz)

% dalpha and d(1/Q)
dalphamax_rel(isnan(dalphamax_rel)) = 0; % replace NaN by zeros
dalpha_rel(isnan(dalpha_rel)) = 0;
dQm1max_rel(isnan(dQm1max_rel)) = 0;
dQm1_rel(isnan(dQm1_rel)) = 0;

dalphamax = cumsum(dalphamax_rel);
dalpha = cumsum(dalpha_rel);
dQm1max = cumsum(dQm1max_rel);
dQm1 = cumsum(dQm1_rel);

%% Plot Velocity vs Time
H3 = figure(3);
if ishandle(H3), close(H3), end
H3 = figure(3);
set(gcf,'position',[100 100 600 800],'Color',[1 1 1]);
ax1a = axes('Position',[0.15 0.22 0.7 0.2],'YAxisLocation','left','Color','none','XColor','none','NextPlot','add'); % add so that axes properties are not deleted when plotting
ax1b = axes('Position',[0.15 0.1 0.7 0.2],'YAxisLocation','right','Color','none','NextPlot','add');
ax2a = axes('Position',[0.15 0.88 0.7 0.1],'YAxisLocation','left','Color','none','XColor','none','NextPlot','add'); 
ax2b = axes('Position',[0.15 0.82 0.7 0.1],'YAxisLocation','right','Color','none','XColor','none','NextPlot','add'); 
ax2c = axes('Position',[0.15 0.73 0.7 0.1],'YAxisLocation','left','Color','none','XColor','none','NextPlot','add'); 
ax2d = axes('Position',[0.15 0.68 0.7 0.1],'YAxisLocation','right','Color','none','XColor','none','NextPlot','add'); 
ax3a = axes('Position',[0.15 0.5 0.7 0.2],'YAxisLocation','left','Color','none','XColor','none','NextPlot','add'); 
ax3b = axes('Position',[0.15 0.38 0.7 0.2],'YAxisLocation','right','Color','none','XColor','none','NextPlot','add'); 

hold(ax2a,'on');
plot(ax2a,Time(idxAc)-Time(idxAc(1)),NormStress(idxAc),'k','LineWidth',1); % 
set(ax2a,'XLimMode','auto','YLimMode','auto'); %,'ycolor','k'
set(ax2a,'XTickMode','auto','YTickMode','auto','XTicklabel',[]);
set(ax2a,'FontSize',16);
ylabel(ax2a,'$\sigma_n$ (MPa)','Interpreter','Latex');

hold(ax2b,'on');
plot(ax2b,Time(idxAc)-Time(idxAc(1)),ShearStress(idxAc),'r','LineWidth',1); 
set(ax2b,'XLimMode','auto','YLimMode','auto','ycolor','r'); %
set(ax2b,'XTickMode','auto','YTickMode','auto','XTicklabel',[]);
set(ax2b,'FontSize',16);
ylabel(ax2b,'$\tau$ (MPa)','Interpreter','Latex');

hold(ax2c,'on');
plot(ax2c,Time(idxAc)-Time(idxAc(1)),Ppa(idxAc),'k','LineWidth',1); % 
set(ax2c,'XLimMode','auto','YLimMode','auto'); %,'ycolor','k'
set(ax2c,'XTickMode','auto','YTickMode','auto','XTicklabel',[]);
set(ax2c,'FontSize',16);
ylabel(ax2c,'Ppa (MPa)','Interpreter','Latex');

hold(ax2d,'on');
plot(ax2d,Time(idxAc)-Time(idxAc(1)),Ppb(idxAc),'r','LineWidth',1); 
set(ax2d,'XLimMode','auto','YLimMode','auto','ycolor','r'); %
set(ax2d,'XTickMode','auto','YTickMode','auto','XTicklabel',[]);
set(ax2d,'FontSize',16);
ylabel(ax2d,'Ppb (MPa)','Interpreter','Latex');

hold(ax1a,'on')
plot(ax1a,Time(idxAc)-Time(idxAc(1)),dQm1,'k','LineWidth',1)
set(ax1a,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','k'); % ,'ycolor','k'
set(ax1a,'XTickMode','auto','YTickMode','auto','XTicklabel',[]);%'XTick',get(ax2a(1),'XTick'), ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax1a,'FontSize',16);
ylabel(ax1a,'$\frac{1}{Q}-\frac{1}{Q_0}$','Interpreter','Latex');

hold(ax1b,'on')
plot(ax1b,Time(idxAc)-Time(idxAc(1)),Perm(idxAc)*1e15,'r','LineWidth',1);hold on
plot(ax1b,Time(idxAc)-Time(idxAc(1)),Perm_new(idxAc)*1e15,'g','LineWidth',1);
set(ax1b,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','r'); % ,'ycolor','k'
set(ax1b,'XTickMode','auto','YTickMode','auto');%'XTick',get(ax2a(1),'XTick'), ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax1b,'FontSize',16);
ylabel(ax1b,'Perm ($\times 10^{-15} m^2$)','Interpreter','Latex');
xlabel(ax1b,'Time (s)','Interpreter','Latex');
legend(ax1b,'Ben','New');

hold(ax3a,'on');                                     
for kk = 5 %1:numCHT
    for hh = 6 %1:numCHR
%         scatter(ax3a,Time(idxAc)-Time(idxAc(1)),c_s,[],MaxInterI(:,hh,kk),'.'); %
        plot(ax3a,Time(idxAc)-Time(idxAc(1)),c_s,'k','LineWidth',1); %
    end
end

ylabel(ax3a,'Velocity (km/s)','Interpreter','Latex');
set(ax3a,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','k'); % 
set(ax3a,'YTickMode','auto','XTicklabel',[]); %'XTick',get(ax2a(1),'XTick'),
set(ax3a,'FontSize',16);

hold(ax3b,'on')
plot(ax3b,Time(idxAc)-Time(idxAc(1)),ThChangeLPF(idxAc),'r','LineWidth',1)
set(ax3b,'XLim',get(ax2a(1),'XLim'),'YLimMode','auto','ycolor','r'); % 
set(ax3b,'XTickMode','auto','YTickMode','auto');%'XTick',get(ax2a(1),'XTick'), ,'YScale','log','YLim',[10^(-16) 10^(-13)]
set(ax3b,'FontSize',16);
ylabel(ax3b,'$\Delta$h ($\mu$m)','Interpreter','Latex');

linkaxes([ax1a,ax1b,ax2a,ax2b,ax2c,ax2d,ax3a,ax3b],'x');


%% SAVE

if SAVE
    
    saveas(H1,['Results_wAmp/' runname '_' run '_timeshift.fig']);    
    saveas(H3,['Results_wAmp/' runname '_' run '_velocity.fig']);
    
    set(H1,'PaperPositionMode','auto');    
    print(H1,['Results_wAmp/' runname '_' run '_timeshift'],'-dpng');
    set(H3,'PaperPositionMode','auto');  
    print(H3,['Results_wAmp/' runname '_' run '_velocity'],'-dpng');  
    
    filenamedata = ['Results_wAmp/' runname '_' run '_pp_wAmp.mat'];
    save(filenamedata,'c_s','c_b','dist_b','dist_s','arrivaltime', ...
                      'dalphamax_rel','dalpha_rel','dalphamax','dalpha', ...
                      'dQm1max_rel','dQm1_rel','dQm1max','dQm1','Ppa','Ppb',...
                      'Time','NormStress','ThChange','Perm_new','T','R');
       
end

return
