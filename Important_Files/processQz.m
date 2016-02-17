function[Qzpeaks,Qzlocs, Qzstimaves,hQzstimaves] = processQz(Qz,epoch,dt,habit_int)
    %% EPOCH INITIALIZATION
        edc = zeros(epoch.num(end),epoch.size);
        localt = -epoch.start_offset:dt:epoch.stop_offset;
        for eindex = epoch.num
            estim     = epoch.stimtype(eindex);
            estart    = epoch.start(eindex);
            eend      = epoch.stop(eindex);
                if eend > length(Qz)
                    eend = length(Qz);
                end
            e        = epoch.offset(eindex);
            ex       = estart:eend;
            edata    = Qz(ex);
    
	%% Baseline Correction for each epoch
            % Fit a line to the data, then remove that trendline from the data
                P = polyfit(ex,edata,1);
                if length(ex)<epoch.size
                   edc(eindex,:) = [edata - polyval(P,ex), zeros(1,epoch.size-length(ex))];
                else
                    edc(eindex,:) = [edata - polyval(P,ex)];
                end
                %% ARTIFACT REJECTION
                artifact_rejection_threshold = 50;
                if sum(abs(edc(eindex,:))>=artifact_rejection_threshold)
                    % Reject data
                    edc(eindex,:) = NaN;
                end
%                 % Figure for debugging
%                 figure(2); clf;
%                 subplot(2,1,1);
%                 plot((ex)-estart-epoch.start_offset,edata,...
%                      [e e]-estart-epoch.start_offset, [min(edata), max(edata)]);
%                 title(['Stimulus Type: ',num2str(estim)]);
%                 subplot(2,1,2)
%                 plot(ex-estart-epoch.start_offset,edc(eindex,:),...
%                      [e e]-estart-epoch.start_offset, [min(edc(eindex,:)), max(edc(eindex,:))]);
%                  input('Return');
        end
    %% Identifies rejected artifacts from dataset
        naninds = find(isnan(edc(:,5)));
        disp([sprintf('\t\t'),'Artifact Rejection- ',num2str(length(epoch.num)-length(naninds)),...
          ' sweeps accepted, ',num2str(length(naninds)),' rejected']);
