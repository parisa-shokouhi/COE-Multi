clear all
close all
clc
% Script to anaylize acoustic data (verasonics device), once the sync has been performed

% Load mechanical data (filename looks like 'pXXXX_data_bin')
runname = 'p5270';

load([runname 'MechData']);

acousticrun = 'run1'; % select the acoustic run to analyze after adjusting indexes (from figure 1) and the path
switch acousticrun                        
                
    case 'run1'        
        AcSettingsfile = [runname '_' acousticrun '.mat']; % acoustic settings file 
        AcSyncFile = [runname '_sync_' acousticrun '.mat']; % sync file 
        WF_path = ['./' runname '/' acousticrun '/WF_']; % where the WFs are
        
        % Portion of the WF to analyze
        idxBeg = 520;       % choose the beginning of the WF used for analysis
        idxEnd = 630;      % choose the end of the WF used for analysis        
        
        % number of waveforms to stack (either to display or when analyzing)
        NtoStack = 10;      
        
        % analyze acoustic data over that time range only. If not defined,
        % the whole run is analyzed
        TimeRange = [3939 3969];
%         TimeRange = [10468 11035]; % time interval in seconds
        
        displayoptions = 1; % choose 0 to display all waveforms or 1 to display one set of waveforms over 100
        
        % Show WFs at these times
        % vector of times (seconds) at which you would like to see the waveforms
        AtWhichTimes = TimeRange(1); 

        % Display waveforms sent by transmitter WhichTrans
        WhichTrans = 1;
        
        ref = 'mixref'; %'absref', 'relref' or 'mixref';                             
        
end  

% offset waveforms by Offset when multiple channels are used
Offset1 = 5000;
Offset2 = 5000;

% used for 'relref' or 'mixref'
threshold = 0.97;

%% plot mechanical data of interest within the considered run

load(AcSyncFile);
% Find sample number corresponding to the beginning and end of the acoustic run
FirstIdxAc = find(Time > acTime(1),1,'first'); 
LastIdxAc = find(Time > acTime(end),1,'first');
idxAc = FirstIdxAc:LastIdxAc;

FigRaw = figure;
subplot(311);plot(Time(idxAc),ShearStress(idxAc));ylabel('Shear Stress (MPa)');
subplot(312);plot(Time(idxAc),LPDisp(idxAc)/1000);ylabel('LP Disp (mm)');hold on
subplot(313);plot(Time(idxAc),NormStress(idxAc));ylabel('Normal Stress (MPa)');
xlabel('Time (s)')
dcmObj = datacursormode;set(dcmObj,'UpdateFcn',@GoodCursor);

%return

%% show WFs at different times
ShowMeWFs(WF_path,AcSettingsfile,AcSyncFile,AtWhichTimes,NtoStack,Offset1,WhichTrans);

%return

%% process acoustic data (Time Shift, RmsAmp and Max Intercorrelation)
[MaxInter,TimeShift,RmsAmp,Amp,RmsAmpRef,AmpRef,fullWFref,LocalAcTime] = ...
    ProcessAc_Tomo(WF_path,AcSettingsfile,AcSyncFile,...
    idxBeg,idxEnd,ref,NtoStack,threshold,Offset2,displayoptions,TimeRange); %
%% save data

% filename of the resulting mat file with explicit name based on chosen paramters
if strcmp(ref,'relref') || strcmp(ref,'mixref')
   ref = [ref '_Th' num2str(threshold)]; % add threshold value to name when using relative reference
end
try % if TimeRange is defined above
    filenamedata = ['Results_' runname '_' acousticrun '_' num2str(LocalAcTime(1,1)) 's-' num2str(LocalAcTime(end,end)) 's_Stack' num2str(NtoStack) 'WFs_' ref '_' num2str(idxBeg) '_' num2str(idxEnd) '.mat'];
catch % if TimeRange is not defined (full run analyzed)
    filenamedata = ['Results_' runname '_' acousticrun '_fullrun_Stack' num2str(NtoStack) 'WFs_' ref '.mat'];
    TimeRange = [acTime(1) acTime(end)];
end

for i=1:length(MaxInter)
    if MaxInter(i,WhichTrans,WhichTrans) < threshold
        Amp(i,WhichTrans,WhichTrans)=Amp(i-1,WhichTrans,WhichTrans);
        RmsAmp(i,WhichTrans,WhichTrans)=RmsAmp(i-1,WhichTrans,WhichTrans);
        TimeShift(i,WhichTrans,WhichTrans)=TimeShift(i-1,WhichTrans,WhichTrans);
    end
end


save(filenamedata,...
    'LocalAcTime','RmsAmp','Amp','AmpRef','MaxInter','TimeShift',...        
    'RmsAmpRef','fullWFref','idxBeg','idxEnd','NtoStack','ref','threshold','TimeRange');                                                           
              
return
