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
start = randi(1000);

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

% Create a movie array
height_px = 600;
width_px = 800;
nr_total_frames = 1000;
% Sequence of RGB images (height x width x 3 x frames)
movie = zeros(height_px, width_px, 3, nr_total_frames, 'uint8');

% Store Output?
store = false;
