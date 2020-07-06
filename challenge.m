%% Computer Vision Challenge 2020 challenge.m

%% Start timer here
t_start = tic;

% Initialize indices
loop = 0;
i = 0;
j = 0;

if store
    % Create a movie array
    height_px = 600;
    width_px = 800;
    nr_total_frames = 3000;
    % Sequence of RGB images (height x width x 3 x frames)
    movie = zeros(height_px, width_px, 3, nr_total_frames, 'uint8');
end

if gif
    % load gif and define parameters
    %[gif_image, cmap] = imread(bg, 'Frames', 'all');
    [~, ~, ~, num_gif_images] = size(gif_image);
    
    % construct an empty movie by initializing dimensions
    result = zeros(600, 800, 3, num_images, 'uint8');
end
%% Generate Movie

while loop ~= 1
  i = i + 1;
  % Get next image tensors
  [left, right, loop] = ir.next();
  % Generate binary mask
  mask = segmentation(left, right);
  
  % GIF background?
  if gif
      % use a second iteration variable
      j = j+1;
      % check if iteration variable already exceeded amount of frames
      if j >= num_gif_images
          j = 1;
      end
      
      % choose frame and convert it
      % Multiply with 255: colormaps read in from GIFs represent colors
      % in the range 0 to 1, rather than integers 0 to 255
      gif_frame = gif_image(:,:,:, j);
      gif_frame_rgb = uint8(255 * ind2rgb(gif_frame, cmap));
      
      % resize image and define background
      bg = imresize(gif_frame_rgb, [600,800]);
      
  end
  
  % Render new frame
  if store
    movie(:, :, :, i) = render(left(:, :, 1:3), mask, bg, mode);
  else
    render(left(:, :, 1:3), mask, bg, mode);
  end
end

%% Stop timer here
elapsed_time = toc(t_start);
fprintf('Elapsed time: %.3f seconds = %.3f minutes\n', elapsed_time, elapsed_time / 60);

%% Write Movie to Disk
if store
  % default frame rate for the VideoWriter object is 30 frames per second
  v = VideoWriter(dst, 'Motion JPEG AVI');
  v.Quality = 100;
  open(v);
  for j = 1:i
    frame = im2frame(movie(:, :, :, j));
    writeVideo(v, frame);
  end
  close(v);
end
