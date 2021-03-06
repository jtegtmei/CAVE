function [imddFF] = deltaFF(imd,pn,fn,align)

%FUNCTION for applying the delta F/F calculation. The change in fluorescence
%over time is calculated by subtracting the mean frame of the whole video from
%every single frame and dividing the result by the mean frame. Additionally
%a gaussian blur is added for smoothing.

%INPUT      imd: calcium imaging video as 8-bit/16-bit with the dimensions
%           pixel widht, pixel height, number of frames
%           pn: pathname
%           fn: filename
%           align: signals whether alignment was done (value = 1) or not
%           (value = 0)

%OUTPUT     imddFF: resulting video from delta F/F calculation showing the
%           change in fluorescence over time.

%OPTIONAL   temporal filtering


global p

%deltaF/F
h=msgbox('Calculating deltaF/F... please wait!');
% %temporal filtering
% [bFilt,aFilt] = butter(p.options.dbutterd,p.options.dbutterd2, 'low');
%  imdd=zeros(size(imd));
% for kr=1:size(imd,1)
%      for kc=1:size(imd,2)
%         imdd(kr,kc,:)=filtfilt(bFilt,aFilt,double(imd(kr,kc,:))); %temporal low-passing
%      end
% end
%imd=imdd;
 
Fmean=mean(imd(:,:,1:100:end),3); %mean frame of whole video by taking every 100th frame
imddF=bsxfun(@rdivide,bsxfun(@minus,double(imd),Fmean),Fmean); %frame minus meanframe divided by meanframe

hhh = fspecial('gaussian', p.options.dgaussh, p.options.dgausss); %gaussian blur

imddFF=imfilter(imddF,hhh);
close(h);

%saving deltaF video
h=msgbox('Saving progress... Program might seem unresponsive, please wait!');
filename=[pn '\' fn 'dFvid.mat'];
deltaFimd=imddFF;
save(filename, 'deltaFimd','-v7.3');
%saving whether images were aligned
filename=[pn '\' fn 'vidalign'];
vidalign=align;
save(filename, 'vidalign');
close(h);