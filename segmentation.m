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
  %       - 20200707: Updated segmentation method

  % TODO: - finding parameters with best result
  %       - finding method with lowest computation time

  %% Background estimation
  %Number of follow-up Images
  N = size(left, 3) / 3 - 1;

  %Initialize background image
  bg = uint8(zeros(size(left(:, :, 1:3))));

  vec=[1,(N + 1) * 3 - 2];
  %Estimate background via median of Nr follow-up images
  bg(:, :, 1) = uint8(median(left(:, :, vec    ), 3));
  bg(:, :, 2) = uint8(median(left(:, :, vec + 1), 3));
  bg(:, :, 3) = uint8(median(left(:, :, vec + 2), 3));
  
  %% Compute foreground mask:
  
  %mode to switch between the methods. 
  %mode=0: Compare to background
  %mode=1: vision.ForegroundDetector
  mode = 0;
  
  switch mode
      case 0
        %% Compare to background
        %Idea: the foreground is detected by substracting the background from the
        %images and compare the error between the (floor((N+1)/2)+1)-th
        %image and the (floor((N+1)/2)-1)-th image (following and previous
        %frame. Additionally, edge detection is used.

        %NOTE: substracting variables of type uint8 gives 0 instead of negative
        %values! This is used here to give 'positive' and 'negative' deviations
        %different weights.
        
        Nr = floor((N+1)/2);
        
        bg_med = median(bg,'all');
        
        %positive deviation: image brighter than median
        dev_pos = rgb2gray(left(:, :, 3*(Nr+1)-2:3*(Nr+1)) - bg) + bg_med;
        dev_pos_med = rgb2gray(left(:, :, 3*(Nr-1)-2:3*(Nr-1)) - bg) + bg_med;                
        
        %negative deviation: median brighter than image
        dev_neg = rgb2gray(bg - left(:, :, 3*(Nr+1)-2:3*(Nr+1))) + bg_med;
        dev_neg_med = rgb2gray(bg - left(:, :, 3*(Nr-1)-2:3*(Nr-1))) + bg_med;        
        
        %bound for positive deviation:
        bound_pos = 8;

        %bound for negative deviation:
        bound_neg = 10;
        
        %FOREGROUND MASK:
        %mask = (dev_pos - bg_med> bound_pos) | (dev_neg - bg_med> bound_neg);
        mask = (imabsdiff(dev_pos,dev_pos_med) > bound_pos) | (imabsdiff(dev_neg,dev_neg_med)> bound_neg);     %comparison with the previos image
        
        %Removing noise (pixel areas < 15)
        mask = bwareafilt(logical(mask),[15,inf]);
        
        %Edge Detection:
        %[G1,~] = imgradient(rgb2gray(left(:, :, 3*(Nr+1)-2:3*(Nr+1))));
        %edg1=(abs(G1)>20).*imdilate(mask,strel('disk',50));
        %[G2,~] = imgradient(rgb2gray(left(:, :, 3*(Nr-1)-2:3*(Nr-1))));
        %edg2=(abs(G2)>20).*imdilate(mask,strel('disk',50));
        edg_window=imdilate(mask,strel('disk',30));         %Take only the edge near the already detected mask
        edg1=edge(rgb2gray(left(:, :, 3*(Nr+1)-2:3*(Nr+1))),'Sobel',0.02).*edg_window;
        edg2=edge(rgb2gray(left(:, :, 3*(Nr-1)-2:3*(Nr-1))),'Sobel',0.02).*edg_window;
        
        %Adding the detected difference in edges to the mask
        mask = mask | bwmorph(bitxor(uint8(edg1), uint8(edg2)),'close');
        
        %Removing noise
        mask = bwareafilt(logical(mask),[100,inf]); 
        
        %Connecting close pixels to clusters
        mask=bwmorph(mask, 'majority',2);
        mask=bwmorph(mask, 'close', 5);
        
        %Remove areas < 2000 (for small false-detected areas)
        mask = bwareaopen(mask, 2000,8);
        
        %Fill holes and "peninsulas" by operating on inverse mask
        mask = ~imopen(bwareaopen(~mask, 10000,8),strel('disk',40));
        
        %Fill remaining holes
        mask=imclose(mask,strel('diamond',10)); 
        mask(end-1,find(mask(end-1,:),1,'first'):find(mask(end-1,:),1,'last'))=1;
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
        Nr = floor((N+1)/2);
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
