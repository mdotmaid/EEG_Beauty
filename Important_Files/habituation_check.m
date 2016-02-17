function [goodinds, goodpks]  =  habituation_check(deviant,standard,localt,samplerate,interval);
% A function by Michelle Maiden
        [m,n] = size(deviant);
        stimpks  = zeros(1,m);
        ctr = 0;
        badinds = [];
        
    for si = 1:m
        ctr = ctr+1;
        stim3  = meanclean(deviant(si:si,:),samplerate);
        [sval,sloc] = mmn(deviant,standard,localt(1));
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
    goodinds = setxor(1:m,intersect(badinds,1:m));
    goodinds(goodinds>si)=[];
    goodpks  = stimpks(goodinds);
end
    
