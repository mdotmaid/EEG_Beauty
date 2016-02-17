% This script allows you to view already processed peak data
% WORK IN PROGRESS: please keep track of bugs and let Michelle know
%                   how it's going
allfile = 'CNT/altogether.mat';
disp(['Displaying Stimulus 3 data from: ', allfile]);
    load(allfile,'structpeak');
disp('Normally Processed Data');
disp('Subject            Cz              Fz              Pz');
for ii=1:length(structpeak.Subject)
    fprintf('  %d\t\t%f\t%f\t%f\n',[structpeak.Subject(ii) structpeak.CzPeaks(ii,:,3,1),...
          structpeak.FzPeaks(ii,:,3,1) structpeak.PzPeaks(ii,:,3,1)]);
end
disp('Habituation Check Data');
disp('Subject            Cz              Fz              Pz');
for ii=1:length(structpeak.Subject)
    fprintf('  %d\t\t%f\t%f\t%f\n',[structpeak.Subject(ii) structpeak.CzPeaks(ii,:,3,2),...
          structpeak.FzPeaks(ii,:,3,2) structpeak.PzPeaks(ii,:,3,2)]);
end
