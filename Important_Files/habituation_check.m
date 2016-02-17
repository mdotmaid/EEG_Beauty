function [goodinds, goodpks]  =  habituation_check(deviant,standard,localt,...
                                                samplerate,offset,win);
        [m,n] = size(deviant);
        stimpks  = zeros(1,m);
        ctr = 0;
        badinds = [];
        
    for si = 1:m
        ctr = ctr+1;
        % Average over all epochs within interval of si
        fe  = find(offset<(offset(si)+win),1,'last');
        stim3  = meanclean(deviant(si:fe,:),samplerate);
        [sval,sloc] = mmn(stim3,standard,localt(1));
        if isempty(sval) || sval>0 || sval<-15
            stimpks(ctr) = NaN;
            badinds      = [badinds, si];
        else
            stimpks(ctr) = sval;
        end
        % % Figure for debugging
%         figure(5); clf;
%         plot(localt,stim3,localt(sloc),sval,'*');
%         input('Return');
    %         if abs(sval)<.2*abs(val)
    %             continue;
    %         end
    end
    if isempty(badinds)
        goodinds = 1:m;
    else
        goodinds = setxor(1:m,intersect(badinds,1:m));
    end
    if isempty(si)
        si = m;
    end
    goodinds(goodinds>si)=[];
    goodpks  = stimpks(goodinds);
    disp([sprintf('\t\tHabituation Time: '),num2str(offset(si)/1000/60),...
          ' min out of ',num2str(offset(m)/1000/60),' min']);
    disp([sprintf('\t\t'),num2str(length(badinds)),...
         ' additional epochs rejected in moving window average']);

end
    
