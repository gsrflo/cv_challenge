%% Computer Vision Challenge 2020 challenge.m

%% Start timer here
t_start = tic;

% Initialize indices
loop = 0;
i = 1;

%% Generate Movie

while loop ~= 1
  % Get next image tensors
  left, right, loop = ir.next()
  % Generate binary mask
  mask = segmentation(left, right)
  % Render new frame
  movie(:, :, :, i:(N + i + 1)) = render(left(:, :, 1), mask, bg, mode)
  i = i + 1
end

%% Stop timer here
elapsed_time = toc(t_start);
fprintf('Elapsed time: %.3f seconds = %.3f minutes\n', elapsed_time, elapsed_time / 60);

%% Write Movie to Disk
if store
  % Delete black images from movie array
  movie_filtered = movie(:, :, :, 1:(N + i + 1))
  v = VideoWriter(dst, 'Motion JPEG AVI');
  v.Quality = 100;
  open(v)
  writeVideo(v, movie_filtered)
  close(v)
end
