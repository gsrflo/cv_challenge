 function [mask] = segmentation(left, right)
  % This function determines the foreground-mask of the first image of the
  % left camera (i.e., left(:,:,1:3) ).

  %left: tensor of current image + N follow-up images from left camera
  %right: tensor of the current image + N follow-up images from right camera
  %mask: segmentation mask - entries with 1: foreground
  % Author: Johannes Teutsch
  % Log:  - 20200622: Setting up initial structure
  %       - 20200624: Extended by alternative: vision.ForegroundDetector
  %       - 20200625: Minor updates + switch case to choose detector
  %       - 20200702: Minor updates on segmentation

  % TODO: - finding parameters with best result
  %       - finding method with lowest computation time

  %% Background estimation
  %Number of follow-up Images
  N = size(left, 3) / 3 - 1;

  %Initialize background image
  bg = uint8(zeros(size(left(:, :, 1:3))));

  %Estimate background via median of Nr follow-up images
  bg(:, :, 1) = uint8(median(left(:, :, 1:3:(N + 1) * 3 - 2), 3));
  bg(:, :, 2) = uint8(median(left(:, :, 2:3:(N + 1) * 3 - 1), 3));
  bg(:, :, 3) = uint8(median(left(:, :, 3:3:(N + 1) * 3    ), 3));
  
  %Grayimages:
  bg=rgb2gray(bg);
  
  lft_gray=uint8(zeros(size(left,1), size(left,2),N));
  for i=1:N
        lft_gray(:,:,i)=rgb2gray(left(:,:,3*i-2:3*i));
  end

  %% Compute foreground mask:
  
  %mode to switch between the methods. 
  %mode=0: Compare to background
  %mode=1: vision.ForegroundDetector
  mode = 0;
  
  switch mode
      case 0
        %% Compare to background
        %Idea: the foreground is detected by substracting the background from the
        %images and compare the error between the floor(N/2)-th image and the background

        %NOTE: substracting variables of type uint8 gives 0 instead of negative
        %values! This is used here to give 'positive' and 'negative' deviations
        %different weights.
        
        Nr = floor(N/2);
        
        bg_med = median(bg,'all');
        
        %positive deviation: image brighter than median
        %dev_pos = rgb2gray(left(:, :, 3*Nr-2:3*Nr) - bg);
        dev_pos = lft_gray(:, :, Nr) - bg + bg_med;
        %dev_pos_med = lft_gray(:,:,Nr-1) - bg + bg_med;                %in case a comparison with the previos image is desired
        
        %negative deviation: median brighter than image
        %dev_neg = rgb2gray(bg - left(:, :, 3*Nr-2:3*Nr));
        dev_neg = bg - lft_gray(:, :, Nr) + bg_med;
        %dev_neg_med = bg - lft_gray(:,:,Nr-1) + bg_med;                %in case a comparison with the previos image is desired
        
        %bound for positive deviation:
        bound_pos = 8;

        %bound for negative deviation:
        bound_neg = 12;
        
 
        %FOREGROUND MASK:
        mask = (dev_pos - bg_med> bound_pos) | (dev_neg - bg_med> bound_neg);
        %mask = (imabsdiff(dev_pos,dev_pos_med) > bound_pos) | (imabsdiff(dev_neg,dev_neg_med)> bound_neg);     %comparison with the previos image
        
        %delete single pixels and fill holes:        
        mask = bwmorph(mask,'clean');
        mask = bwmorph(mask,'fill');
        
        %group neighboring pixels to (small) clusters (in the hope that
        %the pixels of the foreground combine to one cluster)
        mask = imdilate(mask,strel('disk',1));
        mask = imclose(mask,strel('disk',1));
        
        %delete all clusters whose pixel-area is below 30
        mask = bwareafilt(logical(mask),[30,inf]);
        
        %(get edge of remaining clusters and) fill holes to get big cluster
        mask = bwperim(mask,8);
        mask = imfill(mask,'holes');
        mask = imdilate(mask,strel('disk',4));
        mask = imfill(mask,'holes');
        
        %delete all clusters whose pixel-area is below 6000
        mask = bwareaopen(mask, 6000,8);
        
        %get closed holes at the image bottom (which can then be filled):
        mask(end,find(mask(end,:),1,'first'):find(mask(end,:),1,'last'))=1;
        
        %fill remaining holes
        mask=imclose(mask,strel('disk',50));       
        mask=imfill(mask,'holes');    
        
        %convertion to uint8, so that the mask can later be used like: img.*mask      
        mask = uint8(mask);
        
        %imshow(mask*255);
        
        %OTHER FUNCTIONS OF INTEREST:
        %imopen(mask,strel('object',size)) %erosion followed by dilation
        %imclose(mask,strel('object',size)) %dilation followed by erosion
        %bwmorph(mask,'method') %different morphological operations
        %mask=bwconvhull(mask) %convex hull
      case 1
        %% Computer Vision Toolbox: ForegroundDetector 

        %Computer Vison Toolbox: Foreground Detector
        
        %number of training frames for learing phase;
        num_trainframes = 30;
        
        %creating detector object:
        detector = vision.ForegroundDetector('NumTrainingFrames',num_trainframes);

        %learning-phase of detector using the background estimate
        for i=1:num_trainframes
        detector(bg);
        end
        Nr = floor(N/2);
        %foreground detection;
        mask = detector(lft_gray(:,:,Nr));

        %you can play with these (change order, change parameters):

        %delete single pixels and fill holes:        
        mask=bwmorph(mask,'clean');
        mask=bwmorph(mask,'fill');
        
        %group neighboring pixels to (small) clusters (in the hope that
        %the pixels of the foreground combine to one cluster)
        mask=imdilate(mask,strel('disk',1));
        mask = imclose(mask,strel('disk',1));
        
        %delete all clusters whose pixel-area is below 10
        mask=bwareafilt(logical(mask),[10,inf]);
        
        %fill holes to get big cluster
        mask=imdilate(mask,strel('disk',3));
        mask=imfill(mask,'holes');
        
        %delete all clusters whose pixel-area is below 1000
        mask=bwareaopen(mask, 1000,8);
        
         %get closed holes at the image bottom (which can then be filled):
        mask(end,find(mask(end,:),1,'first'):find(mask(end,:),1,'last'))=1;
        
        %fill remaining holes
        mask=imclose(mask,strel('disk',40));       
        mask=imfill(mask,'holes');
              
        %convertion to uint8, so that the mask can later be used like: img.*mask
        mask = uint8(mask);
        
  end
  
end