 function [mask] = segmentation(left, right)
    % This function determines the foreground-mask of the middle image of the
    % left camera ( i.e., left(:,:,3*floor((N+1)/2)-2:3*floor((N+1)/2)) ).
    % Stereo-information is not needed for this method, so the tensor 
    % "right" is not used.

    %left: tensor of current image + N follow-up images from left camera
    %right: tensor of the current image + N follow-up images from right camera
    %mask: segmentation mask - entries with 1: foreground
    
        

    %% Background estimation
    %Number of follow-up images
    N = size(left, 3) / 3 - 1;

    %Initialize background estimate
    bg = uint8(zeros(size(left(:, :, 1:3))));

    vec=[1,(N + 1) * 3 - 2];                %only first and last element of tensor is taken for rough background-estimation
    %vec = 1:3:(N + 1) * 3 - 2;             %take every element of tensor for background-estimation
    
    %Estimate background via median of images
    bg(:, :, 1) = uint8(median(left(:, :, vec    ), 3));        %red
    bg(:, :, 2) = uint8(median(left(:, :, vec + 1), 3));        %green
    bg(:, :, 3) = uint8(median(left(:, :, vec + 2), 3));        %blue
  
    %% Compute foreground mask:
  
    %Idea: the foreground is detected by substracting the background from the
    %images and compare the error between the (floor((N+1)/2)+1)-th
    %image and the (floor((N+1)/2)-1)-th image (following and previous
    %frame of (current) middle frame). Additionally, differences in
    %detected edges of those images is taken into account.

    %NOTE: substracting variables of type uint8 gives 0 instead of negative
    %values! This is used here to give 'positive' and 'negative' deviations
    %different weights.
    
    %number of (current) middle frame
    Nr = floor((N+1)/2);
    
    %median of background: is added when substracting the background to
    %keep the overall brightness, but later cancelled out in the
    %substraction of following and previous image.
    bg_med = median(bg,'all');

    %positive deviation: image brighter than background
    dev_pos = rgb2gray(left(:, :, 3*(Nr+1)-2:3*(Nr+1)) - bg) + bg_med;
    dev_pos_med = rgb2gray(left(:, :, 3*(Nr-1)-2:3*(Nr-1)) - bg) + bg_med;                

    %negative deviation: background brighter than image
    dev_neg = rgb2gray(bg - left(:, :, 3*(Nr+1)-2:3*(Nr+1))) + bg_med;
    dev_neg_med = rgb2gray(bg - left(:, :, 3*(Nr-1)-2:3*(Nr-1))) + bg_med;        

    %bound for positive deviation:
    bound_pos = 9;

    %bound for negative deviation:
    bound_neg = 12;

    %FOREGROUND MASK:
    mask = (imabsdiff(dev_pos,dev_pos_med) > bound_pos) | (imabsdiff(dev_neg,dev_neg_med)> bound_neg); 

    %Removing noise (pixel areas < 30)
    mask = bwareaopen(mask, 30,8);

    %Edge Detection: 
    edg_window=imdilate(mask,strel('square',30));         %Take only the edge near the already detected mask
    edg1=edge(rgb2gray(left(:, :, 3*(Nr+1)-2:3*(Nr+1))),'Sobel',0.01).*edg_window;
    edg2=edge(rgb2gray(left(:, :, 3*(Nr-1)-2:3*(Nr-1))),'Sobel',0.01).*edg_window;

    %Adding the detected difference in edges to the mask
    mask = mask | bwmorph(bitxor(uint8(edg1), uint8(edg2)),'dilate');

    %Removing noise
    mask = bwareaopen(mask, 50,8);

    %Connecting close pixels to clusters
    mask=bwmorph(mask, 'majority',2);
    mask=bwmorph(mask, 'close',2);

    %Remove areas < 4000 (for small false-detected areas)
    mask = bwareaopen(mask, 4000,8);

    %Fill holes and "peninsulas" by operating on inverse mask
    mask = ~imopen(bwareaopen(~mask, 10000,8),strel('square',60));

    %Fill remaining holes 
    mask(end-1,find(mask(end-1,:),1,'first'):find(mask(end-1,:),1,'last'))=1;
    mask=imfill(mask,'holes');

    %Smooth edges of mask
    mask=imclose(mask,strel('disk',20));
    mask=imopen(mask,strel('disk',7));

    %convertion to uint8, so that the mask can later be used like: img.*mask      
    mask = uint8(mask);

 end
