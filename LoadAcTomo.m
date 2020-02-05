

function [ACdata ACdata3D ACdata4D] = LoadAcTomo(WF_path,filenumber,numCHR,numSFpfile,numTRANS,Nsample,stack)

% Load acoustic file and reshape according to the
% number of receivers

%% Input
% WF_path: location of the files
% filenumber: which file is being loaded
% numCHR: number of receivers 
% numSFpfile: number of 'superframes' per file (Verasonics jargon)
% numTRANS: number of transmitters
% Nsample : number of data points
% stack   : (y/n) option to stack the waveforms (average within a WF file)

%% Output 
% ACdata: 2D reshaped matrix
% ACdata3D: 3D stacked reshaped matrix (waveform, transmitter, receiver)
% ACdata4D: 4D reshaped matrix (waveform, transmitter, receiver, # of acquisition)
%% Code

ACfilename = [WF_path 'WF_' num2str(filenumber) '.ac'];
fid = fopen(ACfilename,'r');
ACdata = fread(fid,'int16');
fclose(fid);

% reshape to get one column per channel
ACdata = reshape(ACdata,[],numCHR,numSFpfile);   % 3D matrix with WF vs numCHR vs number of SF
ACdata = permute(ACdata,[1 3 2]);                % put numCHR as the last dimension before reshaping
ACdata = reshape(ACdata,[],numCHR,1);            % WF vs numCHRs


for i = 1:16

    ACdata4D(:,:,:,i) = reshape(ACdata(1+numTRANS*Nsample*(i-1):numTRANS*Nsample*i,:),[],numTRANS, numCHR);  

end % for i

switch stack
    case {'yes','y','Y'}      
        ACdata3D = mean(ACdata4D,4);
    case {'no','No','N'}
        ACdata3D = [];
end % switch  
        

end