function varargout = roisub(varargin)
% ROISUB MATLAB code for roisub.fig
%      ROISUB, by itself, creates a new ROISUB or raises the existing
%      singleton*.
%
%      H = ROISUB returns the handle to a new ROISUB or the handle to
%      the existing singleton*.
%
%      ROISUB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROISUB.M with the given input arguments.
%
%      ROISUB('Property','Value',...) creates a new ROISUB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roisub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roisub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%       
%       HOW TO USE THIS GUI FOR CALCIUM IMAGING DATA WITH DORIC
%       ENDOMICROSCOPE:
% 
%       -PREPARATIONS to work with this program: one TIFF file per folder &
%       test file named 'Framrate' containing only a number describing the
%       framerate of the calcium imaging video (TIFF file)
% 
%       -load .tif data recorded by doric endomicroscope by pushing SELECT
%       FOLDER button
% 
%       -LOW IN, HIGH IN, LOW OUT, HIGH OUT sliders for changes brightness
%       and contrast to investigate images (RESET resets values to initial
%       values)
% 
%       -FRAMES SLIDER for sliding through TIFF images from frame to frame
%       -PLAY button to play the video from current frame in FRAME SLIDER,
%       STOP for stopping the video immediately
% 
%       -PREPROCESSING downsamples the file to 40 percent, kicks out faulty
%       frames and does flat field correction; additionally gives you a 
%       graph of mean change over time
%       -if needed, ALIGN IMAGES allows to align the images to the first
%       frame
%
%       -DELTA F/F calculates the change over time of the video by
%       substracting a mean frame from each frame and dividng by the mean
%       frame
% 
%       -to define the ROIs use the ROI button. Define the area by clicking
%       around the wanted area. Corners can be adjusted afterwards by
%       hovering over it until one sees a circle symbol. Simply click and
%       drag to adjust the corner. If you place the cursor over the middle
%       the cursor should change into a cross which allows you to shift the
%       selected area. If you are satisfied double-click.
%       You can press the ROI button multiple times to define as many ROIs
%       as you want. In case you want to clear all ROIs and start over,
%       please use the CLEAR ALL ROIS button
%       -to remove a ROI or parts of it simply overlap with a new ROI
%       -to define a lot of ROIs use the THRESHOLD slider to define a
%       threshold and then click THRESHOLD ROIS to aplly the threshold
%       -if you already defined ROIs or you want to use a ROI mask from
%       another video press LOAD ROIS
%       -to show changes in brightness over time from your defined ROIs
%       use PLOT ROIS
%
%       HOW TO ANALYZE THE BEHAVIORAL VIDEO:
%       -load video by pushing SELECT FOLDER button
%       -crop the video to the area in which the mouse is moving by pushing
%       the CROP VIDEO button by simply clicking and dragging the cursor
%       over the desired area. You can adjust the are by hovering over the
%       edges and then click and dragging it. If you are satisfied with the
%       defined area, right-click, press Copy Position, and double-click
%       onto the screen. In the dialog window simply press NEXT and FINISH.
%       The CROP VIDEO also automatically downsamples the cropped video
%       -convert the RGB video to HSV color space by pushing CONVERT TO HSV
%       COLOR SPACE
%       -press GREEN or PINK PRESETS to use the defined threshold presets
%       for the respective spot. Adjust the thresholds if needed to extract
%       only the green/pink spot from the back of the mouse by using the
%       HUE, SATURATION, and VALUE THRESHOLD LOW and HIGH
%       -apply the spot to all frames by pushing the SAVE GREEN/PINK SPOT
%       -scroll through all frames to check if spot is detected in all/most
%       of the frames; if not, set threshold again and then push SAVE
%       GREEN/PINK SPOT again
%       -to show the movement of the animal push TRACE ANIMAL, it will
%       display movement of the green spot in green and the movement of the
%       pink spot in red. Additionally it will show a heat map
%       corresponding to each cell that was active during that frame
%
%
%       SOURCES USED: threshold.m; SimpleColorDetectionByHue; Mohammed Ali
%       2016 Paper 'An integrative approach for analyzing hundreds of
%       neurons in task performing mice using wide-field calcium imaging.'
%       
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roisub

% Last Modified by GUIDE v2.5 27-Dec-2016 18:07:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roisub_OpeningFcn, ...
                   'gui_OutputFcn',  @roisub_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before roisub is made visible.
function roisub_OpeningFcn(hObject, eventdata, handles, varargin)
clear global d;
clear global v;
global d
global v
global p
p.pn=[];
%initializing variables needed before hand
v.pushed=0; %no video loaded
d.pushed=0; %no video loaded
d.bcount=0; %no. of rois selected equals zero
d.roisdefined=0; %no rois defined
d.play=0;
v.play=0;
v.pn=[];
d.pn=[];
d.thresh=0;
d.valid=0;
d.align=0; %signals whether images were aligned
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roisub (see VARARGIN)

% Choose default command line output for roisub
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roisub wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roisub_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------

%% DORIC CAMERA CODE


%%---------------------------Processing calcium imaging video

% --- Executes on button press in pushbutton5.                   LOAD DORIC
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
%clears cache
%clears all global variables
clear global d;
%reinitializes global variables
global d
d.pushed=0;
d.bcount=0;
d.roisdefined=0;
d.play=0;
d.thresh=0;
d.valid=0;
d.dF=0;
d.load=0;
d.align=0;
d.pre=0;
d.mip=0;
d.pn=[];
%clears axes
cla(handles.axes1,'reset');
%resets frame slider
handles.slider7.Value=1;
%resets values of low in/out, high in/out to start values
handles.slider5.Value=0;
handles.slider15.Value=1;
handles.slider6.Value=0;
handles.slider16.Value=1;

if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

% ms.UseParallel = true; %initializes parallel processing
d.perc=[]; %initializing ROI values in percent as empty

