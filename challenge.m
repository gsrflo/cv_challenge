%% Computer Vision Challenge 2020 challenge.m

%% Start timer here
t_start = tic;

% Initialize indices
loop = 0;
i = 0;

if store
  % Create a movie array
  height_px = 600;
  width_px = 800;
  nr_total_frames = 3000;
  % Sequence of RGB images (height x width x 3 x frames)
  movie = zeros(height_px, width_px, 3, nr_total_frames, 'uint8');
end

%% Generate Movie

while loop ~= 1
  i = i + 1;
  % Get next image tensors
  [left, right, loop] = ir.next();
  % Generate binary mask
  mask = segmentation(left, right);
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
