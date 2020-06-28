%% Computer Vision Challenge 2020 config.m

%% General Settings
% Group number:
group_number = 0;

% Group members:
members = {'Max Mustermann'};

% Email-Address (from Moodle!):
mail = {'ga99abc@tum.de'};

%% Setup Image Reader
% Specify Scene Folder
src = 'Chokepoint/P1E_S1';

% Select Cameras
L = 1;
R = 2;

% Choose a start point
start = 2250;

% Choose the number of succeeding frames
N = 5;
ir = ImageReader(src, L, R, start, N);

%% Output Settings
% Output Path
dst = "output.avi";

% Load Virual Background
bg = imread("windows_background.jpg");

% Select rendering mode
mode = "substitute";

% Store Output?
store = false;