%     % Figure for debugging
%     figure(3); clf;
%     plot(edc');
%     input('Return');
    %% Average Stimulus 1 Response (Standard)
        % Choose non-artifact indices
        stim1inds = find(epoch.stimtype==1);
        acc1inds  = setxor(stim1inds,intersect(naninds,stim1inds));
        % Function finds average of functions and sends it through a lowpass
        % filter
            stim1ave = meanclean(edc(acc1inds,:),dt*1000);
            
    %% Average Stimulus 2 Response (Deviant)
        % Choose non-artifact indices
            stim2inds  = find(epoch.stimtype==2);
            acc2inds   = setxor(stim2inds,intersect(naninds,stim2inds));
	if ~isempty(acc2inds)
        % Function finds average of functions and sends it through a lowpass
        % filter
            stim2ave           = meanclean(edc(acc2inds,:),dt*1000);
          [val2,loc2,stim2ave] = mmn(stim2ave,stim1ave,epoch.start_offset); 
            
    %% Check for Habituation in Stimulus 2; WORK IN PROGRESS
        [good2inds, good2pks] = habituation_check(edc(acc2inds,:),...
                                stim1ave,localt,dt*1000,...
                                epoch.offset(acc2inds),habit_int);
         good2inds = acc2inds(good2inds);
            P1 = polyfit(epoch.offset(good2inds),good2pks,1);
%         figure(6); clf;
%             plot(epoch.offset(good2inds)/1000/60,good2pks,'*');
%             title(['Slope of Trendline: ',num2str(P1(1))]);
%             input('Return');
        % Function finds average of functions and sends it through a lowpass
        % filter
            newstim2ave     = meanclean(edc(good2inds,:),dt*1000);
            [newval2,newloc2,newstim2ave] = mmn(newstim2ave,stim1ave,...
                                              epoch.start_offset);
            loc2 = localt(loc2);
            newloc2 = localt(newloc2);
            
	else 
        disp('All epochs from Stimulus 2 were "artifact rejected"');
        stim2ave = zeros(size(stim1ave));
        newstim2ave = zeros(size(stim1ave));
        val2 = NaN; newval2 = NaN;
        loc2 = 0;   newloc2 = 0;
    end
    
    %% Average Stimulus 3 Response (Deviant)
        % Choose non-artifact indices
            stim3inds = find(epoch.stimtype==3);
            acc3inds  = setxor(stim3inds,intersect(naninds,stim3inds));
	if ~isempty(acc3inds)
        % Function finds average of functions and sends it through a lowpass
        % filter
            stim3ave           = meanclean(edc(acc3inds,:),dt*1000);
            [val3,loc3,stim3ave] = mmn(stim3ave,stim1ave,epoch.start_offset); 
    %% Check for Habituation in Stimulus 3; WORK IN PROGRESS
        [good3inds, good3pks] = habituation_check(edc(acc3inds,:),...
                                stim1ave,localt,dt*1000,...
                                epoch.offset(acc3inds),habit_int);
        good3inds = acc3inds(good3inds);
%             P1 = polyfit(epoch.offset(good3inds),good3pks,1);
%         figure(6); clf;
%             plot(epoch.offset(good3inds)/1000/60,good3pks,'*');
%             title(['Slope of Trendline: ',num2str(P1(1))]);
%             input('Return');
        % Function finds average of functions and sends it through a lowpass
        % filter
            newstim3ave     = meanclean(edc(good3inds,:),dt*1000);
            [newval3,newloc3,newstim3ave] = mmn(newstim3ave,stim1ave,...
                                              epoch.start_offset); 
	loc3    = localt(loc3);
    newloc3 = localt(newloc3); 
    else 
        disp('All epochs from Stimulus 3 were "artifact rejected"');
        stim3ave = zeros(size(stim1ave));
        newstim3ave = zeros(size(stim1ave));
        val3 = NaN; newval3 = NaN;
        loc3 = 0;   newloc3 = NaN;
    end

        % Figure for debugging
        % Figure for debugging
%         disp(['Filename :',data_dir]);
            figure(5); clf;
            subplot(3,1,1);
                plot(localt,stim1ave);
                title('Stimulus 1 Average');
            subplot(3,1,2);
                plot(localt,stim2ave,loc2,val2,'*');
                title(['Stimulus 2 Valley',num2str(val2)]); 
            subplot(3,1,3);
                plot(localt,stim3ave,loc3,val3,'*');
                title([' Stimulus 3 Valley: ',num2str(val3)]);
                drawnow;
                pause(0.5);
%                 input('Return');
%% Returned variables
    Qzpeaks    = [0 0; val2  newval2; val3 newval3];
    Qzlocs     = [0 0; loc2  newloc2; loc3 newloc3];
    Qzstimaves = [[stim1ave' (zeros(length(ex)-length(stim1ave)))'];...
                  [stim2ave' (zeros(length(ex)-length(stim2ave)))'];...
                  [stim3ave' (zeros(length(ex)-length(stim2ave)))']];
    hQzstimaves = [[   stim1ave' (zeros(length(ex)-length(   stim1ave)))'];...
                     [newstim2ave' (zeros(length(ex)-length(newstim2ave)))'];...
                     [newstim3ave' (zeros(length(ex)-length(newstim2ave)))']];
%     % Figure for debugging
%     figure(4); clf;
%     subplot(2,1,1);
%     plot(localt,stim1ave);
%     subplot(2,1,2);
%     plot(localt,stim3ave,localt(loc),val,'*',...
%          localt,newstim3ave,localt(newloc),newval,'*');
%     title(['Local Value: ',num2str(val),' Local New Value: ',num2str(newval)]);
end
