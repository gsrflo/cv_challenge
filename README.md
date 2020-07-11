# cv_challenge
demo for the computer vision lecture at TUM

## Best practice
To get the best result, please use the following settings:
....

To use an animated background, please use the GIF format.
Therefor, just hand over the desired background to the *bg_name* variable.
To get the best experience, please use GIFs with a dedicated "Download" button (e.g. https://gifer.com/en) and do not right-click and save as image.

## ImageReader

The `ImageReader` converts the respective video stream of the dataset into actionable matrices and tensors. The class constructor returns a class object containing following properties:
- `src`: Source Path pointing to the source folder of the ChokePoint dataset, string or char array
- `L`: Selection for left videostream, numeric values {1,2}
- `R`: Selection for right videostream, numeric values {2,3}
- `start`: Starting frame number for segmentation, numeric inbetween framenumber range of folder (optional)
- `N`: Number of returned consecutive frames, numeric

The class constructor returns a class object `ir` and can be called the following way:

```matlab
  ir = ImageReader(src, L, R, start, N);
```

As the variable `start` is optional, the constructor can be also called with 4 input variables, setting the variable `start`internally to default value `1`:

```matlab
  ir = ImageReader(src, L, R, N);
```

### next() Method

This public method is part of the `ImageReader` class and iteratively fills up tensors `left` and `right` starting from the prior intialized sarting frame number `start`. Following output variables will be returned: 
- `left`: Tensor containing left video stream, shape _600 x 800 x (N+1)*3_, numeric
- `right`: Tensor containing right video stream, shape _600 x 800 x (N+1)*3_, numeric
- `loop`: Overflow flag in case ender of frame numer range of folder is reached, numeric values {0,1} 

This public class method can be called the following way:

```matlab
  [left, right, loop] = ir.next();
```

## GUI
To start the gui, run
```matlab
  start_gui
```
in the command window in MATLAB. Before being able to run the script, choose a path leading to one of the chokepoint datasets, and a background.
Supported backgorund data types are:
1. jpg
2. png
3. gif

Any other settings are optional. Standard values are:
1. Start Point: 1
2. Rendering Mode: foreground
3. Left Image: Sequence 1
4. Right Image: Sequence 2
5. Output Video Options: do not store a copy of the video

### Known Issues
1. When opening the file selector on MacOS the window opens behind the GUI UI. This is a known issue by MATLAB and might be fixed in the future.
   > [Here](https://de.mathworks.com/matlabcentral/answers/518793-how-to-make-uigetfile-window-pops-up-in-front-of-my-app-designed-in-appdesigner) is a discussion
