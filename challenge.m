%% Computer Vision Challenge 2020 challenge.m

%% Start timer here
t_start = tic;

% Initialize indices
loop = 0;
i = 0;

%% Generate Movie

while loop ~= 1
    % Get next image tensors
    left, right, loop = ir.next()
    % Generate binary mask
    mask = segmentation(left, right)
    % Render new frame
    movie(:, :, :, (N+1)*i+1:(N+1)*(i+1)+1) = render(frame, mask, bg, mode)
    i = i + 1
end

%% Stop timer here
elapsed_time = toc(t_start);
fprintf('Elapsed time: %.3f seconds = %.3f minutes\n', elapsed_time, elapsed_time / 60);

%% Write Movie to Disk
if store
    % Delete black images from movie array
    movie_filtered = movie(:, :, :, 1:(N+1)*(i+1)+1)
    v = VideoWriter(dst, 'Motion JPEG AVI');
    v.Quality = 100;
    open(v)
    writeVideo(v, movie_filtered)
    close(v)
end
