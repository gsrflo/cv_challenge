%% Computer Vision Challenge 2020 config.m

%% General Settings
% Group number:
group_number = 10;

% Group members:

members = {'Florian Geiser'};

% Email-Address (from Moodle!):

mail = {'florian.geiser@tum.de'};

%% Setup Image Reader
% Specify Scene Folder
src = 'Chokepoint/P1E_S1';

% Select Cameras
L = 1;
R = 2;

% Choose a start point
start = 10;

% Choose the number of succeeding frames
N = 5;
ir = ImageReader(src, L, R, start, N);

%% Output Settings
% Output Path
dst = "output.avi";

% Load Virtual Background
% enter .jpg file or .gif file
bg_name = "nyan_cat.gif";

% distinguish between jpg and gif
try
    [gif_image, cmap] = imread(bg_name, 'Frames', 'all');
    gif = 1;
catch
    bg = imread(bg_name);
    gif = 0;
end


% Select rendering mode
mode = "substitute";

% Store Output?
store = false;
