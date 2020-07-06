% Checks wether all variables needed are in the workspace.
% If this is true, a 0 is returned. if not, error status 1 is returned
function status =  check_workspace()
    status = 0;
    
    if exist('src') == 0
        disp('src missing!')
        status = 1;
    end
    
    %if exist('start') == 0
    %    disp('start missing!')
    %    status = 1;
    %end
    
    if exist('dst') == 0
        disp('dst missing!')
        status = 1;
    end
    
    %if exist('background_path') == 0
    %    disp('background_path missing!')
    %    status = 1;
    %end
    
    %if exist('mode') == 0
    %    disp('mode missing!')
    %    status = 1;
    %end
    
    if (store == 1)
        if exist('background_path') == 0
             disp('Background Path missing')
        status = 1;
        end
    end
    
end