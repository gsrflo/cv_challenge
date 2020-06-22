%% ImageReader
% Author: Berni Hausleitner
% Log:  - 20200621: Setting up initial structure and constructor of class
%       - 20200622: Setting up next method

% TODO: - start parameter stuff
%       - relative path handling

% function should be able to process two videostreams from one folder into
% an endless loop

% ImageReader will be a class with the method next()

% generate string P**_S*_C*

%% Params
% src: string entailing the different relative/absolute paths
% L: left Camera (1,2)
% R: right Camera (2,3)
% start: framenumber to start with (optional, if nothing: 0)
% N: amount of following frames per reading process (N=1)

%% Methods
% next: "left,right,loop = ir.next()" 
% -> params: 
%           - left: tensor with frames of left camera 600x800x(N+1)*3
%           - right: tensor with frames of right camera 600x800x(N+1)*3
%           - loop: 0, if not enough pics in folder, just give back the existing ones -> loop = 1
%           -> if loop=1, next call of next() starts at 0000000.jpg

%% Implementation

classdef ImageReader
   properties
      src %base folder src
      L %which camera should be left cam
      R %which camera should be right cam
      start %which frame to start
      N %amount of following frames, default=1
      targetL %target folder left cam
      targetR %target folder right cam
      loop % default = 0, if loop=1 folder ran out of images, next one starts at 00000000.jpg
   end
   
   methods
      function irObj = ImageReader(varargin)
         % Constructor method
         if nargin > 3
            % Create Input Parser instance
            p = inputParser;
            
            % Set default values for inputs
            default_src='./joman/this_is_a_test_string_char';
            default_start=0;
            default_N=1;
            
            % Check-function for input variables
            checkL = @(x) isnumeric(x) && ((x==1) || (x==2));
            checkR = @(x) isnumeric(x) && ((x==2) || (x==3));
            checkSrc = @(x) isa(x,'char') || isa(x,'string');
            
            % Add Params to the Parser-Instance
            addParameter(p,'src',default_src,checkSrc)
            addParameter(p,'L',@isnumeric,checkL)
            addParameter(p,'R',@isnumeric,checkR)
            addOptional(p,'start',default_start,@isnumeric)
            addParameter(p,'N',default_N,@isnumeric)
    
            % Fill the varargin matrix
            parse(p,varargin{:})
    
            % Assign the output values
            irObj.src = p.Results.src;
            irObj.L = p.Results.L;
            irObj.R = p.Results.R;
            irObj.start = p.Results.start;
            irObj.N = p.Results.N;
            
            % Read targets
            [irObj.targetL, irObj.targetR] = readSrc(irObj);
            
            %next stack of images
         else
            error('Wrong number of input arguments')
         end
         
      end
      
      
      function [targetL, targetR] = readSrc(irObj)
          % Function for reading/generating source-path
          L_str=num2str(irObj.L);
          R_str=num2str(irObj.R);
          targetL=strcat(irObj.src,irObj.src((end-6):end),'_C',L_str,irObj.src(end-6));
          targetR=strcat(irObj.src,irObj.src((end-6):end),'_C',R_str,irObj.src(end-6)); 
      end
      
      function [left,right,loop,irObj] = next(irObj)
          % Function for getting the next N+1 images
          % The image list for all subfolders in a folder P**_S* is identical
          % This algorithm takes image list from left camera as reference
          
          % Initialize containers
          left=[]; right=[];irObj.loop=0;
          
          % Read filenames from text-file in respective folder
          f=fopen(strcat(irObj.targetL,'all_file.txt'));
          data=textscan(f,'%s');
          fclose(f);
          
          % Get startvalue
          [startInd,endInd] = startFrameToStartList(irObj,data);
          
          % Get filenames as a char-array to iterate through
          filenames = cell2mat(data{1,1});  
        
          % Get N+1 images and stack them into 600x800x[(N+1)*3]
          for ind=startInd:(startInd+irObj.N)
              %display(strcat('startIndex is ',num2str(ind)));             
              
              
              if ind <= endInd
                  %display(strcat('listIndex is ',data{1}{ind}(1:8)));
                  % If current index is smaller/equal the end of the list
                  irObj.loop=0;
                  % Call path and get current image
                  currentImageL = imread(strcat(irObj.targetL,filenames(ind,1:12)));
                  currentImageR = imread(strcat(irObj.targetR,filenames(ind,1:12)));
              
                  % Stack image into 600x800x[(N+1)*3]
                  left = cat(3,left,currentImageL);
                  right = cat(3,right,currentImageR);
              else
                  % If current index is greater the end of the list
                  irObj.loop=1;
              end
          end
          
          % Update the start property of the class
          if irObj.loop == 0
            irObj.start=str2double(data{1}{ind}(1:8))+irObj.N;
          else
           irObj.start=0;
           %disp('Starting from new again')
          end
          
          loop=irObj.loop;
      end
      
      function [startInd,endInd] = startFrameToStartList(irObj,data)
          %Function for getting start value in the list
          
          % Convert number into strin of form '0000xxxx,jpg'
          startStr=strcat(num2str(irObj.start,'%08.f'),'.jpg');
          
          % Find index of starting frame
          indexArr = strfind(data{1},startStr);
          startInd = find(not(cellfun('isempty',indexArr)));
          
          endInd=size(data{1},1);
      end
      
      
   end
end