%defining initial folder displayed in dialog window
if isempty(p.pn)==1;
    [d.pn]=uigetdir('F:\jenni\Documents\PhD PROJECT\Calcium Imaging\doric camera\');
else
    [d.pn]=uigetdir(p.pn);
end

%clears old behavioral video if new calcium imaging video is loaded
if v.pushed==1 && strcmp(v.pn,d.pn)==0;
    %clears cache
    %clears all global variables
    clear global v;
    %clears axes
    cla(handles.axes2,'reset');
    return;
end

%extracts filename
filePattern = fullfile(d.pn, '*.tif'); % *.tiff for 2-P
Files = dir(filePattern);
d.fn = Files(1).name;

%defining dimensions of video
frames=size(imfinfo([d.pn '\' d.fn]),1);
x=imfinfo([d.pn '\' d.fn]);
Width=x(1).Width;
Height=x(1).Height;

%asking frame rate of the CI video
try
   d.framerate=csvread([d.pn '\Framerate.txt']);
catch ME
   if (strcmp(ME.identifier,'MATLAB:csvread:FileNotFound'))
        prompt = {'Enter framerate:'};
        dlg_title = 'Input';
        num_lines = 1;
        answer = inputdlg(prompt,dlg_title,num_lines);
        d.framerate=str2num(cell2mat(answer));
   end
end 

%check whether ROI mask had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn));
    tf(k)=strcmp([d.fn(1:end-4) '.mat'],files(k).name);
end
if sum(tf)>0;
    % Construct a questdlg with two options
    choice = questdlg('Would you like to load your last processed version?', ...
        'Attention', ...
        'YES','NO','YES');
    % Handle response
    switch choice
        case 'YES'
            %loading delta F/F video
            load([d.pn '\' d.fn(1:end-4) 'dFvid']);
            d.imd=deltaFimd;
            %loading MIP
            MaxIntensProj = max(d.imd, [], 3);
            stdIm = std(d.imd,0,3);
            d.mip=MaxIntensProj./stdIm;
            figure,imagesc(d.mip),title('Maximum Intensity Projection');
            %loading ROI mask
            load([d.pn '\' d.fn(1:end-4) '.mat']);
            d.mask=ROImask;
            d.ROIorder=ROIorder;
            %plotting ROIs
            colors={[0    0.4471    0.7412],...
                [0.8510    0.3255    0.0980],...
                [0.9294    0.6941    0.1255],...
                [0.4941    0.1843    0.5569],...
                [0.4667    0.6745    0.1882],...
                [0.3020    0.7451    0.9333],...
                [0.6353    0.0784    0.1843],...
                [0.6784    0.9216    1.0000]};

            singleFrame=d.imd(:,:,round(handles.slider7.Value));
            axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
            B=bwboundaries(d.mask); %boundaries of ROIs
            d.labeled=bwlabel(d.mask);
            stat = regionprops(d.labeled,'Centroid');
            d.b=cell(length(B),1);
            d.c=cell(length(B),1);
            colors=repmat(colors,1,ceil(length(B)/8));
            for j = 1 : length(B);
                d.b{j,1} = B{j};
                d.c{j,1} = stat(j).Centroid;
                plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
            end
            hold off;
            d.pushed=4; %signals that ROIs were selected
            d.roisdefined=1; %signals that ROIs were defined

            % label ROIs
            background=d.mask;
            background(background==1)=2;
            background(background==0)=1;
            background(background==2)=0;
            CC=bwconncomp(d.mask);
            numROIs=CC.NumObjects; %number of ROIs
            d.imdThresh=cell(size(d.imd,3),numROIs);
            d.ROIs=cell(size(d.imd,3),numROIs);
            d.background=cell(size(d.imd,3),1);
            d.bg=cell(size(d.imd,3),1);
            h=waitbar(0,'Labeling ROIs');
            for j=1:size(d.imd,3);
                for i=1:numROIs;
                    ROIs=zeros(size(d.imd,1),size(d.imd,2));
                    m = find(d.labeled==i);
                    ROIs(m)=1;
                    % You can only multiply integers if they are of the same type.
                    ROIs = cast(ROIs, class(d.imd(:,:,1)));
                    d.imdThresh{j,i} = ROIs .* d.imd(:,:,j);
                    d.ROIs{j,d.ROIorder(i)}=d.imdThresh{j,i}(m);
                end
                % You can only multiply integers if they are of the same type.
                nn = find(background==1);
                background = cast(background, class(d.imd(:,:,1)));
                d.background{j,1} = background .* d.imd(:,:,j);
                d.bg{j,1}=d.background{j,1}(nn);
                waitbar(j/size(d.imd,3),h);
            end
            %relabeling d.labeled
            labels=zeros(size(d.imd,1),size(d.imd,2));
            for i=1:numROIs;
                m = find(d.labeled==i);
                labels(m)=d.ROIorder(i);
            end
            d.labeled=labels;
            d.load=1; %signals that a ROI mask was loaded
            close(h);

            %loading original calcium imaging video
            % Construct a questdlg with two options
            choice = questdlg('Would you also like to load the original calcium imaging video?', ...
                'Attention', ...
                'YES','NO','YES');
            % Handle response
            switch choice
                case 'YES'
                    if length(Files)==1;
                        %putting each frame into variable 'Images'
                        h=waitbar(0,'Loading');
                        for k = 1:frames;
                            % Read in image into an array.
                            fullFileName = fullfile([d.pn '\' d.fn]);
                            Image = imread(fullFileName,k);
                            % Check to see if it's an 8-bit image needed later for scaling).
                            if strcmpi(class(Image), 'uint8')
                                % Flag for 256 gray levels.
                                eightBit = true;
                            else
                                eightBit = false;
                            end
                            if eightBit
                                Images = Image;
                            else
                            Imaged=double(Image);
                            Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                            end
                            imd(:,:,k) = Images;
                            waitbar(k/frames,h);
                        end
                        d.origCI=imd;
                    else
                        %putting each frame into variable 'images'
                        h=waitbar(0,'Loading');
                        for k = 1:length(Files);
                            waitbar(k/length(Files),h);
                            baseFileName = Files(k).name;
                            fullFileName = fullfile([d.pn '\' baseFileName]);
                            Image = imread(fullFileName); 
                            % Check to see if it's an 8-bit image needed later for scaling).
                            if strcmpi(class(Image), 'uint8')
                                % Flag for 256 gray levels.
                                eightBit = true;
                            else
                                eightBit = false;
                            end
                            if eightBit
                                Images = Image;
                            else
                            Imaged=double(Image);
                            Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                            end
                            imd(:,:,k) = Images;
                        end
                        d.origCI=imd;
                    end
                    d.dF=1;
                    load([d.pn '\' d.fn(1:end-4) 'vidalign']);
                    d.align=vidalign;
                    d.pre=1;

                    msgbox('Loading complete!');
                case 'NO'
                    d.dF=1;
                    load([d.pn '\' d.fn(1:end-4) 'vidalign']);
                    d.align=vidalign;
                    d.pre=1;
            end
        case 'NO'
            if length(Files)==1;
                %putting each frame into variable 'Images'
                h=waitbar(0,'Loading');
                for k = 1:frames;
                    % Read in image into an array.
                    fullFileName = fullfile([d.pn '\' d.fn]);
                    Image = imread(fullFileName,k);
                    % Check to see if it's an 8-bit image needed later for scaling).
                    if strcmpi(class(Image), 'uint8')
                        % Flag for 256 gray levels.
                        eightBit = true;
                    else
                        eightBit = false;
                    end
                    if eightBit
                        Images = Image;
                    else
                    Imaged=double(Image);
                    Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                    end
                    d.imd(:,:,k) = Images;
                    waitbar(k/frames,h);
                end

                d.pushed=1; %signals that file was selected
                d.roisdefined=0; %no rois defined
                d.b=[];
                d.c=[];
                d.dF=0;
                d.load=0;
                d.align=0;
                d.pre=0;
                d.mip=0;
                d.origCI=[];

                %looking at first original picture
                axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
            else
                %putting each frame into variable 'images'
                h=waitbar(0,'Loading');
                for k = 1:length(Files);
                    waitbar(k/length(Files),h);
                    baseFileName = Files(k).name;
                    fullFileName = fullfile([d.pn '\' baseFileName]);
                    Image = imread(fullFileName); 
                    % Check to see if it's an 8-bit image needed later for scaling).
                    if strcmpi(class(Image), 'uint8')
                        % Flag for 256 gray levels.
                        eightBit = true;
                    else
                        eightBit = false;
                    end
                    if eightBit
                        Images = Image;
                    else
                    Imaged=double(Image);
                    Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
                    end
                    d.imd(:,:,k) = Images;
                end

                d.pushed=1; %signals that file was selected
                d.roisdefined=0; %no rois defined
                d.b=[];
                d.c=[];
                d.dF=0;
                d.load=0;
                d.align=0;
                d.pre=0;
                d.mip=0;
                d.origCI=[];

                %looking at first original picture
                axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
            end
    end

elseif length(Files)==1;
    %putting each frame into variable 'Images'
    h=waitbar(0,'Loading');
    for k = 1:frames;
        % Read in image into an array.
        fullFileName = fullfile([d.pn '\' d.fn]);
        Image = imread(fullFileName,k);
        % Check to see if it's an 8-bit image needed later for scaling).
        if strcmpi(class(Image), 'uint8')
            % Flag for 256 gray levels.
            eightBit = true;
        else
            eightBit = false;
        end
        if eightBit
            Images = Image;
        else
        Imaged=double(Image);
        Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
        end
        d.imd(:,:,k) = Images;
        waitbar(k/frames,h);
    end
    
    d.pushed=1; %signals that file was selected
    d.roisdefined=0; %no rois defined
    d.b=[];
    d.c=[];
    d.dF=0;
    d.load=0;
    d.align=0;
    d.pre=0;
    d.mip=0;
    d.origCI=[];
    
    %looking at first original picture
    axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
else
    %putting each frame into variable 'images'
    h=waitbar(0,'Loading');
    for k = 1:length(Files);
        waitbar(k/length(Files),h);
        baseFileName = Files(k).name;
        fullFileName = fullfile([d.pn '\' baseFileName]);
        Image = imread(fullFileName); 
        % Check to see if it's an 8-bit image needed later for scaling).
        if strcmpi(class(Image), 'uint8')
            % Flag for 256 gray levels.
            eightBit = true;
        else
            eightBit = false;
        end
        if eightBit
            Images = Image;
        else
        Imaged=double(Image);
        Images =uint16(Imaged./max(max(Imaged,[],2))*65535);
        end
        d.imd(:,:,k) = Images;
    end
    
    d.pushed=1; %signals that file was selected
    d.roisdefined=0; %no rois defined
    d.b=[];
    d.c=[];
    d.dF=0;
    d.load=0;
    d.align=0;
    d.pre=0;
    d.mip=0;
    d.origCI=[];
    
    %looking at first original picture
    axes(handles.axes1); imshow(d.imd(:,:,1));colormap(handles.axes1, gray);
end
p.pn=d.pn;

titleLabel = ['Calcium imaging video: ' d.fn];
set(handles.text27, 'String', titleLabel);
handles.text27.TooltipString=d.pn;
textLabel = sprintf('%d / %d', 1,size(d.imd,3));
set(handles.text36, 'String', textLabel);

msgbox('Loading Completed.','Success');






% --- Executes on slider movement.                           CHANGES LOW IN
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider5.Value changes low in value
if d.pushed==4 || d.roisdefined==1;
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                          CHANGES LOW OUT
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider6.Value changes low out value
if d.pushed==4 || d.roisdefined==1;
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                          CHANGES HIGH IN
function slider15_Callback(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider15.Value changes high in value
if d.pushed==4 || d.roisdefined==1;
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                         CHANGES HIGH OUT
function slider16_Callback(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.pre==1 || d.dF==1;
    msgbox('Image is displayed scaled! No need to adjust!','ATTENTION');
    return;
end

%handles.slider16.Value changes high out value
if d.pushed==4 || d.roisdefined==1;
    singleFrame=imadjust(d.origCI(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); hold on;
    for k=1:size(d.b,1);
    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2);
    text(d.c{k,1}(1),d.c{k,1}(2),num2str(k));
    end
    hold off;
    d.pushed=4;
else
    d.pushed=1;
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1); imshow(singleFrame); %shows image in axes1
end

% --- Executes during object creation, after setting all properties.
function slider16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton22.                       RESET
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%resets values of low in/out, high in/out to start values
handles.slider5.Value=0;
handles.slider15.Value=1;
handles.slider6.Value=0;
handles.slider16.Value=1;
singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
axes(handles.axes1); imshow(singleFrame); %shows image in axes1






% --- Executes on button press in pushbutton23.               PREPROCESSING
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
if d.pre==1;
    msgbox('You already did preprocessing!','ATTENTION');
    return;
end
%variable initialization
imd=cast(zeros(ceil(size(d.imd,1)*0.4),ceil(size(d.imd,2)*0.4),size(d.imd,3)),class(d.imd));
meanChange=diff(mean(mean(d.imd,1),2));

%Downsampling
h=waitbar(0,'Downsampling');
for k=1:size(d.imd,3);
    imd(:,:,k)=imresize(d.imd(:,:,k),0.4); %evt. medfilt2() as median filter, downsampling fixed with 0.4
    waitbar(k/size(d.imd,3),h);
end
close(h);

%Eliminating faulty frames
h=waitbar(0,'Eliminating faulty frames');
for k=1:size(meanChange,3);
    if meanChange(1,1,k)<-(5*median(abs(meanChange)/0.6745)) || meanChange(1,1,k)>5*median(abs(meanChange)/0.6745);
        if k+1 <= size(meanChange,3) && (meanChange(1,1,k)~=meanChange(1,1,k+1));
            imd(:,:,k+1)=imd(:,:,k);
%         elseif k+1 <= size(meanChange,3) && (meanChange(1,1,k)==meanChange(1,1,k+1));
%             imd(:,:,k+1)=imd(:,:,k+3); % k+3 when the glitch lasted 2 frames!
        else
            imd(:,:,k+1)=imd(:,:,k-1);
        end
    end
    waitbar(k/size(meanChange,3),h);
end
d.imd=imd;
close(h);

d.origCI=imresize(d.imd,0.805); %keeping this file stored as original video

%flatfield correction
H = fspecial('average',round(.08*size(d.imd,1))); %8 % blur
a=(imfilter(d.imd(:,:,1),H,'replicate')); %blur frame totally
d.imd=uint16(single(max(max(d.imd(:,:,1))))*bsxfun(@rdivide,single(d.imd),single(a)));
s=size(d.imd); %cut middle 80 % of image
d.imd=d.imd(round(.1*s(1)):round(.9*s(1)),round(.1*s(2)):round(.9*s(2)),:);

%showing resulting frame
singleFrame=d.imd(:,:,round(handles.slider7.Value));
axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);

d.pre=1;
%plotting mean change along the video
meanChange=diff(mean(mean(d.imd,1),2));
h=figure,plot(squeeze(meanChange)),title('Mean brightness over frames'),xlabel('Number of frames'),ylabel('Brightness in uint16');
name=('Mean Change');
path=[d.pn '/',name,'.png'];
path=regexprep(path,'\','/');
print(h,'-dpng','-r100',path); %-depsc for vector graphic
msgbox('Preprocessing done!','Success');


% --- Executes on button press in pushbutton9.                ALIGNS IMAGES
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.pre==0;
    msgbox('Please do preprocessing before proceeding!','ATTENTION');
    return;
end
% adapted from source: http://de.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html
if d.dF==1;
     msgbox('Please align before calculating dF/F.','Attention');
     return
end

if handles.radiobutton1.Value==1;
    %SURF feature detection to align images
    imgA = d.imd(:,:,1);
    imgC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
    imgC(:,:,1) =  d.imd(:,:,1);
    %aligning images to first image
    h=waitbar(0,'Aligning images');
    for k=1:size(d.imd,3)-1;
        imgB=d.imd(:,:,k+1);
        % figure(1); imshowpair(imgA,imgB,'ColorChannels','red-cyan');
        %detecting SURF features in first image and following images
        pointsA = detectSURFFeatures(imgA);
        pointsB = detectSURFFeatures(imgB);
    %     if isempty(pointsA)==1;
    % %         pointsA = detectHarrisFeatures(imgA);
    % %         pointsB = detectHarrisFeatures(imgB);
    %         [optimizer,metric] = imregconfig('monomodal');
    %         for j=1:size(d.imd,3)-1;
    %             imgB=d.imd(:,:,j+1);
    %             imgC(:,:,j+1) = imregister(imgB,imgA,'rigid',optimizer,metric);
    %             waitbar(j/(size(d.imd,3)-1),h);
    %         end
    %         d.imd=imgC;singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    %         axes(handles.axes1); imshow(singleFrame);
    %         close(h);
    %         % d.pushed=2; %signals that images were aligned
    %         msgbox('Aligning Completed.','Success');
    %         break
    %     end
        %extract FREAK descriptors for the SURF features
        [featuresA, pointsA] = extractFeatures(imgA, pointsA);
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        %match features of both pictures
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        %extract location coordinates of matched points
        pointsA=pointsA.Location;
        pointsB=pointsB.Location;
        %if there are no matching points, set the matrix to zeros
        if isempty(pointsA)==1;
            pointsA=zeros(1,2);
        end
        if isempty(pointsB)==1;
            pointsB=zeros(1,2);
        end
        %calculate shifting vector from matched points, how was the points
        %shifted from A to B
        tvector=[round(mean(pointsA(:,2)-pointsB(:,2))) round(mean(pointsA(:,1)-pointsB(:,1)))];
        if sum(tvector)<=5 && sum(tvector)>=-5 || sum(tvector)>=100 || sum(tvector)<=-100; %boundaries for not changing current image
            imgC(:,:,k+1)=imgB;
        else
            imgC(:,:,k+1)=circshift(imgB,tvector);
        end
        % figure(1); imshowpair(imgA,imgC(:,:,k+1),'ColorChannels','red-cyan');
        waitbar(k/(size(d.imd,3)-1),h);
    end
    d.imd=imgC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    close(h);
else
    %Lucas Kanade algorithm to align images
    transform = 'euclidean';
    % parameters for ECC and Lucas-Kanade 
    par = [];
    par.levels =    2;
    par.iterations = 30;
    par.transform = transform;
    tmp= d.imd(:,:,1);
    imgC = cast(zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3)),class(d.imd));
    imgC(:,:,1) =  d.imd(:,:,1);
    h=waitbar(0,'Aligning images');
    for k=1:size(d.imd,3)-1;
        img=d.imd(:,:,k+1);
        [LKWarp]=iat_LucasKanade(img,tmp,par);
        % Compute the warped image and visualize the error
        [wimageLK, supportLK] = iat_inverse_warping(img, LKWarp, par.transform, 1:size(tmp,2),1:size(tmp,1));
%         % draw mosaic
%         LKMosaic = iat_mosaic(tmp,img,[LKWarp; 0 0 1]);
        imgC(:,:,k)=wimageLK;
        waitbar(k/(size(d.imd,3)-1),h);
    end
    d.imd=imgC;
    %showing resulting frame
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    close(h);
end


d.align=1; %signals that images were aligned
msgbox('Aligning Completed.','Success');
if d.pushed==4;
    %resets all varibles needed for selecting ROIs
    d.bcount=0; %signals ROI button was not pressed
    d.pushed=1; %signals video was loaded
    d.ROIs=[];
    d.labeled = zeros(size(d.imd,1),size(d.imd,2));
    d.bg=[];
    d.b=[];
    d.c=[];
    d.roisdefined=0; %signals no ROIs were selected
    msgbox('Please re-select ROIs!','ATTENTION');
    return;
end


% --- Executes on button press in pushbutton28.            RESETS ALIGNMENT
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
d.imd=d.origCI;
d.align=0; %signals that image alignment was reset
msgbox('Alignment reset!');


% --- Executes on button press in pushbutton25.                   DELTA F/F
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d

if d.pre==0;
    msgbox('Please do preprocessing before proceeding!','ATTENTION');
    return;
end

if d.dF==1;
    msgbox('You already did delta F/F calculation!','ATTENTION');
    return;
end

%setting aligned images as original CI video
if d.align==1;
    d.origCI=d.imd;
end

%deltaF/F
h=waitbar(0,'Calculating deltaF/F');
Fmean=mean(d.imd(:,:,1:100:end),3); %% insert slight blurring filter?
imddF=bsxfun(@rdivide,bsxfun(@minus,double(d.imd),Fmean),Fmean);
    %temporal filter below was removed because of artifacts
    % [bFilt,aFilt] = butter(4,.5, 'low');
    % 
    % for kr=1:size(imddF,1)
    %     for kc=1:size(imddF,2)
    %        imddF(kr,kc,:)=filtfilt(bFilt,aFilt,imddF(kr,kc,:)); %temporal low-passing
    %     end
    % %     disp(kr);
    % end

hhh = fspecial('gaussian', 5, 5);
%SE = strel('disk', 15);

for k=1:size(d.imd,3);
%    imddF(:,:,k)=imtophat(imddF(:,:,k),SE);
%     imddF(imddF(:,:,k)<(max(max(imddF(:,:,k)))*0.5))=0;
    imddF(:,:,k)=imfilter(imddF(:,:,k),hhh); %filter taken from miniscope msRun ()
%     IM=imbothat(imddF(:,:,k),SE);
%     imddF(:,:,k)=imsubtract(imddF(:,:,k),IM);
%     imddF(:,:,k)=imclearborder(imddF(:,:,k),8);
    waitbar(k/size(d.imd,3),h);
end
d.imd=imddF;
close(h);

%saving deltaF video
h=msgbox('Program might seem unresponsive, please wait!');
filename=[d.pn '\' d.fn(1:end-4) 'dFvid'];
deltaFimd=d.imd;
save(filename, 'deltaFimd');
%saving whether images were aligned
filename=[d.pn '\' d.fn(1:end-4) 'vidalign'];
vidalign=d.align;
save(filename, 'vidalign');
close(h);

%variable initialization for ROI processing
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.ROIs=[];

%showing resulting frame
singleFrame=d.imd(:,:,round(handles.slider7.Value));
axes(handles.axes1);imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
d.dF=1;
%finding cells with maximum intensity projection and standard deviation
MaxIntensProj = max(d.imd, [], 3);
stdIm = std(d.imd,0,3);
d.mip=MaxIntensProj./stdIm;
if handles.radiobutton2.Value==1;
    h=figure,imagesc(d.mip),title('Maximum Intensity Projection');
else
    h=figure,imagesc(d.mip),title('Maximum Intensity Projection');
end
name=('MIP');
path=[d.pn '/',name,'.png'];
path=regexprep(path,'\','/');
print(h,'-dpng','-r100',path); %-depsc for vector graphic
msgbox('Calculation done!','Success');







% --- Executes on button press in pushbutton3.                         ROIs
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
if d.dF==0;
    msgbox('Please perform Delta F/F calculation before selection ROIs!','ATTENTION');
    return;
end

colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};


%display instructions only if the button was pressed for the first time or
%a mistake was made
if d.bcount==0 || d.valid==1;
    d.valid=0;
    uiwait(msgbox('Please define the region of interest (ROI) by clicking around the area. The corners can be moved afterwards as well as the whole selected area. When satisfied with the selection please double-click!','Attention','modal'));
end

%displaying picture with previously marked ROIs
axes(handles.axes1);
if d.bcount>0;
    colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    singleFrame=d.mip./max(max(d.mip));
    axes(handles.axes1); imshow(singleFrame);hold on;
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    f=getframe(handles.axes1);
    singleFrame=f.cdata;
elseif d.load==1;
    colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
    singleFrame=d.mip./max(max(d.mip));
    axes(handles.axes1); imshow(singleFrame);hold on;
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    f=getframe(handles.axes1);
    singleFrame=f.cdata;
elseif d.bcount==0;
    singleFrame=d.mip./max(max(d.mip));
end

%manual ROI selection
ROI = roipoly(singleFrame);    %uint8 for CI_win_S1HL_02/20151118 & DORIC; int16 for CI_S1Hl_02
if d.bcount>0 || d.load==1;
    B=zeros(size(d.mip,1),size(d.mip,2));
    B=imresize(ROI, [size(d.mip,1) size(d.mip,2)]);
    ROI=B;
end
%check if ROI was selected correctly
if numel(find(ROI))==0;
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    d.valid=1;
    msgbox('Please select valid ROI! Check the instructions again.','ERROR');
    return;
end
%count times button is pressed
d.bcount=d.bcount+1;

if d.load==1;
    d.labeled = d.labeled+(ROI*(max(max(d.labeled))+1)); %labeling of ROIs
    d.mask = d.mask+ROI;
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0;
        choice = questdlg('Would you like to remove this ROI?', ...
        'Attention', ...
        'YES','NO','YES');
        % Handle response
        switch choice
            case 'YES'
                d.mask=d.mask-(2*ROI);
                d.mask(d.mask<0)=0;
                d.labeled=bwlabel(d.mask);
                % relabel ROIs
                n=size(d.imd,3);
                CC=bwconncomp(d.mask);
                numROIs=CC.NumObjects; %number of ROIs
                d.imdrem=cell(size(d.imd,3),numROIs);
                d.ROIs=cell(size(d.imd,3),numROIs);
                h=waitbar(0,'Relabeling ROIs');
                for j=1:n;
                    for i=1:numROIs;
                        ROIs=zeros(size(d.imd,1),size(d.imd,2));
                        m = find(d.labeled==i);
                        ROIs(m)=1;
                        % You can only multiply integers if they are of the same type.
                        ROIs = cast(ROIs, class(d.imd(:,:,1)));
                        d.imdrem{j,i} = ROIs .* d.imd(:,:,j);
                        d.ROIs{j,i}=d.imdrem{j,i}(m);
                    end
                    waitbar(j/size(d.imd,3),h);
                end
                close(h);
                %plotting ROIs
                singleFrame=d.imd(:,:,round(handles.slider7.Value));
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid');
                %check whether ROIs are touching
                if length(stat)>length(B);
                    d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                    d.mask = d.mask-ROI;
                    singleFrame=d.mip;
                    if d.dF==1 || d.pre==1;
                        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                    else
                        axes(handles.axes1); imshow(singleFrame); hold on;
                    end
                    stat = regionprops(d.labeled,'Centroid');
                    for k=1:size(d.b,1);
                        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                    end
                    hold off;
                    msgbox('Please do not let ROIs touch!','ERROR');
                    return;
                end
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
                for j = 1 : size(d.ROIs,2);
                    d.b{j,1} = B{j};
                    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
                    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
                end
                hold off;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask
                % Construct a questdlg with two options
                choice = questdlg('Would you like to save this ROI mask?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                switch choice
                    case 'YES'
                        %saving ROI mask
                        filename=[d.pn '\' d.fn(1:end-4)];
                        ROImask=d.mask;
                        ROIorder=d.ROIorder;
                        save(filename, 'ROImask','ROIorder');
                    case 'NO'
                        return;
                end
                return;
            case 'NO'
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                d.labeled(d.labeled<0)=0;
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                stat = regionprops(d.labeled,'Centroid');
                for k=1:size(d.b,1);
                    d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                    text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                end
                hold off;
                msgbox('Please do not superimpose ROIs!','ERROR');
                d.mask = d.mask-ROI;
                return;
        end
    else
        d.mask(d.mask>0)=1;
    end
    %values from video in ROIs
    h=waitbar(0,'Labeling ROIs');
    imdROI=cell(size(d.imd,3),(max(max(d.labeled))));
    for k = 1:size(d.imd,3);
        m = find(d.labeled==(max(max(d.labeled))));
        ROI = cast(ROI, class(d.imd(:,:,1)));
        imdROI{k,(max(max(d.labeled)))} = ROI.*d.imd(:,:,k); %applying ROI mask to real values
        d.ROIs{k,(max(max(d.labeled)))}= imdROI{k,(max(max(d.labeled)))}(m);
        waitbar(k/size(d.imd,3),h);
    end
    close(h);
    

    %plotting ROIs
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    B=bwboundaries(d.mask); %boundaries of ROIs
    stat = regionprops(d.labeled,'Centroid');
    %check whether ROIs are touching
    if length(stat)>length(B);
        d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
        d.mask = d.mask-ROI;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for k=1:size(d.b,1);
            d.c{k,1} = stat(d.ROIorder(k)).Centroid;
            plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
            text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
        end
        hold off;
        msgbox('Please do not let ROIs touch!','ERROR');
        return;
    end
    d.b=cell(length(B),1);
    d.c=cell(length(B),1);
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(colors,1,ceil((max(max(d.labeled))+1)/8));
    for j = 1 : length(B);
        d.b{j,1} = B{j};
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
    hold off;
    d.pushed=4; %signals that ROIs were selected
    d.roisdefined=1; %signals that ROIs were defined

    %saving ROI mask
    filename=[d.pn '\' d.fn(1:end-4)];
    ROImask=d.mask;
    ROIorder=d.ROIorder;
    save(filename, 'ROImask','ROIorder');
else
    d.labeled = d.labeled+ROI*(max(max(d.labeled))+1); %labeling of ROIs
    d.mask = d.mask+ROI;
    %checking if ROIs are superimposed on each other
    if numel(find(d.mask>1))>0;
        choice = questdlg('Would you like to remove this ROI?', ...
        'Attention', ...
        'YES','NO','YES');
        % Handle response
        switch choice
            case 'YES'
                d.mask=d.mask-(2*ROI);
                d.mask(d.mask<0)=0;
                d.labeled=bwlabel(d.mask);
                % relabel ROIs
                n=size(d.imd,3);
                CC=bwconncomp(d.mask);
                numROIs=CC.NumObjects; %number of ROIs
                d.imdrem=cell(size(d.imd,3),numROIs);
                d.ROIs=cell(size(d.imd,3),numROIs);
                h=waitbar(0,'Relabeling ROIs');
                for j=1:n;
                    for i=1:numROIs;
                        ROIs=zeros(size(d.imd,1),size(d.imd,2));
                        m = find(d.labeled==i);
                        ROIs(m)=1;
                        % You can only multiply integers if they are of the same type.
                        ROIs = cast(ROIs, class(d.imd(:,:,1)));
                        d.imdrem{j,i} = ROIs .* d.imd(:,:,j);
                        d.ROIs{j,i}=d.imdrem{j,i}(m);
                    end
                    waitbar(j/size(d.imd,3),h);
                end
                close(h);
                %plotting ROIs
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                B=bwboundaries(d.mask); %boundaries of ROIs
                stat = regionprops(d.labeled,'Centroid');
                %check whether ROIs are touching
                if length(stat)>length(B);
                    d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                    d.mask = d.mask-ROI;
                    singleFrame=d.mip;
                    if d.dF==1 || d.pre==1;
                        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                    else
                        axes(handles.axes1); imshow(singleFrame); hold on;
                    end
                    stat = regionprops(d.labeled,'Centroid');
                    for k=1:size(d.b,1);
                        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                    end
                    hold off;
                    msgbox('Please do not let ROIs touch!','ERROR');
                    return;
                end
                d.b=cell(length(B),1);
                d.c=cell(length(B),1);
                d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
                colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
                for j = 1 : size(d.ROIs,2);
                    d.b{j,1} = B{j};
                    d.c{j,1} = stat(d.ROIorder(j)).Centroid;
                    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
                    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
                end
                hold off;
                d.pushed=4; %signals that ROIs were selected
                d.roisdefined=1; %signals that ROIs were defined

                %saving ROI mask & ROI order
                % Construct a questdlg with two options
                choice = questdlg('Would you like to save this ROI mask?', ...
                    'Attention', ...
                    'YES','NO','YES');
                % Handle response
                switch choice
                    case 'YES'
                        %saving ROI mask
                        filename=[d.pn '\' d.fn(1:end-4)];
                        ROImask=d.mask;
                        ROIorder=d.ROIorder;
                        save(filename, 'ROImask','ROIorder');
                    case 'NO'
                        return;
                end
                return;
            case 'NO'
                d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
                d.mask = d.mask-ROI;
                singleFrame=d.mip;
                if d.dF==1 || d.pre==1;
                    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
                else
                    axes(handles.axes1); imshow(singleFrame); hold on;
                end
                stat = regionprops(d.labeled,'Centroid');
                for k=1:size(d.b,1);
                    d.c{k,1} = stat(d.ROIorder(k)).Centroid;
                    plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
                    text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
                end
                hold off;
                msgbox('Please do not superimpose ROIs!','ERROR');
                return;
        end
    else
        d.mask(d.mask>0)=1;
    end
    %values from video in ROIs
    h=waitbar(0,'Labeling ROIs');
    for k = 1:size(d.imd,3);
        m = find(d.labeled==(max(max(d.labeled))));
        ROI = cast(ROI, class(d.imd(:,:,1)));
        imdROI{k,(max(max(d.labeled)))} = ROI.*d.imd(:,:,k); %applying ROI mask to real values
        d.ROIs{k,(max(max(d.labeled)))}= imdROI{k,(max(max(d.labeled)))}(m);
        waitbar(k/size(d.imd,3),h);
    end
    close(h);
    

    %plotting ROIs
    singleFrame=d.mip;
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
    else
        axes(handles.axes1); imshow(singleFrame); hold on;
    end
    B=bwboundaries(d.mask); %boundaries of ROIs
    stat = regionprops(d.labeled,'Centroid');
    %check whether ROIs are touching
    if length(stat)>length(B);
        d.labeled = d.labeled-(ROI*(max(d.ROIorder)+1));
        d.mask = d.mask-ROI;
        singleFrame=d.mip;
        if d.dF==1 || d.pre==1;
            imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
        else
            axes(handles.axes1); imshow(singleFrame); hold on;
        end
        stat = regionprops(d.labeled,'Centroid');
        for k=1:size(d.b,1);
            d.c{k,1} = stat(d.ROIorder(k)).Centroid;
            plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
            text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
        end
        hold off;
        msgbox('Please do not let ROIs touch!','ERROR');
        return;
    end
    d.b=cell(length(B),1);
    d.c=cell(length(B),1);
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
    colors=repmat(colors,1,ceil((max(max(d.labeled))+1)/8));
    for j = 1 : length(B);
        d.b{j,1} = B{j};
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
    hold off;
    d.pushed=4; %signals that ROIs were selected
    d.roisdefined=1; %signals that ROIs were defined

    %saving ROI mask
    filename=[d.pn '\' d.fn(1:end-4)];
    ROImask=d.mask;
    ROIorder=d.ROIorder;
    save(filename, 'ROImask','ROIorder');
end




% --- Executes on button press in pushbutton16.              CLEAR ALL ROIS
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
global v
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
%resets all varibles needed for selecting ROIs
d.bcount=0; %signals ROI button was not pressed
d.pushed=1; %signals video was loaded
d.ROIs=[];
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.bg=[];
d.b=[];
d.c=[];
d.ROIorder=[];
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=(1/(mean(mean(mean(d.imd))))+1/(max(max(max(d.imd)))))/2;
else
    imdMax=1/(max(max(max(d.imd))));
end

singleFrame=d.mip;
if d.dF==1;
    singleFrame=d.imd(:,:,round(handles.slider7.Value))*imdMax;
    axes(handles.axes1);imshow(singleFrame); colormap(handles.axes1, gray);
else
    axes(handles.axes1); imshow(singleFrame);
end
msgbox('ROIs cleared!','Success');





% --- Executes on button press in pushbutton27.          LOAD EXISTING ROIs
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global d
%resets all varibles needed for selecting ROIs
d.bcount=0; %signals ROI button was not pressed
d.pushed=1; %signals video was loaded
d.ROIs=[];
d.mask=zeros(size(d.imd,1),size(d.imd,2));
d.labeled = zeros(size(d.imd,1),size(d.imd,2));
d.bg=[];
d.b=[];
d.c=[];
d.ROIorder=[];
d.roisdefined=0; %signals no ROIs were selected
d.load=0; %signals that no ROI mask was loaded

if d.pre==0;
    msgbox('Please do preprocessing & Delta F/F calculation before proceeding!','ATTENTION');
    return;
elseif d.dF==0;
    msgbox('Please do Delta F/F calculation before proceeding!','ATTENTION');
    return;
end

filepath=[d.pn '\'];
[pn]=uigetdir(filepath);
%extracts filename
load([pn '\' d.fn(1:end-4) '.mat']);
d.mask=ROImask;
d.ROIorder=ROIorder;
%plotting ROIs
colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};

singleFrame=d.imd(:,:,round(handles.slider7.Value));
if d.dF==1 || d.pre==1;
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray); hold on;
else
    axes(handles.axes1); imshow(singleFrame); hold on;
end
B=bwboundaries(d.mask); %boundaries of ROIs
d.labeled=bwlabel(d.mask);
stat = regionprops(d.labeled,'Centroid');
d.b=cell(length(B),1);
d.c=cell(length(B),1);
colors=repmat(colors,1,ceil(length(B)/8));
for j = 1 : length(B);
    d.b{j,1} = B{j};
    d.c{j,1} = stat(j).Centroid;
    plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
    text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
end
hold off;
d.pushed=4; %signals that ROIs were selected
d.roisdefined=1; %signals that ROIs were defined

% label ROIs
background=d.mask;
background(background==1)=2;
background(background==0)=1;
background(background==2)=0;
CC=bwconncomp(d.mask);
numROIs=CC.NumObjects; %number of ROIs
d.imdThresh=cell(size(d.imd,3),numROIs);
d.ROIs=cell(size(d.imd,3),numROIs);
d.background=cell(size(d.imd,3),1);
d.bg=cell(size(d.imd,3),1);
h=waitbar(0,'Labeling ROIs');
for j=1:size(d.imd,3);
    for i=1:numROIs;
        ROIs=zeros(size(d.imd,1),size(d.imd,2));
        m = find(d.labeled==i);
        ROIs(m)=1;
        % You can only multiply integers if they are of the same type.
        ROIs = cast(ROIs, class(d.imd(:,:,1)));
        d.imdThresh{j,i} = ROIs .* d.imd(:,:,j);
        d.ROIs{j,d.ROIorder(i)}=d.imdThresh{j,i}(m);
    end
    % You can only multiply integers if they are of the same type.
    nn = find(background==1);
    background = cast(background, class(d.imd(:,:,1)));
    d.background{j,1} = background .* d.imd(:,:,j);
    d.bg{j,1}=d.background{j,1}(nn);
    waitbar(j/size(d.imd,3),h);
end
%relabeling d.labeled
labels=zeros(size(d.imd,1),size(d.imd,2));
for i=1:numROIs;
    m = find(d.labeled==i);
    labels(m)=d.ROIorder(i);
end
d.labeled=labels;
d.load=1; %signals that a ROI mask was loaded
close(h);
msgbox('Loading complete!');





% --- Executes on slider movement.                          THRESHOLD LEVEL
function slider21_Callback(hObject, eventdata, handles)
% hObject    handle to slider21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
MIP=d.mip/max(max(d.mip));
MIP(MIP<handles.slider21.Value)=0;
figure(2),imshow(MIP);


% th_MIP=im2bw(MIP, handles.slider21.Value);
% smallestAcceptableArea = 25;
% structuringElement = strel('disk', 2);
% th_clean_MIP = imclose(bwareaopen(th_MIP,smallestAcceptableArea),structuringElement);
% D = bwdist(~th_clean_MIP);
% figure(2);
% imshow(D,[],'InitialMagnification','fit');
% title('Distance transform of ~bw');
% D = -D;
% D(~th_clean_MIP) = -Inf;
% L = watershed(D);
% rgb = label2rgb(L,'jet',[.5 .5 .5]);
% figure(3);
% imshow(rgb,'InitialMagnification','fit');
% title('Watershed transform of D');

% --- Executes during object creation, after setting all properties.
function slider21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton34.                   AUTO ROIs
function pushbutton34_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on button press in pushbutton14.             PLOT ROI VALUES
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
%check whether ROIs were selected
if d.roisdefined==0;
    msgbox('Please label ROIs first!','ERROR');
    return;
end
%check whether dF/F was calculated
if d.dF==0;
    msgbox('Please calculate Delta F/F first!','ERROR');
    return;
end


colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};

    
    %dF/f and thresholded ROIs
if d.load==1;
    colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
    % calculate mean grey value of ROIs in percent
    d.ROImeans=zeros(size(d.ROIs,1),size(d.ROIs,2));
    d.bgmeans=zeros(size(d.ROIs,1),1);
    for k=1:size(d.ROIs,2);
        for i=1:size(d.ROIs,1);
            d.ROImeans(i,k)=mean(d.ROIs{i,k});
            d.bgmean(i,1)=mean(d.bg{i,1});
            d.ROImeans(i,k)=(d.ROImeans(i,k)-d.bgmean(i,1))*100;
        end
    end
    % plotting ROI values
    NoofSpikes=zeros(size(d.ROIs,2),1);
    spikes=cell(1,size(d.ROIs,2));
    ts=cell(1,size(d.ROIs,2));
    amp=cell(1,size(d.ROIs,2));
    %initializing that only 8 subplots will be in one figure
    onesub=(1:8);
    anysub=repmat(onesub,1,ceil(size(d.ROIs,2)/8));
    check=(9:8:100);
    check2=(8:8:100);

    figure('color','w');
    for j=1:size(d.ROIs,2);
        if ismember(j,check)==1;
            figure('color','w');
        end
        subplot(8,1,anysub(j));
        plot(d.ROImeans(:,j),'Color',colors{1,j});
        strings=sprintf('ROI No.%d',j);
        %title('ROI values in percent');
        if ismember(j,check2)==1 || j==size(d.ROIs,2);
            xlabel('Time in seconds');
        end
        ylabel('%');
        legend(strings,'Location','eastoutside');
        tlabel=get(gca,'XTickLabel');
        for k=1:length(tlabel);
            tlabel{k,1}=str2num(tlabel{k,1});
        end
        tlabel=cell2mat(tlabel);
        tlabel=tlabel./d.framerate;
        set(gca,'XTickLabel',tlabel);
        set(gca, 'box', 'off');
        hold on;
        [y,x]=findpeaks(d.ROImeans(:,j),'MinPeakHeight',5*median(abs(d.ROImeans(:,j))/0.6745)); %quiroga spike detection formula
        spikes{1,j}=x;
        ts{1,j}=x/d.framerate;
        amp{1,j}=y;
        if isempty(x)==0;
            plot(x,max(d.ROImeans(:,j))+0.5,'k.');
        else
            spikes{1,j}=1;
        end
        %calculating number of spikes
        NoofSpikes(j,1)=length(x);
    end
    hold off;
    %calculating firing frequency
    Frequency=round(NoofSpikes./(size(d.imd,3)/d.framerate),2);
    %calculating highest amplitude change
    Amplitude=round(reshape(max(d.ROImeans),size(d.ROImeans,2),1),2);
    
    %plotting raster plot
    b=zeros(size(d.ROImeans,1),1);
    fig=figure;
    subplot(2,1,1);
    for j=1:size(d.ROImeans,2);
        plot(spikes{1,j},j,'k.');
        hold on;
        b(spikes{1,j})=b(spikes{1,j})+1;
        title('Cell activity raster plot');
        xlabel('Time in seconds');
        ylabel('ROI number');
        xlim([0 round(size(d.imd,3))]);
        ylim([0 size(d.ROImeans,2)+1]);
    end
    tilabel=get(gca,'XTickLabel');
    for k=1:length(tilabel);
        tilabel{k,1}=str2num(tilabel{k,1});
    end
    tilabel=cell2mat(tilabel);
    tilabel=tilabel./d.framerate;
    set(gca,'XTickLabel',tilabel);
    hold off;
    subplot(2,1,2);
    plot(b);
    xlabel('Time in seconds');
    ylabel('Number of spikes');
    xlim([0 round(size(d.imd,3))]);
    ticlabel=get(gca,'XTickLabel');
    for k=1:length(ticlabel);
        ticlabel{k,1}=str2num(ticlabel{k,1});
    end
    ticlabel=cell2mat(ticlabel);
    ticlabel=ticlabel./d.framerate;
    set(gca,'XTickLabel',ticlabel);
    
    
    %dF/F and manual ROIs
elseif d.load==0;
    colors=repmat(colors,1,ceil(size(d.ROIs,2)/8));
    %background
    bg=cell(size(d.imd,3),1);
    d.bg=cell(size(d.imd,3),1);
    background=d.mask;
    background(background==1)=2;
    background(background==0)=1;
    background(background==2)=0;
    h=waitbar(0,'Labeling background');
    for k = 1:size(d.imd,3);
        % You can only multiply integers if they are of the same type.
        nn = find(background==1);
        background = cast(background, class(d.imd(:,:,1)));
        d.background{k,1} = background .* d.imd(:,:,k);
        d.bg{k,1}=d.background{k,1}(nn);
    end
    close(h);
    
    % calculate mean grey value of ROIs in percent
    d.ROImeans=zeros(size(d.ROIs,1),size(d.ROIs,2));
    d.bgmeans=zeros(size(d.ROIs,1),1);
    for k=1:size(d.ROIs,2);
        for i=1:size(d.ROIs,1);
            d.ROImeans(i,k)=mean(d.ROIs{i,k});
            d.bgmean(i,1)=mean(d.bg{i,1});
            d.ROImeans(i,k)=(d.ROImeans(i,k)-d.bgmean(i,1))*100;
        end
    end
    % plotting ROI values
    NoofSpikes=zeros(size(d.ROIs,2),1);
    spikes=cell(1,size(d.ROIs,2));
    ts=cell(1,size(d.ROIs,2));
    amp=cell(1,size(d.ROIs,2));
    %initializing that only 8 subplots will be in one figure
    onesub=(1:8);
    anysub=repmat(onesub,1,ceil(size(d.ROIs,2)/8));
    check=(9:8:100);
    check2=(8:8:100);

    figure('color','w');
    for j=1:size(d.ROIs,2);
        if ismember(j,check)==1;
            figure('color','w');
        end
        subplot(8,1,anysub(j));
        plot(d.ROImeans(:,j),'Color',colors{1,j});
        strings=sprintf('ROI No.%d',j);
        %title('ROI values in percent');
        if ismember(j,check2)==1 || j==size(d.ROIs,2);
            xlabel('Time in seconds');
        end
        ylabel('%');
        legend(strings,'Location','eastoutside');
        tlabel=get(gca,'XTickLabel');
        for k=1:length(tlabel);
            tlabel{k,1}=str2num(tlabel{k,1});
        end
        tlabel=cell2mat(tlabel);
        tlabel=tlabel./d.framerate;
        set(gca,'XTickLabel',tlabel);
        set(gca, 'box', 'off');
        hold on;
        [y,x]=findpeaks(d.ROImeans(:,j),'MinPeakHeight',5*median(abs(d.ROImeans(:,j))/0.6745)); %quiroga spike detection formula
        spikes{1,j}=x;
        ts{1,j}=x/d.framerate;
        amp{1,j}=y;
        if isempty(x)==0;
            plot(x,max(d.ROImeans(:,j))+0.5,'k.');
        else
            spikes{1,j}=1;
        end
        %calculating number of spikes
        NoofSpikes(j,1)=length(x);
    end
    hold off;
    %calculating firing frequency
    Frequency=round(NoofSpikes./(size(d.imd,3)/d.framerate),2);
    %calculating highest amplitude change
    Amplitude=round(reshape(max(d.ROImeans),size(d.ROImeans,2),1),2);
    
    %plotting raster plot
    b=zeros(size(d.ROImeans,1),1);
    fig=figure;
    subplot(2,1,1);
    for j=1:size(d.ROImeans,2);
        plot(spikes{1,j},j,'k.');
        hold on;
        b(spikes{1,j})=b(spikes{1,j})+1;
        title('Cell activity raster plot');
        xlabel('Time in seconds');
        ylabel('ROI number');
        xlim([0 round(size(d.imd,3))]);
        ylim([0 size(d.ROImeans,2)+1]);
    end
    tilabel=get(gca,'XTickLabel');
    for k=1:length(tilabel);
        tilabel{k,1}=str2num(tilabel{k,1});
    end
    tilabel=cell2mat(tilabel);
    tilabel=tilabel./d.framerate;
    set(gca,'XTickLabel',tilabel);
    hold off;
    subplot(2,1,2);
    plot(b);
    xlabel('Time in seconds');
    ylabel('Number of spikes');
    xlim([0 round(size(d.imd,3))]);
    ticlabel=get(gca,'XTickLabel');
    for k=1:length(ticlabel);
        ticlabel{k,1}=str2num(ticlabel{k,1});
    end
    ticlabel=cell2mat(ticlabel);
    ticlabel=ticlabel./d.framerate;
    set(gca,'XTickLabel',ticlabel);
end
%saving traces
% Construct a questdlg with two options
choice = questdlg('Would you like to save these traces?', ...
    'Attention', ...
    'YES','NO','YES');
% Handle response
switch choice
    case 'YES'
        files=dir(d.pn);
        tf=zeros(1,length(dir(d.pn)));
        for k=1:length(dir(d.pn));
            tf(k)=strcmp('traces',files(k).name);
        end
        if sum(tf)==0;
            mkdir([d.pn '\traces']);
            tnum=ceil(size(d.ROImeans,2)/8);
            hfnum=get(fig,'Number');
            numseries=(hfnum-tnum:1:hfnum-1);
            for j=1:tnum;
                name=sprintf('traces_%d',j);
                figurenum=sprintf('-f%d',numseries(j));
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r100',path); %-depsc for vector graphic
            end
            name=('rasterplot');
            figurenum=sprintf('-f%d',hfnum);
            path=[d.pn '/traces/',name,'.png'];
            path=regexprep(path,'\','/');
            print(figurenum,'-dpng','-r100',path); %-depsc for vector graphic
            
            %saving table
            filename=[d.pn '\traces\ROIs_' d.fn(1:end-4) '.xls'];
            ROInumber=cell(size(d.ROImeans,2),1);
            for k=1:size(d.ROImeans,2);
                ROInumber{k,1}=sprintf('ROI No.%d',k);
            end
            T=table(NoofSpikes,Frequency,Amplitude,...
                'RowNames',ROInumber);
            writetable(T,filename,'WriteRowNames',true);
            
            %saving data
            field1='framerate';
            field2='wave';
            field3='spikes';
            field4='amp';
            field5='ts';
            value1=d.framerate;
            value2=d.ROImeans;
            value4=amp;
            value5=ts;
            value3=struct(field4,value4,field5,value5);
            traces=struct(field1,value1,field2,value2,field3,value3);
            filename=[d.pn '\traces\traces_' d.fn(1:end-4)];
            save(filename, 'traces');
    
            msgbox('Done!','Attention');
        else
            rmdir([d.pn '\traces'],'s');
            mkdir([d.pn '\traces']);
            tnum=ceil(size(d.ROImeans,2)/8);
            hfnum=get(fig,'Number');
            numseries=(hfnum-tnum:1:hfnum-1);
            for j=1:tnum;
                name=sprintf('traces_%d',j);
                figurenum=sprintf('-f%d',numseries(j));
                path=[d.pn '/traces/',name,'.png'];
                path=regexprep(path,'\','/');
                print(figurenum,'-dpng','-r100',path); %-depsc for vector graphic
            end
            name=('rasterplot');
            figurenum=sprintf('-f%d',hfnum);
            path=[d.pn '/traces/',name,'.png'];
            path=regexprep(path,'\','/');
            print(figurenum,'-dpng','-r100',path); %-depsc for vector graphic
            
            %saving table
            filename=[d.pn '\traces\ROIs_' d.fn(1:end-4) '.xls'];
            ROInumber=cell(size(d.ROImeans,2),1);
            for k=1:size(d.ROImeans,2);
                ROInumber{k,1}=sprintf('ROI No.%d',k);
            end
            T=table(NoofSpikes,Frequency,Amplitude,...
                'RowNames',ROInumber);
            writetable(T,filename,'WriteRowNames',true);
    
            %saving data
            field1='framerate';
            field2='wave';
            field3='spikes';
            field4='amp';
            field5='ts';
            value1=d.framerate;
            value2=d.ROImeans;
            value4=amp;
            value5=ts;
            value3=struct(field4,value4,field5,value5);
            traces=struct(field1,value1,field2,value2,field3,value3);
            filename=[d.pn '\traces\traces_' d.fn(1:end-4)];
            save(filename, 'traces');
            
            msgbox('Done!','Attention');
        end
    case 'NO'
        return;
end






% --- Executes on button press in pushbutton26.               SAVE CI VIDEO
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=1/(mean(mean(mean(d.imd))));
else
    imdMax=1/(max(max(max(d.imd))));
end

if isempty(d.origCI)==1;
    d.origCI=d.imd;
end

h=waitbar(0,'Saving calcium imaging video');

if d.dF==0; %saving video if it was not processed further
    %converting original CI video to double precision and to values between 1 and 0
        origCIconv=double(d.origCI);
        origCIconv=origCIconv./max(max(max(origCIconv)));
        
        filename=[d.pn '\' d.fn(1:end-4)];
        v = VideoWriter(filename,'Grayscale AVI');
        v.FrameRate=d.framerate;
        open(v);
        for k=1:size(d.imd,3);
            singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
%             figure(100),imshow(singleFrame);
            writeVideo(v,singleFrame);
            waitbar(k/size(d.imd,3),h);
        end
        close(v);
        close(h);
%         close(gcf);
        msgbox('Saving video completed.');
else
    % Construct a questdlg with two options
    choice = questdlg('Would you like to save only the dF/F video or the combined one?', ...
        'Attention', ...
        'Original','dF/F','Combined','Original');
    % Handle response
    switch choice
        case 'Original'
            %converting original CI video to double precision and to values between 1 and 0
            origCIconv=double(d.origCI);
            origCIconv=origCIconv./max(max(max(origCIconv)));

            filename=[d.pn '\' d.fn(1:end-4)];
            v = VideoWriter(filename,'Grayscale AVI');
            v.FrameRate=d.framerate;
            open(v);
            for k=1:size(d.imd,3);
                singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    %             figure(100),imshow(singleFrame);
                writeVideo(v,singleFrame);
                waitbar(k/size(d.imd,3),h);
            end
            close(v);
            close(h);
    %         close(gcf);
            msgbox('Saving video completed.');
        case 'dF/F'
            filename=[d.pn '\' d.fn(1:end-4) 'dF'];
            v = VideoWriter(filename,'Grayscale AVI');
            v.FrameRate=d.framerate;
            open(v);
            for k = 1:size(d.imd,3);
                frame = d.imd(:,:,k)*imdMax; %scaling images so that values are between 0 and 1 and the maximum value of d.imd is almost 1 d.imd(:,:,k)*(floor((1/max(max(max(d.imd))))));
                frame(frame<0)=0;

                writeVideo(v,frame);
                waitbar(k/size(d.imd,3),h);
            end
            close(v);
            close(h);
            msgbox('Saving video completed.');
        case 'Combined'
            %converting original CI video to double precision and to values between 1 and 0
            origCIconv=double(d.origCI);
            origCIconv=origCIconv./max(max(max(origCIconv)));
            %converting dF/F video such that all pixels below 50% of absolute maximum
            %intensity are zero
            imdconv=zeros(size(d.imd,1),size(d.imd,2),size(d.imd,3));
            smallestAcceptableArea = 30;
            structuringElement = strel('disk', 2);
            hh=waitbar(0,'Converting dF/F calcium imaging video');
            for k=1:size(d.imd,3);
                frame=d.imd(:,:,k);
    %             frame(frame<(mean(mean(mean(d.imd)))*2))=0;
    %             mask = imclearborder(imclose(bwareaopen(frame,smallestAcceptableArea),structuringElement));
                frame=frame.*d.mask;
                frame(frame<(max(max(max(d.imd)))*0.25))=0;
                imdconv(:,:,k)=frame;
                waitbar(k/size(d.imd,3),hh);
            end
            close(hh);
            %converting video such that values are between 1 and 0
            if d.align==1 && handles.radiobutton2.Value==1;
                imdMax=1/(mean(mean(mean(imdconv))));
            else
                imdMax=1/(max(max(max(imdconv))));
            end
            imdconv=imdconv.*imdMax;

            filename=[d.pn '\' d.fn(1:end-4) 'combo'];
            v = VideoWriter(filename,'Uncompressed AVI');
            v.FrameRate=d.framerate;
            open(v);
            for k=1:size(d.imd,3);
                singleFrame=imadjust(origCIconv(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
                figure(100),imshow(singleFrame);
                red = cat(3, ones(size(origCIconv(:,:,1))), zeros(size(origCIconv(:,:,1))), zeros(size(origCIconv(:,:,1))));
                hold on 
                hh = imshow(red); 
                hold off
                set(hh, 'AlphaData', imdconv(:,:,k));
                f=getframe(gcf);
                newframe=f.cdata;
                writeVideo(v,singleFrame);
                waitbar(k/size(d.imd,3),h);
            end
            close(v);
            close(h);
            close(gcf);
            msgbox('Saving video completed.');
    end
end




%---------------------------Browsing through video/s

% --- Executes on slider movement.                            CHANGES FRAME
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global d
global v
if d.pushed==0 && v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if v.pushed==0;
    v.imd=[];
elseif v.pushed==1;
    v.hsvP=[];
    v.hsvG=[];
elseif v.pushed>=1;
end
if d.pushed==0;
    d.imd=[];
    maxframes=size(v.imd,2);
    handles.slider7.Max=maxframes;
else
    maxframes=size(d.imd,3);
    handles.slider7.Max=maxframes;
end

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=(1/(mean(mean(mean(d.imd))))+1/(max(max(max(d.imd)))))/2;
else
    imdMax=1/(max(max(max(d.imd))));
end

colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};
colors=repmat(colors,1,(ceil(size(d.b,1)/8)));
if d.pushed==4;
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
end

if d.pre==1 && d.pushed==1;
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==1;
    singleFrame=imadjust(d.imd(:,:,round(handles.slider7.Value)), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    axes(handles.axes1);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif d.pushed==4;
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    axes(handles.axes1);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for k=1:size(d.b,1);
        d.c{k,1} = stat(d.ROIorder(k)).Centroid;
        plot(d.b{k,1}(:,2),d.b{k,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(k)});
        text(d.c{k,1}(1),d.c{k,1}(2),num2str(d.ROIorder(k)));
    end
    hold off;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
end
if v.pushed==1 && d.pushed>=1;
    axes(handles.axes2); image(v.imd(round(handles.slider7.Value)).cdata); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==1;
    axes(handles.axes2); image(v.imd(round(handles.slider7.Value)).cdata); %original video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==2;
    axes(handles.axes2); imshow(v.hsvG(round(handles.slider7.Value)).cdata); %green masked video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
elseif v.pushed==3;
    axes(handles.axes2); imshow(v.hsvP(round(handles.slider7.Value)).cdata); %yellow masked video
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
end


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton18.                  PLAY VIDEO
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
d.stop=0;
%checks if a video file was selected
if v.pushed==0 && d.pushed==0;
    msgbox('Please select folder first!','ERROR');
    return;
elseif v.pushed==0;
    v.imd=[];
    nframes=[];
elseif v.pushed==1;
    v.hsvP=[];
    v.hsvG=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1;
    nframes=size(v.imd,2);
end
if d.pushed==0;
    d.imd=[];
    maxframes=size(v.imd,2);
else
    maxframes=size(d.imd,3);
end

if d.align==1 && handles.radiobutton2.Value==1;
    imdMax=(1/(mean(mean(mean(d.imd))))+1/(max(max(max(d.imd)))))/2;
else
    imdMax=1/(max(max(max(d.imd))));
end

colors={[0    0.4471    0.7412],...
    [0.8510    0.3255    0.0980],...
    [0.9294    0.6941    0.1255],...
    [0.4941    0.1843    0.5569],...
    [0.4667    0.6745    0.1882],...
    [0.3020    0.7451    0.9333],...
    [0.6353    0.0784    0.1843],...
    [0.6784    0.9216    1.0000]};
colors=repmat(colors,1,ceil(size(d.b,1)/8));
if d.pushed==4;
    d.ROIorder=unique(d.labeled(d.labeled>0),'stable');
end

%if both videos were loaded
if v.pushed==1 && d.pre==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    image(v.imd(k).cdata); %original video
    axes(handles.axes1); %thresholded video
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        axes(handles.axes1); imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif v.pushed==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    image(v.imd(k).cdata); %original video
    axes(handles.axes1); %original video
    singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif v.pushed==1 && d.pushed==4;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    image(v.imd(k).cdata); %original video
    axes(handles.axes1); %ROIs with video
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for j=1:size(d.b,1);
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
    hold off;
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif v.pushed==2 && d.pre==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    imshow(v.hsvG(k).cdata); %green masked video
    axes(handles.axes1); %thresholded video
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        axes(handles.axes1); imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif  v.pushed==2 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    imshow(v.hsvG(k).cdata); %green masked video
    axes(handles.axes1); %original video
    singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif v.pushed==2 && d.pushed==4;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    imshow(v.hsvG(k).cdata); %green masked video
    axes(handles.axes1); %ROIs with video
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for j=1:size(d.b,1);
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
    hold off;
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif v.pushed==3 && d.pre==1 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    imshow(v.hsvP(k).cdata); %pink masked video
    axes(handles.axes1); %thresholded video
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        axes(handles.axes1); imshow(singleFrame);
    end
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif v.pushed==3 && d.pushed==1;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    imshow(v.hsvP(k).cdata); %pink masked video
    axes(handles.axes1); %original video
    singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif v.pushed==3 && d.pushed==4;
    d.play=1;
    v.play=1;
    for k=round(handles.slider7.Value):size(d.imd,3);
    axes(handles.axes2);
    imshow(v.hsvP(k).cdata); %pink masked video
    axes(handles.axes1); %ROIs with video
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for j=1:size(d.b,1);
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
    hold off;
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
end


%if only calcium video was loaded
if d.pre==1;
    d.play=1;
    axes(handles.axes1);
    for k=round(handles.slider7.Value):size(d.imd,3);
    singleFrame=d.imd(:,:,round(handles.slider7.Value));
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        axes(handles.axes1); imshow(singleFrame);
    end
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif d.pushed==1;
    d.play=1;
    axes(handles.axes1); %original video
    for k=round(handles.slider7.Value):size(d.imd,3);
    singleFrame=imadjust(d.imd(:,:,k), [handles.slider5.Value handles.slider15.Value],[handles.slider6.Value handles.slider16.Value]);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);
    else
        imshow(singleFrame);
    end
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
elseif d.pushed==4;
    d.play=1;
    axes(handles.axes1); %video with ROIs
    for k=round(handles.slider7.Value):size(d.imd,3);
    singleFrame=d.imd(:,:,k);
    if d.dF==1 || d.pre==1;
        imagesc(singleFrame,[min(min(singleFrame)),max(max(singleFrame))]); colormap(handles.axes1, gray);hold on;
    else
        imshow(singleFrame);hold on;
    end
    stat = regionprops(d.labeled,'Centroid');
    for j=1:size(d.b,1);
        d.c{j,1} = stat(d.ROIorder(j)).Centroid;
        plot(d.b{j,1}(:,2),d.b{j,1}(:,1),'linewidth',2,'Color',colors{1,d.ROIorder(j)});
        text(d.c{j,1}(1),d.c{j,1}(2),num2str(d.ROIorder(j)));
    end
    hold off;
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.1);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
end


%if only behavioral video was loaded
if  v.pushed==1;
    v.play=1;
    axes(handles.axes2);
    for k=round(handles.slider7.Value):size(v.imd,2);
    image(v.imd(k).cdata); %original video
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.05);
    if k==size(d.imd,3);
        d.stop=1;
    end
    if d.stop==1;
        return;
    end
    end
end


% --- Executes on button press in pushbutton21.                        STOP
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if d.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
d.stop=1;
d.play=0;
v.play=0;







%% ---------------------------Processing behavioral video


% --- Executes on button press in pushbutton7.       LOADS BEHAVIORAL VIDEO
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
%clears cache
%clears all global variables
clear global v;
%reinitializes global variables
global v
v.pushed=0;
v.play=0;
v.pn=[];
%clears axes
cla(handles.axes2,'reset');
%resets frame slider
handles.slider7.Value=1;

if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end

v.pn=[];
v.fn=[];
v.crop=0; %signals video is not cropped
v.hsv=0; %signals video is not converted to hsv color space
v.gspot=0; %signals green spot is not saved
v.psopt=0; %signals pink spot is not saved
if d.pushed>=1;
    [v.pn]=uigetdir(d.pn);
else
    [v.pn]=uigetdir('F:\jenni\Documents\PhD PROJECT\Calcium Imaging\doric camera\');
end

%checks whether calcium imaging video was loaded
if d.pushed==0;
    msgbox('Please select calcium imaging video first!','ATTENTION');
    return;
end

filePattern = fullfile(v.pn, '*.mp4');
Files = dir(filePattern);
v.fn = Files(1).name;
v.vid = VideoReader([v.pn '\' v.fn]);

%defining dimensions of video
nframes=get(v.vid,'NumberOfFrames');
vidObj = VideoReader([v.pn '\' v.fn]);
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
v.framerate=vidObj.FrameRate;
v.imd = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'));

%putting each frame into variable 'v.imd'
h=waitbar(0,'Loading');
c=1;
if v.framerate>d.framerate;
    for k=1:ceil(v.framerate/d.framerate):nframes
        v.imd(c).cdata = read(vidObj,k);
        c=c+1;
        waitbar(k/nframes,h);
    end
else
    for k=1:nframes
        v.imd(c).cdata = read(vidObj,k);
        c=c+1;
        waitbar(k/nframes,h);
    end
end
sframe=size(v.imd,2)-size(d.imd,3);
v.imd=v.imd(1:size(d.imd,3));
v.pushed=1; %signals video is loaded
close(h);

%looking at first original picture
axes(handles.axes2); image(v.imd(1).cdata);
titleLabel = ['Behavioral video: ' v.fn];
set(handles.text28, 'String', titleLabel);
handles.text28.TooltipString=v.pn;
msgbox(sprintf('Loading Completed. Frames cut off: %d',sframe),'Success');




% --- Executes on button press in pushbutton15. CROP & CONVERT IMAGE TO HSV
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('Please push stop button before proceeding!','ATTENTION');
    return;
end
axes(handles.axes2); image(v.imd(1).cdata); %displays first image
uiwait(msgbox('Please define the area where the mouse is running by left-click and dragging the cursor over the area! Then right click and select Copy Position, finish by double-clicking!','Attention','modal'));
%initializes interactive cropping
h=imcrop;
cropped=clipboard('pastespecial');
cropCoordinates=str2num(cell2mat(cropped.A_pastespecial));
%checks if cropping coordinates are valid
if isempty(cropCoordinates)==1 || cropCoordinates(1,3)==0 || cropCoordinates(1,4)==0;
    msgbox('Please select valid cropping area! Check the instructions again.','ERROR');
    return;
end
cc=floor(cropCoordinates);
%cropping frames
h=waitbar(0,'Cropping frames');
for k=1:size(v.imd,2);
    v.imd(k).cdata=v.imd(k).cdata(cc(2):cc(2)+cc(4),cc(1):cc(1)+cc(3),:);
    waitbar(k/size(v.imd,2),h);
end
v.crop=1; %signals that video was cropped
close(h);
%downsampling
imd = struct('cdata',zeros(size(v.imd(1),1),size(v.imd(1),2),3,'uint8'));
h=waitbar(0,'Downsampling');
for k=1:size(v.imd,2);
    imd(k).cdata=imresize(v.imd(k).cdata,0.6);
    waitbar(k/size(v.imd,2),h);
end
v.imd=imd;
close(h);
axes(handles.axes2); image(v.imd(1).cdata);

% %checks the size of the video and performs temporal downsampling if the video is too big
% if size(v.imd,2)>7000;
%     v.imd=v.imd(:,1:5:size(v.imd,2)); %taking only every fifth frame
% end

frame = struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
hsvImage = struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
hImage=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
sImage=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
vImage=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
imd=v.imd;
%converting video from RGB colors space to HSV
h=waitbar(0,'Converting');
for k=1:size(imd,2);
    frame(k).cdata=imd(k).cdata;
    % Convert RGB image to HSV
    hsvImage(k).cdata= rgb2hsv(frame(k).cdata);
    % Extract out the H, S, and V images individually
    hImage(k,:,:) = hsvImage(k).cdata(:,:,1);
    sImage(k,:,:) = hsvImage(k).cdata(:,:,2);
    vImage(k,:,:) = hsvImage(k).cdata(:,:,3);
    waitbar(k/size(imd,2),h);
end
v.hImage=hImage;
v.sImage=sImage;
v.vImage=vImage;
v.hsv=1; %signals that video was converted
close(h);
msgbox('Cropping and Conversion Completed. Please use the green and pink presets to view only the respective spot. If needed adjust thresholds manually! If satisfied save the green spot by clicking SAVE GREEN SPOT and the pink spot by clicking SAVE PINK SPOT.','Success');






% --- Executes on slider movement.                      VALUE THRESHOLD LOW
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

v.valueThresholdLow=handles.slider9.Value; %slider9 value for value threshold low
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Now apply each color band's particular thresholds to the color band
hueMask = (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.hueThresholdLow) & (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.hueThresholdHigh);
saturationMask = (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.saturationThresholdLow) & (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.saturationThresholdHigh);
valueMask = (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.valueThresholdLow) & (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
axes(handles.axes2); imshow(maskedRGBImage);

% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                     VALUE THRESHOLD HIGH
function slider10_Callback(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

v.valueThresholdHigh=handles.slider10.Value; %slider10 value for value threshold high
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow = handles.slider9.Value;

% Now apply each color band's particular thresholds to the color band
hueMask = (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.hueThresholdLow) & (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.hueThresholdHigh);
saturationMask = (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.saturationThresholdLow) & (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.saturationThresholdHigh);
valueMask = (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.valueThresholdLow) & (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
axes(handles.axes2); imshow(maskedRGBImage);

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                SATURATION THRESHOLD HIGH
function slider11_Callback(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.saturationThresholdHigh = handles.slider11.Value; %slider11 value for saturation threshold high
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Now apply each color band's particular thresholds to the color band
hueMask = (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.hueThresholdLow) & (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.hueThresholdHigh);
saturationMask = (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.saturationThresholdLow) & (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.saturationThresholdHigh);
valueMask = (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.valueThresholdLow) & (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
axes(handles.axes2); imshow(maskedRGBImage);

% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                 SATURATION THRESHOLD LOW
function slider12_Callback(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.saturationThresholdLow = handles.slider12.Value; %slider12 value for saturation threshold low
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Now apply each color band's particular thresholds to the color band
hueMask = (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.hueThresholdLow) & (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.hueThresholdHigh);
saturationMask = (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.saturationThresholdLow) & (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.saturationThresholdHigh);
valueMask = (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.valueThresholdLow) & (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
axes(handles.axes2); imshow(maskedRGBImage);

% --- Executes during object creation, after setting all properties.
function slider12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                        HUE THRESHOLD LOW
function slider13_Callback(hObject, eventdata, handles)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.hueThresholdLow = handles.slider13.Value; %slider13 value for hue threshold low
%other slider values
v.hueThresholdHigh = handles.slider14.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Now apply each color band's particular thresholds to the color band
hueMask = (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.hueThresholdLow) & (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.hueThresholdHigh);
saturationMask = (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.saturationThresholdLow) & (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.saturationThresholdHigh);
valueMask = (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.valueThresholdLow) & (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
axes(handles.axes2); imshow(maskedRGBImage);

% --- Executes during object creation, after setting all properties.
function slider13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.                       HUE THRESHOLD HIGH
function slider14_Callback(hObject, eventdata, handles)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
maxframes=size(d.imd,3);
nframes=size(v.imd,2);
v.hueThresholdHigh = handles.slider14.Value; %slider14 value for hue threshold high
%other slider values
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

% Now apply each color band's particular thresholds to the color band
hueMask = (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.hueThresholdLow) & (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.hueThresholdHigh);
saturationMask = (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.saturationThresholdLow) & (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.saturationThresholdHigh);
valueMask = (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.valueThresholdLow) & (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
axes(handles.axes2); imshow(maskedRGBImage);

% --- Executes during object creation, after setting all properties.
function slider14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton19.               GREEN PRESETS
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
global p
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
% Green preset values
hueThresholdLow = 0.25;
hueThresholdHigh = 0.55;
saturationThresholdLow = 0.16;
saturationThresholdHigh = 1;
valueThresholdLow = 0;
valueThresholdHigh = 0.8;
handles.slider14.Value = hueThresholdHigh;
handles.slider13.Value = hueThresholdLow;
handles.slider12.Value = saturationThresholdLow;
handles.slider11.Value = saturationThresholdHigh;
handles.slider9.Value = valueThresholdLow;
handles.slider10.Value = valueThresholdHigh;

v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

maxframes=size(d.imd,3);
nframes=size(v.imd,2);

% Now apply each color band's particular thresholds to the color band
hueMask = (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.hueThresholdLow) & (v.hImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.hueThresholdHigh);
saturationMask = (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.saturationThresholdLow) & (v.sImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.saturationThresholdHigh);
valueMask = (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) >= v.valueThresholdLow) & (v.vImage(round(round(handles.slider7.Value)*round((nframes/maxframes),2)),:,:) <= v.valueThresholdHigh);

% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the green parts of the image.
coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

% Filter out small objects.
smallestAcceptableArea = 50;
% Get rid of small objects.  Note: bwareaopen returns a logical.
coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely green also.
coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');

% You can only multiply integers if they are of the same type.
% (coloredObjectsMask is a logical array.)
% We need to convert the type of coloredObjectsMask to the same data type as hImage.
% coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
coloredObjectsMask = squeeze(cast(coloredObjectsMask, class(v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1))));

% Use the colored object mask to mask out the colored-only portions of the rgb image.
maskedImageR = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,1);
maskedImageG = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,2);
maskedImageB = coloredObjectsMask .* v.imd(round(round(handles.slider7.Value)*round((nframes/maxframes),2))).cdata(:,:,3);
% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

%showing thresholded image in GUI
if numel(find(maskedRGBImage))==0; %check if color spot is in image, if not mouse out of bounds or spot not detected!
    axes(handles.axes2); imshow(maskedRGBImage); hold on;
    str=sprintf('Mouse out of bounds, please select a frame where the mouse is visible! Otherwise adjust thresholds manually!');
    text(20,20,str,'Color','r');
else
    axes(handles.axes2); imshow(maskedRGBImage);
end
hold off;

% --- Executes on selection change in popupmenu1.              SELECT COLOR
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global p
p.preset=contents{get(handles.popupmenu1,'Value')};

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton10.             SAVE GREEN SPOT
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end

v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

hueMask=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
saturationMask=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
valueMask=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
coloredObjectsMask=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
maskedImageR=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
maskedImageG=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
maskedImageB=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
v.hsvG = struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));

%getting green spot from all frames
h=waitbar(0,'Extracting green spot for all frames');
for k=1:size(v.imd,2);
    % Now apply each color band's particular thresholds to the color band
    hueMask = (v.hImage(k,:,:) >= v.hueThresholdLow) & (v.hImage(k,:,:) <= v.hueThresholdHigh);
    saturationMask = (v.sImage(k,:,:) >= v.saturationThresholdLow) & (v.sImage(k,:,:) <= v.saturationThresholdHigh);
    valueMask = (v.vImage(k,:,:) >= v.valueThresholdLow) & (v.vImage(k,:,:) <= v.valueThresholdHigh);

    % Combine the masks to find where all 3 are "true."
    % Then we will have the mask of only the green parts of the image.
    coloredObjectsMask(k).cdata = uint8(hueMask & saturationMask & valueMask);

    % Filter out small objects.
    smallestAcceptableArea = 50;
    % Get rid of small objects.  Note: bwareaopen returns a logical.
    coloredObjectsMask(k).cdata = uint8(bwareaopen(coloredObjectsMask(k).cdata, smallestAcceptableArea));
    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
    coloredObjectsMask(k).cdata = imclose(coloredObjectsMask(k).cdata, structuringElement);
    % Fill in any holes in the regions, since they are most likely green also.
    coloredObjectsMask(k).cdata = imfill(logical(coloredObjectsMask(k).cdata), 'holes');

    % You can only multiply integers if they are of the same type.
    % (coloredObjectsMask is a logical array.)
    % We need to convert the type of coloredObjectsMask to the same data type as hImage.
    % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
    coloredObjectsMask(k).cdata = squeeze(cast(coloredObjectsMask(k).cdata, class(v.imd(1).cdata(:,:,1))));

    % Use the colored object mask to mask out the colored-only portions of the rgb image.
    maskedImageR(k).cdata = coloredObjectsMask(k).cdata .* v.imd(1,k).cdata(:,:,1);
    maskedImageG(k).cdata = coloredObjectsMask(k).cdata .* v.imd(1,k).cdata(:,:,2);
    maskedImageB(k).cdata = coloredObjectsMask(k).cdata .* v.imd(1,k).cdata(:,:,3);
    % Concatenate the masked color bands to form the rgb image.
    v.hsvG(k).cdata = cat(3, maskedImageR(k).cdata, maskedImageG(k).cdata, maskedImageB(k).cdata);
    waitbar(k/size(v.imd,2),h);
end
v.coloredObjectsMaskG =  coloredObjectsMask;
v.pushed=2; %signals green spot was saved
v.gspot=1; %signals green spot was saved
close(h);

nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
traceg=zeros(nframes,2);
%tracing center of the extracted green dot
h=waitbar(0,'Tracing green spot');
for k=1:nframes;
    stats=regionprops(v.coloredObjectsMaskG(k).cdata, {'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        x(k,:) = c(1);
        y(k,:) = c(2);
    else
        x(k,:) = 0;
        y(k,:) = 0;
    end
    traceg(:,1)=x; %coordinates of the mouse center
    traceg(:,2)=y;
    waitbar(k/nframes,h);
end
close(h);
%plotting green trace
tracegplot=traceg(traceg>0);
tracegplot=reshape(tracegplot,[size(tracegplot,1)/2,2]);
figure, image(v.imd(1).cdata); hold on;
plot(tracegplot(:,1),tracegplot(:,2),'g'); hold off;

msgbox('Saving Completed. Please save pink spot as well!','Success');



% --- Executes on button press in pushbutton11.              SAVE PINK SPOT
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global v
global d
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
            
v.hueThresholdHigh = handles.slider14.Value;
v.hueThresholdLow = handles.slider13.Value;
v.saturationThresholdLow = handles.slider12.Value;
v.saturationThresholdHigh = handles.slider11.Value;
v.valueThresholdLow=handles.slider9.Value;
v.valueThresholdHigh = handles.slider10.Value;

hueMask=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
saturationMask=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
valueMask=zeros(size(v.imd,2),size(v.imd(1).cdata,1),size(v.imd(1).cdata,2));
coloredObjectsMask=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
maskedImageR=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
maskedImageG=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
maskedImageB=struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));
v.hsvP = struct('cdata',zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),3,'uint8'));

%getting green spot from all frames
h=waitbar(0,'Extracting pink spot for all frames');
for k=1:size(v.imd,2);
    % Now apply each color band's particular thresholds to the color band
    hueMask = (v.hImage(k,:,:) >= v.hueThresholdLow) & (v.hImage(k,:,:) <= v.hueThresholdHigh);
    saturationMask = (v.sImage(k,:,:) >= v.saturationThresholdLow) & (v.sImage(k,:,:) <= v.saturationThresholdHigh);
    valueMask = (v.vImage(k,:,:) >= v.valueThresholdLow) & (v.vImage(k,:,:) <= v.valueThresholdHigh);

    % Combine the masks to find where all 3 are "true."
    % Then we will have the mask of only the green parts of the image.
    coloredObjectsMask(k).cdata = uint8(hueMask & saturationMask & valueMask);

    % Filter out small objects.
    smallestAcceptableArea = 50;
    % Get rid of small objects.  Note: bwareaopen returns a logical.
    coloredObjectsMask(k).cdata = uint8(bwareaopen(coloredObjectsMask(k).cdata, smallestAcceptableArea));
    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
    coloredObjectsMask(k).cdata = imclose(coloredObjectsMask(k).cdata, structuringElement);
    % Fill in any holes in the regions, since they are most likely green also.
    coloredObjectsMask(k).cdata = imfill(logical(coloredObjectsMask(k).cdata), 'holes');

    % You can only multiply integers if they are of the same type.
    % (coloredObjectsMask is a logical array.)
    % We need to convert the type of coloredObjectsMask to the same data type as hImage.
    % coloredObjectsMask = cast(coloredObjectsMask, 'like', v.imd(100)); 
    coloredObjectsMask(k).cdata = squeeze(cast(coloredObjectsMask(k).cdata, class(v.imd(1).cdata(:,:,1))));

    % Use the colored object mask to mask out the colored-only portions of the rgb image.
    maskedImageR(k).cdata = coloredObjectsMask(k).cdata .* v.imd(1,k).cdata(:,:,1);
    maskedImageG(k).cdata = coloredObjectsMask(k).cdata .* v.imd(1,k).cdata(:,:,2);
    maskedImageB(k).cdata = coloredObjectsMask(k).cdata .* v.imd(1,k).cdata(:,:,3);
    % Concatenate the masked color bands to form the rgb image.
    v.hsvP(k).cdata = cat(3, maskedImageR(k).cdata, maskedImageG(k).cdata, maskedImageB(k).cdata);
    waitbar(k/size(v.imd,2),h);
end
v.coloredObjectsMaskP = coloredObjectsMask;
v.pushed=3; %signals pink spot was saved
v.pspot=1; %signals pink spot was saved
close(h);

nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
tracep=zeros(nframes,2);
%tracing center of the extracted pink dot
h=waitbar(0,'Tracing pink spot');
for k=1:nframes;
    stats=regionprops(v.coloredObjectsMaskP(k).cdata, {'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        x(k,:) = c(1);
        y(k,:) = c(2);
    else
        x(k,:) = 0;
        y(k,:) = 0;
    end
    tracep(:,1)=x; %coordinates of the mouse center
    tracep(:,2)=y;
    waitbar(k/nframes,h);
end
close(h);
%plotting pink trace
tracepplot=tracep(tracep>0);
tracepplot=reshape(tracepplot,[size(tracepplot,1)/2,2]);
figure, image(v.imd(1).cdata); hold on;
plot(tracepplot(:,1),tracepplot(:,2),'r'); hold off;
hold off;

msgbox('Saving Completed. If both spots are saved,please proceed by tracing the animal!','Success');






% --- Executes on button press in pushbutton12.                TRACE ANIMAL
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
if v.pushed==0;
    msgbox('Please select folder first!','ATTENTION');
    return;
end
if d.play==1 || v.play==1;
    msgbox('PLEASE PUSH STOP BUTTON BEFORE PROCEEDING!','PLEASE PUSH STOP BUTTON');
    return;
end
%checks whether video was cropped and converted and whether the
%corresponding video was loaded
if v.crop==0;
    msgbox('Please crop & convert video first!','ERROR');
    return;
elseif d.pushed==0;
    msgbox('Please load calcium imaging video first!','ERROR');
    return;
end
%making sure that the ROIs were plotted
if isempty(d.perc)==1 && d.dF==0;
    msgbox('ROIs need to be plotted before you can see corresponding postition of the mouse with cell activity!','ATTENTION');
    return;
end
if d.thresh==1 && size(d.ROIs,2)~=size(d.perc,2) && d.dF==0;
    msgbox('All ROIs need to be plotted before you can see corresponding postition of the mouse with cell activity!','ATTENTION');
    return;
elseif d.thresh==0 && size(d.ROIs,2)~=size(d.perc,2) && d.dF==0;
    msgbox('All ROIs need to be plotted before you can see corresponding postition of the mouse with cell activity!','ATTENTION');
    return;
end

nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
traceg=zeros(nframes,2);

%tracing center of the extracted green dot
h=waitbar(0,'Tracing green spot');
for k=1:nframes;
    stats=regionprops(v.coloredObjectsMaskG(k).cdata, {'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        x(k,:) = c(1);
        y(k,:) = c(2);
    else
        x(k,:) = 0;
        y(k,:) = 0;
    end
    traceg(:,1)=x; %coordinates of the mouse center
    traceg(:,2)=y;
    waitbar(k/nframes,h);
end
close(h);
%plotting green trace
tracegplot=traceg(traceg>0);
tracegplot=reshape(tracegplot,[size(tracegplot,1)/2,2]);
figure, image(v.imd(1).cdata); hold on;
plot(tracegplot(:,1),tracegplot(:,2),'g');


nframes=size(v.imd,2);
x=zeros(nframes,1);
y=zeros(nframes,1);
tracep=zeros(nframes,2);

%tracing center of the extracted pink dot
h=waitbar(0,'Tracing pink spot');
for k=1:nframes;
    stats=regionprops(v.coloredObjectsMaskP(k).cdata, {'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        x(k,:) = c(1);
        y(k,:) = c(2);
    else
        x(k,:) = 0;
        y(k,:) = 0;
    end
    tracep(:,1)=x; %coordinates of the mouse center
    tracep(:,2)=y;
    waitbar(k/nframes,h);
end
close(h);
%plotting pink trace
tracepplot=tracep(tracep>0);
tracepplot=reshape(tracepplot,[size(tracepplot,1)/2,2]);
plot(tracepplot(:,1),tracepplot(:,2),'r');
hold off;

%calculating the amount of time the mouse was out of view in percent
percOutside=round((length(tracep)-length(tracepplot))/length(tracep)*100,1); %tracepplot excludes values of zero, which means mouse was out of view

%calculating traveled distance
x=diff(tracepplot(:,1));
x=sqrt(x.^2);
y=diff(tracepplot(:,2));
y=sqrt(y.^2);
dist=sqrt(x.^2+y.^2);
totalDistIncm=sum(dist(dist>1 & dist<30)); %movement is consider at least 1 pixel and at most 30 pixels at once

%pixel in cm
factor=30/size(v.imd(1).cdata,2);
totalDistIncm=round(totalDistIncm*factor,1);

%calculating percent pause
pause=sum(dist(:) <= 1); % change 1 to any other number if wanted, 1 is one pixel movement
percPause=round(pause/length(tracep)*100,1); %percent in regards to the whole time

%velocity in cm/s
VelocityIncms=round(totalDistIncm/(length(tracepplot)/25),1); %mean velocity while it was visible

%calculating amount if time the mouse was in the bowl or in the open compartment in percent
%selecting bowl area
figure,image(v.imd(1).cdata);
uiwait(msgbox('Please define the bowl compartment by clicking around the area!','Attention'));
ROI=roipoly;
close(gcf);
z=find(ROI>=1);
z(z>size(v.imd(1).cdata,1))=0;
border=max(z);
Xvalues=tracepplot(:,2);
Xvalues(Xvalues>border)=0;
percBowl=round(numel(find(Xvalues>0))/length(tracep)*100,1); %percent in regards to the whole time
percOpen=100-percBowl-percOutside;

%saving as table
T=table(totalDistIncm,VelocityIncms,percPause, percOutside, percBowl, percOpen);
filename=[d.pn '\' d.fn(1:end-4) 'behavior.xls'];
writetable(T,filename);

%plotting cell activity
printyn=1; %for printing figures
if d.dF==1;
    d.perc=d.ROImeans;
end
x=zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),size(d.perc,2));
for j=1:size(d.perc,2);
    n=0;
    c=0;
    a=0;
    ArrowCoord=[];
    for k=1:floor(length(traceg)/round(length(traceg)/size(d.perc,1),2));
        if d.perc(k,j)>=std(d.ROImeans(:,j))*2  && traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)>0 && tracep(round(k*round(length(traceg)/size(d.perc,1),2)),1)>0; %>=0.6
            c=c+1;
            a=a+1;
            ArrowCoord{a,j}=[traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1);traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)];
            x(round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2)),round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)),j)=x(round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2)),round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)),j)+1;
            x(round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)),round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1)),j)=x(round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)),round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1)),j)+1;
        elseif d.perc(k,j)>=std(d.ROImeans(:,j))*2  && traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)>0 && tracep(round(k*round(length(traceg)/size(d.perc,1),2)),1)==0; %>=0.6
%         drawArrow([traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1)],[traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)],'MaxHeadSize',10,'LineWidth',3,'Color',[1 0 0]);
            x(round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2)),round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)),j)=x(round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2)),round(traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)),j)+1;
            c=c+1;
%             ArrowCoord{c,j}=[traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1);traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)];
        elseif d.perc(k,j)>=std(d.ROImeans(:,j))*2  && traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)==0 && tracep(round(k*round(length(traceg)/size(d.perc,1),2)),1)>0; %>=0.6
%         drawArrow([traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1)],[traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)],'MaxHeadSize',10,'LineWidth',3,'Color',[1 0 0]);
            x(round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)),round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1)),j)=x(round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)),round(tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1)),j)+1;
            c=c+1;
%             ArrowCoord{c,j}=[traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1);traceg(round(k*round(length(traceg)/size(d.perc,1),2)),2) tracep(round(k*round(length(tracep)/size(d.perc,1),2)),2)];
        end
        if d.perc(k,j)>=std(d.ROImeans(:,j))*2 && (tracep(round(k*round(length(tracep)/size(d.perc,1),2)),1)==0 && traceg(round(k*round(length(traceg)/size(d.perc,1),2)),1)==0); %>=0.6
            n=n+1;
        end
    end
    %position distribution in percent
    x=x./(c+n);
    %plot cell activity
    h=figure(4+j), image(v.imd(1).cdata); hold on;
    string=sprintf('ROI No.%d',j);
    title(string);
    cellactive=imresize(imresize(x,0.25),4);
    colormap(jet),grid=imagesc(cellactive(:,:,j)),cb=colorbar,cb.Label.String = 'Position distribution in %';
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.75);
    %display how many percent mouse was registered out of bounds
    OoB=round(100*(n/(n+c)));
    str=sprintf('Cell fires when mouse is out of bounds in %d percent of cases',OoB);
    text(20,20,str,'Color','r');
    % plot direction
    drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:});
    for  k=1:size(ArrowCoord,1);
        drawArrow([ArrowCoord{k,j}(1,1) ArrowCoord{k,j}(1,2)],[ArrowCoord{k,j}(2,1) ArrowCoord{k,j}(2,2)],'MaxHeadSize',5,'LineWidth',1,'Color',[1 0 0]);
    end
    hold off;
    if printyn==1
        name=sprintf('ROI%d_trace',j);
        path=[d.pn '/',name,'.png'];
        path=regexprep(path,'\','/');
        print(h,'-dpng','-r100',path); %-depsc for vector graphic 
    end
end
v.pushed=1; %signals to show original video again
msgbox('Tracing Completed','Success');
    






%% BEHAVIORAL DETECTION


% --- Executes on button press in pushbutton29.            BUTTON DETECTION
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
global v
d.stop=0;
%checks if a video file was selected
if v.pushed==0;
    msgbox('PLEASE SELECT FOLDER FIRST!','ERROR');
    return;
elseif v.pushed==0;
    v.imd=[];
    nframes=[];
elseif v.pushed==1;
    v.hsvP=[];
    v.hsvG=[];
    nframes=size(v.imd,2);
elseif v.pushed>=1;
    nframes=size(v.imd,2);
end

if  v.pushed==1;
    v.play=1;
    axes(handles.axes2);
    for k=round(handles.slider7.Value):size(v.imd,2);
    image(v.imd(k).cdata); %original video
    handles.slider7.Value=k;
    textLabel = sprintf('%d / %d', round(handles.slider7.Value),maxframes);
    set(handles.text36, 'String', textLabel);
    pause(0.05);
    if d.stop==1;
        return;
    end
    if k==size(v.imd,2);
        v.play=0;
    end
    end
end




% --- Executes on key press with focus on pushbutton29 and none of its controls.
function pushbutton29_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% determine the key that was pressed 
 keyPressed = eventdata.Key;

 if strcmpi(keyPressed,'s')
     % set focus to the button
     uicontrol(handles.pushbutton29);

     % call the callback
     pushbutton29_Callback(handles.pushbutton29,[],handles);
 end
