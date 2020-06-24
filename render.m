function [result] = render(frame,mask,bg,mode)


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

debug = false;

% ---- for debugging, add dummies -------
if debug
    input_image = imread("pic1.jpg");
    mode = "foreground";
    % dummy mask
    mask = ones(600,800);
    mask = triu(mask);
    % dummy bg
    bg = imread("pic2.jpg");
end
%----------------------------------------


mask_inv = ones(size(mask)) - mask;

% picture preperation
dbl_input_image = double(input_image);
image_r = dbl_input_image(:,:,1);
image_g = dbl_input_image(:,:,2);
image_b = dbl_input_image(:,:,3);

dbl_bg_image = double(bg);
bg_r = dbl_bg_image(:,:,1);
bg_g = dbl_bg_image(:,:,2);
bg_b = dbl_bg_image(:,:,3);

% distinguish modes
switch mode
    case "foreground"
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
    case "background"
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
        
    case "overlay"
        % Case 3: overlay
        disp("case3 selected")
        
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
        output_image(:,:,1) = overlay_r;
        output_image(:,:,2) = overlay_g;
        output_image(:,:,3) = overlay_b;
        output_image = uint8(output_image);
        
    case "substitute"
        % Case 4: substitute
        disp("case4 selected")
        
        % keep foreground
        foreground_r = image_r .* mask;
        foreground_g = image_g .* mask;
        foreground_b = image_b .* mask;
        
        % create background
        background_r = bg_r .* mask_inv;
        background_g = bg_g .* mask_inv;
        background_b = bg_b .* mask_inv;
        
        % merge foreground and background
        substitute_r = foreground_r + background_r;
        substitute_g = foreground_g + background_g;
        substitute_b = foreground_b + background_b;
        
        % put layers together
        output_image(:,:,1) = substitute_r;
        output_image(:,:,2) = substitute_g;
        output_image(:,:,3) = substitute_b;
        output_image = uint8(output_image);
    otherwise
        disp("Error: no mode selected")
end



imshow(output_image)
%hold on


end
