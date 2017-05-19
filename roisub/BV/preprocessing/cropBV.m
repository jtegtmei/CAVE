function [imd] = cropBV(imd,cc)

% FUNCTION for cropping the behavioral video.
%
% INPUT     cc: cropping coordinates gathered from the ROI.
%
% OUTPUT    imd: cropped video

%cropping frames
h=waitbar(0,'Cropping frames');
for k=1:size(imd,2)
    imd(k).cdata=imd(k).cdata(cc(2):cc(2)+cc(4),cc(1):cc(1)+cc(3),:);
    waitbar(k/size(imd,2),h);
end
close(h);