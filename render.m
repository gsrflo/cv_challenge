function [result] = render(frame, mask, bg, mode)
%% Computer Vision Challenge - Object Detection - render.m
%
% Author: Florian Geiser
% June 2020; Last revision: 26-06-2020

% Overview
% 4 Modes:
% 1 - foreground: background black
% 2 - background: foreground black
% 3 - overlay: set fore and background different (transparent) colors
% 4 - substitute: substitute background with "bg"
%

debug = true;

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
    bg = imread("pic4.jpg");
    % dummy gif
    gif = "nyan_cat.gif";
end

%----------------------------------------

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
        
    case "gif"
        % Case 5: put gif as background
        
        % load gif and define parameters
        [gif_image, cmap] = imread(gif, 'Frames', 'all');
        [~, ~, ~, num_images] = size(gif_image);
        
        % construct an empty movie by initializing dimensions
        result = zeros(600, 800, 3, num_images, 'uint8');
        
        % loop thru every frame
        for i = 1 : num_images
            
          % choose frame and convert it  
          % Multiply with 255: colormaps read in from GIFs represent colors
          % in the range 0 to 1, rather than integers 0 to 255
          gif_frame = gif_image(:,:,:, i);
          gif_frame_rgb = uint8(255 * ind2rgb(gif_frame, cmap));
          
          % resize image and define foreground and background
          gif_frame_rgb = imresize(gif_frame_rgb, [600,800]);
          foreground = frame .* mask;
          background = gif_frame_rgb .* mask_inv;
          
          % merge foreground and background
          single_pic = foreground + background;
          
          % set pictures to an 4D array
          result(:,:,:,i) = single_pic;

        end
        
        % show gif
        implay(result);
        
    otherwise
        disp("Error: no mode selected")
end


end
