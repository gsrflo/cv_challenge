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

%% How To
% 1: Assign a source:src='ChokePoint/P1E_S1'
% 2: Create an ImageReader-instance: ir=ImageReader('src',src,'L',1,'R',2,'start',1498,'N',50);
% 3: Call the next-method: [left,right,loop,ab] = ir.next();

%% Implementation

classdef ImageReader

  properties
    src % base folder src
    L % which camera should be left cam
    R % which camera should be right cam
    start % which frame to start
    N % amount of following frames, default=1
    targetL % target folder left cam
    targetR % target folder right cam
    loop % default = 0, if loop=1 folder ran out of images, next one starts at 00000000.jpg
  end

  methods

    function irObj = ImageReader(src, L, R, varargin)%start N (start is optional)    
        % Constructor method        
        % assign and check validity of src 
        try irObj.src = char(src);
        catch
            error('Input argument src must be a string or char.')
        end
        
        % assign check validity of L
        if isnumeric(L) && ((L == 1) || (L == 2))
            irObj.L = L; 
        else
            error('Input argument L must be numeric and value 1 or 2.')
        end
        
        % assign check validity of R
        if isnumeric(R) && ((R == 2) || (R == 3))
            irObj.R = R;
        else
            error('Input argument R must be numeric and value 2 or 3.')
        end
        
        if nargin ==5
            % assign and check validity of start (second check later in the code)
            if isnumeric(varargin{1}(1))
                irObj.start = varargin{1}(1);
            else
                error('Input argument start must be numeric.')
            end
            % assign and check validity of N
            if isnumeric(varargin{2}(1))
                irObj.N = varargin{2}(1);
            else
                error('Input argument N must be numeric.')
            end
        elseif nargin == 4
            irObj.start = 0;
            % assign and check validity of N
            if isnumeric(varargin{1}(1))
                irObj.N = varargin{1}(1);
            else
                error('Input argument N must be numeric.')
            end 
        else
          error('Wrong number of input arguments')
        end      
  
      %Read targets
      [irObj.targetL, irObj.targetR] = readSrc(irObj);

    end
    
      
    function [targetL, targetR] = readSrc(irObj)
      % Function for reading/generating source-path
      L_str = num2str(irObj.L);
      R_str = num2str(irObj.R);
      targetL = strcat(irObj.src, irObj.src((end - 6):end), '_C', L_str, '/');
      targetR = strcat(irObj.src, irObj.src((end - 6):end), '_C', R_str, '/');
    end

    function [left, right, loop, irObj] = next(irObj)
      % Function for getting the next N+1 images
      % The image list for all subfolders in a folder P**_S* is identical
      % This algorithm takes image list from left camera as reference

      % Initialize containers
      left = []; right = [];

      % Read filenames from text-file in respective folder
      f = fopen(strcat(irObj.targetL, 'all_file.txt'));
      data = textscan(f, '%s');
      fclose(f);

      % Get startvalue
      [startInd, endInd] = startFrameToStartList(irObj, data);

      % Get filenames as a char-array to iterate through
      filenames = cell2mat(data{1, 1});

      % Get N+1 images and stack them into 600x800x[(N+1)*3]
      for ind = startInd:(startInd + irObj.N + 1)
        %display(strcat('startIndex is ', num2str(ind)));

        if ind <= endInd
          %display(strcat('listIndex is ', data{1}{ind}(1:8)));
          % If current index is smaller/equal the end of the list
          loop = 0;
          % Call path and get current image
          currentImageL = imread(strcat(irObj.targetL, filenames(ind, 1:12)));
          currentImageR = imread(strcat(irObj.targetR, filenames(ind, 1:12)));

          % Stack image into 600x800x[(N+1)*3]
          left = cat(3, left, currentImageL);
          right = cat(3, right, currentImageR);
        else
          % If current index is greater the end of the list
          loop = 1;
        end

      end

      function [startInd, endInd] = startFrameToStartList(irObj, data)
        %Function for getting start value in the list

        % Convert number into strin of form '0000xxxx,jpg'
        startStr = strcat(num2str(irObj.start, '%08.f'), '.jpg');

        % Find index of starting frame
        indexArr = strfind(data{1}, startStr);
        startInd = find(not(cellfun('isempty', indexArr)));

        % Check if given 'start'-value is valid
        if isempty(startInd)
          error('Given variable "start" is not a starting frame. Please choose a valid value!')
        else
          endInd = size(data{1}, 1);
        end

        % Update the start property of the class
        if irObj.loop == 0
          irObj.start = str2double(data{1}{ind}(1:8)) + irObj.N;
        else
          irObj.start = 0;
          %disp('Starting from new again')
        end

        loop = irObj.loop;
      end

    end

  end

end
