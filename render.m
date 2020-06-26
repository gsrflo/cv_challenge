function [result] = render(frame, mask, bg, mode)

  %% comment on function to get variables in matlab workspace

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
    frame = imread("pic1.jpg");
    mode = "substitute";
    % dummy mask
    mask = uint8(ones(600, 800));
    mask = triu(mask);
    % dummy bg
    bg = imread("pic2.jpg");
  end

  %----------------------------------------

  mask_inv = uint8(ones(size(mask))) - mask;

  % distinguish modes
  switch mode
    case "foreground"
      % Case 1: foreground

      % keep foreground, set background black
      result = frame .* mask;
      
    case "background"
      % Case 2: background

      % keep background, set foreground black
      result = frame .* mask_inv;

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

    case "substitute"
      % Case 4: substitute

      % change foreground
      foreground = frame .* mask;

      % keep background
      background = bg .* mask_inv;

      % merge foreground and background
      result = foreground + background;
    otherwise
      disp("Error: no mode selected")
  end

  imshow(result);


end
