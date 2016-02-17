% in: C:\Users\Lara\Documents\MATLAB
save_on = 0; % Set to nonzero to run processor and save files, zero to just plot
             % WORK IN PROGRESS; not recommended to run with save_on == 0
%% Choose Data Directories to Process
%     data_dirs{1} = '1734.cnt';
%     data_dirs{2} = '826.cnt';
    num_dir = [ 826; 1734 ]; %1734.cnt
    for ii = 1:length(num_dir)
        data_dirs{ii} = [ 'CNT/',num2str(num_dir(ii)),'.cnt'];
    end
%% Choose "Altogether" .mat File
%% WIP; might work out of the box, if not tell Michelle the errors you get
    % you can change the name of the file here if you want
    % just make sure you also change it in view_data.m
    allfile = 'CNT/altogether.mat';

%% Initialize Parameters
start_offset = 100;       % counting BACKWARDs from stimulus onset (ms)
stop_offset  = 500;       % counting FORWARDs  from stimulus onset (ms)
dt           = 1000;      % Sampling rate (Hz)
dt           = dt/1000;   % Sampling rate converted from 1/s to 1/ms
habit_int    = 1*60*1000; % Interval over which to average for habituation check

%% Begin processing data; all times are in ms
if save_on
    [ peaks, plocs, stim_aves, hstim_aves  ] = fcn_process_cnt(...
                    data_dirs,start_offset,stop_offset,dt,habit_int);
end

%  peaks:         matrix of peak values that's aligned with data_dirs
%  plocs:         matrix of peak locations that's aligned with peaks
%  stim_aves:     matrix of the average stimulus values 
%  hstim_aves: matrix of the Habituation-Corrected average stimulus
%                 values
% peaks(m,n,p,q) = peak from data directory m, electrode in position n
%                 stimulus type p, all data q=1, habituated data q=2
% plocs has same setup as peaks
% stim_ave(m,n,p,q) = response average from data directory m, electode n
%                     stimulus type p, for local time q
% hstim_aves has the same setup as stim_ave

%% Plot results by person
tlocal = -start_offset:dt:stop_offset;
electr = [ {'Cz'}; {'Fz'}; {'Pz'} ];
%% Plot by Stimulus
for ii = 1:length(num_dir)
    % Plot Everything for one person
    figure(10+ii); clf; 
    mysuptitle(['Data directory: ',data_dirs{ii}]);
    for jj = 1:3
    subplot(3,1,jj);
        plot(tlocal,squeeze( stim_aves(ii,1,jj,:)),'b-',...
             tlocal,squeeze( stim_aves(ii,2,jj,:)),'r-',...
             tlocal,squeeze( stim_aves(ii,3,jj,:)),'k-');
        hold on;
        if jj~=1 % No habituation or peaks for Stimulus 1
            dashline(tlocal,squeeze(hstim_aves(ii,1,jj,:)),1,1,1,1,'color','b');
            dashline(tlocal,squeeze(hstim_aves(ii,2,jj,:)),1,1,1,1,'color','r');
            dashline(tlocal,squeeze(hstim_aves(ii,3,jj,:)),1,1,1,1,'color','k');
            plot(plocs(ii,1,jj,1),peaks(ii,1,jj,1),'bx',...
                 plocs(ii,2,jj,1),peaks(ii,2,jj,1),'rx',...
                 plocs(ii,3,jj,1),peaks(ii,3,jj,1),'kx',...
                 plocs(ii,1,jj,2),peaks(ii,1,jj,2),'b*',...
                 plocs(ii,2,jj,2),peaks(ii,2,jj,2),'r*',...
                 plocs(ii,3,jj,2),peaks(ii,3,jj,2),'k*');
        end
        xlabel('Local Time (ms)'); ylabel('mV'); 
        legend(electr{1},electr{2},electr{3});
        title(['Stimulus ',num2str(jj),' Dashed and Stars are with Hab. Check']);
        hold off;
    end
    % Save everything for one person
    if save_on
        dir_stim_aves = squeeze(stim_aves(ii,:,:,:));
        dir_plocs     = plocs(ii,:,:,:);
        dir_peaks     = peaks(ii,:,:,:);
        savefile = [data_dirs{ii}(1:end-4),'.mat'];
        save(savefile,'tlocal','dir_stim_aves','dir_plocs','dir_peaks');
    end
end

%% Save peaks in "altogether" data directory
if exist(allfile,'file')
	load(allfile,'structpeak');
    structpeak.Subject = [structpeak.Subject, num_dir];
    structpeak.CzPeaks = [structpeak.CzPeaks, peaks(:,1,:,:)];
    structpeak.FzPeaks = [structpeak.FzPeaks, peaks(:,2,:,:)];
    structpeak.PzPeaks = [structpeak.PzPeaks, peaks(:,3,:,:)];
else
    structpeak = struct('Subject',num_dir,...
                        'CzPeaks',peaks(:,1,:,:),...
                        'FzPeaks',peaks(:,2,:,:),...
                        'PzPeaks',peaks(:,3,:,:));
end


save(allfile,'structpeak');




%% ARCHIVED SCRIPT; I just don't want to have to rewrite it if you want it later
%% Plot by Electrode
% for ii = 1:length(num_dir)
%     % Plot Everything for one person
%     figure(10+ii); clf; 
%     mysuptitle(['Data directory: ',data_dirs{ii}]);
%     for jj = 1:3
%     subplot(6,1,jj);
%         plot(tlocal,squeeze(stim_aves(ii,jj,1,:)),'b-',...
%              tlocal,squeeze(stim_aves(ii,jj,2,:)),'r-',...
%              tlocal,squeeze(stim_aves(ii,jj,3,:)),'k-');
%         hold on;
%         plot(plocs(ii,jj,2,1),peaks(ii,jj,2,1),'rx',...
%              plocs(ii,jj,3,1),peaks(ii,jj,3,1),'kx');
%         xlabel('Local Time (ms)'); ylabel('mV'); 
%         legend('Stimulus 1','Stimulus 2','Stimulus 3', 'Stimulus 2 Valley','Stimulus 3 Valley');
%         title(electr{jj});
% 	subplot(6,1,jj+3);
%         plot(tlocal,squeeze(hstim_aves(ii,jj,1,:)),'b-',...
%              tlocal,squeeze(hstim_aves(ii,jj,2,:)),'r-',...
%              tlocal,squeeze(hstim_aves(ii,jj,3,:)),'k-');
%         hold on;
%         plot(plocs(ii,jj,2,2),peaks(ii,jj,2,2),'rx',...
%              plocs(ii,jj,3,2),peaks(ii,jj,3,2),'kx');
%         xlabel('Local Time (ms)'); ylabel('mV'); 
%         legend('Stimulus 1','Stimulus 2','Stimulus 3', 'Stimulus 2 Valley','Stimulus 3 Valley');
%         title([electr{jj}, ' with Habituation Check']);
%         hold off;
%     end
%     % Save everything for one person
%     if save_on
%         dir_stim_aves = squeeze(stim_aves(ii,:,:,:));
%         dir_plocs     = plocs(ii,:,:,:);
%         dir_peaks     = peaks(ii,:,:,:);
%         savefile = [data_dirs{ii}(1:end-4),'.mat'];
%         save(savefile,'tlocal','dir_stim_aves','dir_plocs','dir_peaks');
%     end
% end
% 
