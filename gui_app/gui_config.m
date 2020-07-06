% basic configuration after parameters in gui have been set
%function gui_config()
    ir = ImageReader(src, L, R, start, N);
    
    % Load background image
    bg = imread(background_path);

%end