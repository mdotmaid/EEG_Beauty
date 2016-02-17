function[ peaks, plocs, stim_aves, hstim_aves  ] = fcn_process_cnt(data_dirs,...
                                        start_offset,stop_offset,dt,habit_int)
%% A function by Michelle Maiden
%% Outputs
%  peaks:         matrix of peak values that's aligned with data_dirs
%  stim_aves:     matrix of the average stimulus values 
%  new_stim_aves: matrix of the Habituation-Corrected average stimulus
%                 values


% peaks(m,n,p,q) = peak from data directory m, electrode in position n
%                 stimulus type p, all data q=1, habituated data q=2
peaks     = zeros(length(data_dirs),3,3,2);

% plocs(m,n,p,q) has the same setup as peaks
plocs     = zeros(length(data_dirs),3,3,2);

% stim_ave(m,n,p,q) = response average from data directory m, electode n
%                     stimulus type p, for local time q
stim_aves = zeros(length(data_dirs),3,3,...
                  length(-start_offset:dt:stop_offset));

% new_stim_ave follows the same setup as stim_ave
hstim_aves = zeros(length(data_dirs),3,3,...
                  length(-start_offset:dt:stop_offset));

for di = 1:length(data_dirs)
    data_dir = data_dirs{di};
    disp(['Processing data directory: ', data_dir]);
    data = loadcnt(data_dir);

    %% Label Electrodes
    Cz = data.data(1,:);
    Fz = data.data(2,:);
    Pz = data.data(3,:);

    %% Time Vectors
        % Global time: zero is the start of the trial
        globalt = 0:dt:1/dt*length(Cz);
        % Local time: zero is the stimulus onset
        localt  = -start_offset:dt:stop_offset;

    %% Generate non-insane vectors for stimuli
    epoch = struct('offset',[],'stimtype',[],...
                   'start',[],'stop',[],'size',[],'num',[],...
                   'start_offset',start_offset,'stop_offset',stop_offset);
    epoch.num = 1:length(data.event);
    epoch.stimtype = zeros(1,length(data.event));
    epoch.offset   = zeros(1,length(data.event));
    
    for ii = 1:length(data.event)
        epoch.offset(ii) = data.event(ii).offset;
        epoch.stimtype(ii) = data.event(ii).stimtype;
    end

%     % Figure for debugging extraction of data; can comment out
%     figure(1); clf;
%     plot(1:length(Cz),Cz,repmat(epoch.offset,2,1),repmat([min(Cz) max(Cz)]',1,length(epoch.offset)));
%     input('Return');
    %% Define All Epoch Start and Stop Points
        epoch.start  = epoch.offset - start_offset; % Start epoch offset ms before stimulus 
        epoch.stop   = epoch.offset + stop_offset;   % End epoch offset ms after stimulus 
        epoch.size  = start_offset+stop_offset+1;
    %% Process each of the different electrodes
        disp([sprintf('\t'),'Processing Cz electrode...']);
        [Czpeaks,Czlocs,Czstimaves,hCzstimaves] = processQz(Cz,epoch,dt,habit_int);
        disp([sprintf('\t'),'Processing Fz electrode...']);
        [Fzpeaks,Fzlocs,Fzstimaves,hFzstimaves] = processQz(Fz,epoch,dt,habit_int);
        disp([sprintf('\t'),'Processing Pz electrode...']);
        [Pzpeaks,Pzlocs,Pzstimaves,hPzstimaves] = processQz(Pz,epoch,dt,habit_int);
    %% Save the electrodes to the preallocated structures
            peaks(di,1,:,:)  =  Czpeaks;
            peaks(di,2,:,:)  =  Fzpeaks;
            peaks(di,3,:,:)  =  Pzpeaks;
            plocs(di,1,:,:)  =  Czlocs;
            plocs(di,2,:,:)  =  Fzlocs;
            plocs(di,3,:,:)  =  Pzlocs;
        stim_aves(di,1,:,:)  =  Czstimaves(:,:);
        stim_aves(di,2,:,:)  =  Fzstimaves(:,:);
        stim_aves(di,3,:,:)  =  Pzstimaves(:,:);
       hstim_aves(di,1,:,:) = hCzstimaves(:,:);
       hstim_aves(di,2,:,:) = hFzstimaves(:,:);
       hstim_aves(di,3,:,:) = hPzstimaves(:,:);
end
    







