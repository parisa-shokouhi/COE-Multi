% This function opens the mechanical data, as well as the data between two acoustic files. 
% If the total number of files is not too large, both mechanical and acoustic data are plotted as a function of time

clear all
close all
clc % clear command window

%%%%%%%%%%%% PARAMETERS TO ADJUST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load mechanical data
load('p5270MechData.mat');

% load Synchronization file
SyncFile = 'p5270_sync_run1.mat'; % sync filename
load(SyncFile);

% plot acoustic data between these two files:
% - If the number of files is large, data will not be displayed. 
% - if you'd like to build a time vector for the entire run, choose:
%           filenumber1 = 1; 
%           filenumber2 = filetotalnumberoffiles; 
filenumber1 = 200;                  % first acoustic file
filenumber2 = 300; % last acoustic file

% path to acoustic data
WF_path = 'run1/WF_';

% Acoustic acquisition settings file
AcSettingsfile = 'p5270_run1.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% total number of acoustic files considered
nb_of_files = filenumber2 - filenumber1 + 1;

% load parameters used for the acquisition of acoustic data
acSettings = load(AcSettingsfile);              % load acoustic acquisition settings
numSFpfile = acSettings.numFrames/2;            % number of superframes per file
numAcqs = acSettings.numAcqs;                   % number of segments per superframe
numSegments = numSFpfile*numAcqs;               % number of segments per file
numCH = length(acSettings.channels2save);       % number of channels
Nsegment = acSettings.Nsamples;                 % segment length
clear acSettings

% number of points per file
Nfile = Nsegment*numSegments; % # of points per segment times # of segments
% total number of points for all acoustic files considered
N_Acoustic_Total = Nfile*nb_of_files; % # of points per file times # of files

% time vector for each segment of acoustic data
SegmentTime = (0:Nsegment-1)'*ts/1e6; % ts is in microseconds. SegmentTime is in seconds
% time vector for one acoustic file
AcousticTime_file = NaN(Nfile,1);
% time vector for all acoustic files considered
AcousticTime = NaN(N_Acoustic_Total,1);

% acoustic data vector for all acoustic files considered
AcousticData = NaN(N_Acoustic_Total,1);


for ii = 1:nb_of_files                   
    ii
    % build acoustic time vector for each file 
    filenumber = ii + filenumber1 - 1;      
    for jj = 1:numSegments
        AcousticTime_file((jj-1)*Nsegment+1:jj*Nsegment) = acTime((filenumber-1)*numSegments+jj) + SegmentTime;
    end   
    
    % build total acoustic time vector
    AcousticTime((ii-1)*Nfile+1:ii*Nfile) = AcousticTime_file;
    
    % load file
    AcousticData_file = LoadAcFile(WF_path,filenumber,numCH,numSFpfile);
    
    % build total acoustic data vector
    AcousticData((ii-1)*Nfile+1:ii*Nfile) = AcousticData_file;

    % find beginning and end of acoustic data to zoom on the region of
    % interest
    if filenumber == filenumber1, begac = AcousticTime_file(1);  end % beginning of first file
    if filenumber == filenumber2, endac = AcousticTime_file(end);end % end of last file        
                  
end


if nb_of_files < 50 % display data    
    H1 = figure;
    
    ax1 = subplot(311);
    plot(Time,ShearStress);
    ylabel('Shear Stress (MPa)','Interpreter','Latex')
    set(gca,'xlim',[begac,endac]);
    
    offsetplot = max(max(AcousticData));
    ax2 = subplot(3,1,[2 3]);
    for kk = 1:numCH % plot all channels
        plot(AcousticTime,AcousticData(:,kk)-offsetplot*(kk-1),'r');hold on
    end
    xlabel('Time (s)','Interpreter','Latex')
    
    linkaxes([ax1,ax2],'x');
end
