function [result] = render(frame, mask, bg, mode)
%% Computer Vision Challenge - Object Detection - render.m
%
% Author: Florian Geiser
% July 2020; Last revision: 06-07-2020

% Overview
% 4 Modes:
% 1 - foreground: background black
% 2 - background: foreground black
% 3 - overlay: set fore and background different (transparent) colors
% 4 - substitute: substitute background with "bg"
%

debug = false;

% ---- for debugging, add dummies -------
if debug
    % dummy picture
    frame = imread("pic1.jpg");
    mode = "gif";
    % dummy mask
    mask1 = zeros(600, 450);
    mask2 = ones(600, 200);
    mask3 = zeros(600, 150);
    mask = uint8([mask1 mask2 mask3]);
    % dummy background
    bg = imread("windows_background.jpg");
    % dummy gif
    gif = "nyan_cat.gif";
end

%----------------------------------------

% invert mask for background mode
mask_inv = uint8(~mask);


% distinguish modes
switch mode
    case "foreground"
        % Case 1: foreground
        
        % keep foreground, set background black
        result = frame .* mask;
        
        imshow(result);
    case "background"
        % Case 2: background
        
        % keep background, set foreground black
        result = frame .* mask_inv;
        
        imshow(result);
    case "overlay"
        % Case 3: overlay
        
        % picture preperation
        dbl_input_image = (frame);
        image_r = dbl_input_image(:, :, 1);
        image_g = dbl_input_image(:, :, 2);
        image_b = dbl_input_image(:, :, 3);
        
        % keep foreground
        foreground_r = image_r .* mask;
        foreground_g = image_g .* mask * 1.5;
        foreground_b = image_b .* mask;
        
        % keep background
        background_r = image_r .* mask_inv;
        background_g = image_g .* mask_inv;
        background_b = image_b .* mask_inv * 1.5;
        
        % merge foreground and background
        overlay_r = foreground_r + background_r;
        overlay_g = foreground_g + background_g;
        overlay_b = foreground_b + background_b;
        
        % put layers together
        result(:, :, 1) = overlay_r;
        result(:, :, 2) = overlay_g;
        result(:, :, 3) = overlay_b;
        
        imshow(result);
        
    case "substitute"
        % Case 4: substitute
        
        % resizing bg image to 800x600px
        bg = imresize(bg, [600,800]);
        
        % change foreground
        foreground = frame .* mask;
        
        % keep background
        background = bg .* mask_inv;
        
        % merge foreground and background
        result = foreground + background;
        
        imshow(result);
        
    otherwise
        error("Error: no mode selected")
end


end
