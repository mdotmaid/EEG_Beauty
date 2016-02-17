function stimave = meanclean(stim,samplerate)
% Function by Michelle Maiden
    stimave  = mean(stim,1);
    % Send it through a lowpass filter
    stimave = mypop_filterp( stimave,samplerate, 1, 'Cutoff',30,...
                'Design','fir','Filter','lowpass','Order',96);
end
