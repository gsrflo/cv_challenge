%function [result] = render(frame,mask,bg,mode)


%% comment on function to get variables in matlab workspace

% Overview
% 4 Modes:
% 1 - foreground: background black
% 2 - background: foreground black
% 3 - overlay: set fore and background different (transparent) colors
% 4 - substitute: substitute background with "bg"
%

% init
frame = zeros(600,800);
mask = zeros(600,800);
bg = zeros(600,800);

foreground = zeros(600,800);
background = zeros(600,800);

% ---- for debugging, add dummies -------
mode = 2;
mask = ones(600,800);
mask = triu(mask);
%----------------------------------------

input_image = imread("pic1.jpg");
mask_inv = ones(size(mask)) - mask;

% picture preperation
dbl_input_image = double(input_image);
image_r = dbl_input_image(:,:,1);
image_g = dbl_input_image(:,:,2);
image_b = dbl_input_image(:,:,3);


% distinguish modes
switch mode
    case 1
        % Case 1: foreground
        disp("case1 selected")
        
        % keep foreground, set background black
        foreground_r = image_r .* mask;
        foreground_g = image_g .* mask;
        foreground_b = image_b .* mask;
        
        % put layers together
        output_image(:,:,1) = foreground_r;
        output_image(:,:,2) = foreground_g;
        output_image(:,:,3) = foreground_b;
        output_image = uint8(output_image);
    case 2
        % Case 2: background
        disp("case2 selected")
        
        % keep background, set foreground black
        background_r = image_r .* mask_inv;
        background_g = image_g .* mask_inv;
        background_b = image_b .* mask_inv;
        
        % put layers together
        output_image(:,:,1) = background_r;
        output_image(:,:,2) = background_g;
        output_image(:,:,3) = background_b;
        output_image = uint8(output_image);
        
    case 3
        % Case 3: overlay
        disp("case3 selected")
    case 4
        % Case 4: substitute
        disp("case4 selected")
    otherwise
        disp("Error: no mode selected")
end



imshow(output_image)
%hold on


%end
