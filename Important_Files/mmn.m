function [val,loc,deviant] = mmn(deviant,standard,offset)
% Function by Michelle Maiden
        % Subtract Standard Response from Deviant Response
            deviant = deviant-standard(1:length(deviant));
        % Find MMN for average of Stimulus 3 responses
            [val,loc] = findpeaks(-deviant(offset+140:offset+210),'sortstr','descend','npeaks',1);
            val       = -val;
            loc       = loc+offset+140;
end
