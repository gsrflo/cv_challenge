# cv_challenge
demo for the computer vision lecture at TUM

## Best practice
To get the best result, please use the following settings:
....

To use an animated background, please use the GIF format.
Therefor, just hand over the desired background to the *bg_name* variable.
To get the best experience, please use GIFs with a dedicated "Download" button (e.g. https://gifer.com/en) and do not right-click and save as image.

## GUI
To start the gui, run
```matlab
  start_gui
```
in the command window in Matlab. Before being able to run the script, choose a path leading to one of the chokepoint datasets, and a background.
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
1. When opening the file selector on MacOS the window opens behind the GUI UI. This is a kknowen issue by Matlab and might be fixed in the future.
   > [Here](https://de.mathworks.com/matlabcentral/answers/518793-how-to-make-uigetfile-window-pops-up-in-front-of-my-app-designed-in-appdesigner) is a discussion
