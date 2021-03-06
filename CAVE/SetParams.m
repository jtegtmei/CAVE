function options = SetParams(varargin)

% Struct for setting the roisub default algorithm parameters.

Names = [
    % loading
    'bitconv     '  % value for converting 8 bit to 16 bit
    % preprocessing
    'dsw         '  % minimum width at which downsampling is performed
    'dsr         '  % downsampling rate for imresize
    'blur        '  % blur used for flat field correction
    % dust removal
    'dustr       '  % radius of the disk surrounding the ROI to obtain the neighbourhood mean of the ROI
    % alignment
    'wienerp     '  % neighbourhood of m-by-n to estimate local image mean with wiener2 filter
    'usfac       '  % upsampling factor Images will be registered to within 1/usfac of a pixel
    'LClevels    '  % the number of levels for multi-resolution execution, LucasKanade
    'LCiter      '  % the number of algorithm's iteration, LucasKanade
    % delta F/F
    'dbutterd    '  % value for designing butterworth filter
    'dbutterd2   '  % second value for designing butterworth filter
    'dgaussh     '  % Gaussian lowpass filter of size hsize
    'dgausss     '  % Gaussian lowpass filter with standard deviation sigma
    % pca/ica
    'pigausss    '  % 2-D Gaussian smoothing kernel with standard deviation specified by sigma
    'pisaa       '  % smallest acceptable area for ica results
    'pibwP       '  % removes all connected components that have fewer than P pixels from the binary image BW
    'picsize     '  % first inverts images that contain components bigger than P pixels, then removes all components bigger than P pixels
    'pinroT      '  % deletes objects that roundness metric is smaller than T
    'piolO       '  % deletes objects that overlap more than O percent
    % ROI plotting
    'neuF        '  % neuropil correction factor r
    'spkthrs     '  % threshold for detecting spikes from deconvoluted calcium traces as in factor of std
    'ROIdist     '  % distance threshold D between the center of two ROIs, if smaller, then ROIs will bechecked for similar Ca signals
    'sigcorr     '  % correlation coefficient threshold C of the signal of two ROIs, if smaller, ROIs are assumed to be one cell
    'chg         '  % deleting ROIs which maximum fluorescence change is smaller than 0.8%
    % behavioral video
    'bdsr        '  % downsampling rate for imresize for behavioral video
    'bsaa        '  % smallest acceptable area for color spot on animal
    'bdistmin    '  % minimum pixel distance D the animal has to move to be considered moving
    'bdistmax    '  % maximum pixel distance D the 'animal' can move to be considered moving, this should prevent calculating with animal misrepresentation
    % Green preset values
    'hTLg        '  % hue threshold low
    'hTHg        '  % hue threshold high
    'sTLg        '  % saturation threshold low
    'sTHg        '  % saturation threshold high
    'vTLg        '  % value threshold low
    'vTHg        '  % value threshold high
    % Pink preset values
    'hTLp        '  % hue threshold low
    'hTHp        '  % hue threshold high
    'sTLp        '  % saturation threshold low
    'sTHp        '  % saturation threshold high
    'vTLp        '  % value threshold low
    'vTHp        '  % value threshold high
    % Yellow preset values
    'hTLy        '  % hue threshold low
    'hTHy        '  % hue threshold high
    'sTLy        '  % saturation threshold low
    'sTHy        '  % saturation threshold high
    'vTLy        '  % value threshold low
    'vTHy        '  % value threshold high
    % Blue preset values
    'hTLb        '  % hue threshold low
    'hTHb        '  % hue threshold high
    'sTLb        '  % saturation threshold low
    'sTHb        '  % saturation threshold high
    'vTLb        '  % value threshold low
    'vTHb        '  % value threshold high
    ];

[m,~] = size(Names);

Values = [
    % loading
    {65535}     %default: 65535
    % preprocessing
    {100}       %default: 100
    {0.4}       %default: 0.4
    {0.08}      %default: 0.08
    % dust removal
    {8}         %default: 8
    % alignment
    {[6 6]}     %default: [6 6]
    {100}       %default: 100
    {2}         %default: 2
    {5}         %default: 5
    % delta F/F
    {4}         %default: 4
    {0.5}       %default: 0.5
    {5}         %default: 5
    {5}         %default: 5
    % pca/ica
    {1.5}       %default: 1.5
    {30}        %default: 30
    {0.8}       %default: 0.8
    {300}       %default: 300
    {0.6}       %default: 0.6
    {30}        %default: 30
    % ROI plotting
    {0.7}       %default: 0.7
    {2}         %default: 2
    {8}         %default: 8
    {0.8}       %default: 0.8
    {0.8}       %default: 0.8
    % behavioral video
    {0.6}       %default: 0.6
    {25}        %default: 25
    {1}         %default: 1
    {40}        %default: 40
    % Green preset values
    {0.25}      %default: 0.25
    {0.55}      %default: 0.55
    {0.16}      %default: 0.16
    {1}         %default: 1
    {0}         %default: 0
    {0.8}       %default: 0.8
    % Pink preset values
    {0.8}       %default: 0.8
    {1}         %default: 1
    {0.36}      %default: 0.36
    {1}         %default: 1
    {0}         %default: 0
    {0.8}       %default: 0.8
    % Yellow preset values
    {0.12}      %default: 0.12
    {0.25}      %default: 0.25
    {0.19}      %default: 0.19
    {1}         %default: 1
    {0}         %default: 0
    {0.8}       %default: 0.8
    % Blue preset values
    {0.62}      %default: 0.62
    {1}         %default: 1
    {0.3}       %default: 0.3
    {1}         %default: 1
    {0.7}       %default: 0.7
    {1}         %default: 1
    ];

for j = 1:m
    eval(['options.' Names(j,:) '= Values{j};']);
end