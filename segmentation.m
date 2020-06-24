function [mask] = segmentation(left, right)
  % This function determines the foreground-mask of the first image of the
  % left camera (i.e., left(:,:,1:3) ).

  %left: tensor of current image + N follow-up images from left camera
  %right: tensor of the current image + N follow-up images from right camera
  %mask: segmentation mask - entries with 1: foreground
  % Author: Johannes Teutsch
  % Log:  - 20200622: Setting up initial structure
  %       - 20200624: Extended by alternative: vision.ForegroundDetector

  % TODO: - finding parameters with best result
  %       - finding method with lowest computation time

  %% Background estimation
  %Number of follow-up Images
  N = size(left, 3) / 3 - 1;

  %Reduced number of follow-up images for background estimation (to
  %increase speed by using less images)
  Nr = 15;

  if (Nr > N)
    Nr = N;
  end

  %Initialize background image
  bg = uint8(zeros(size(left(:, :, 1:3))));

  %Estimate background via median of Nr follow-up images
  bg(:, :, 1) = uint8(median(left(:, :, 1:3:(Nr + 1) * 3 - 2), 3));
  bg(:, :, 2) = uint8(median(left(:, :, 2:3:(Nr + 1) * 3 - 1), 3));
  bg(:, :, 3) = uint8(median(left(:, :, 3:3:(Nr + 1) * 3), 3));

  %% Compute foreground mask:
  %Idea: the foreground is detected by substracting the background from the
  %images and compare the error between the current image and the median
  %of all images.

  %tensor of repeated background image - same size as left
  bgrep = repmat(bg, [1, 1, size(left, 3) / 3]);

  %NOTE: substracting variables of type uint8 gives 0 instead of negative
  %values! This is used here to give 'positive' and 'negative' deviations
  %different weights.

  %positive deviation: image brighter than median
  dev_pos = rgb2gray(left(:, :, 1:3) - bg - median(left - bgrep, 3));

  %negative deviation: median brighter than image
  dev_neg = rgb2gray(bg - left(:, :, 1:3) - median(bgrep - left, 3));

  %bound for positive deviation:
  bound_pos = 2;

  %bound for negative deviation:
  bound_neg = 20;

  %foreground mask:
  mask = (dev_pos > bound_pos) | (dev_neg > bound_neg);

  %getting rid of noise:
  mask = imerode(mask, strel('disk', 5));

  %smothing / filling out holes:
  %mask = imdilate(mask,strel('disk',10));
  mask = imclose(mask, strel('disk', 200));

  %convertion to uint8, so that the mask can later be used like: img.*mask
  mask = uint8(mask);

  %% Alternative

  %Computer Vison Toolbox: Foreground Detector
  %{

  %creating detector object:
  num_trainframes = 30;
  detector = vision.ForegroundDetector('NumTrainingFrames',num_trainframes);

  detector = vision.ForegroundDetector;

  %learning-phase of detector using the background estimate
  for i=1:num_trainframes
  detector(bg);
  end

  %foreground detection;
  mask = detector(left(:,:,1:3));

  %foreground detection;
  mask = detector(left(:, :, 1:3));

  %}
end
